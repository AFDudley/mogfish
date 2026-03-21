// mogfish-engine-mistralrs — InferenceEngine backed by llama.cpp
//
// Loads GGUF models via llama-cpp-4 and runs local inference for
// annotation, classification, and Mog script generation.
//
// See docs/plans/mogfish-outside-in-tdd.md

use std::num::NonZeroU32;
use std::path::Path;
use std::sync::Mutex;

use anyhow::Context;
use llama_cpp_4::context::params::LlamaContextParams;
use llama_cpp_4::llama_backend::LlamaBackend;
use llama_cpp_4::llama_batch::LlamaBatch;
use llama_cpp_4::model::params::LlamaModelParams;
use llama_cpp_4::model::{AddBos, LlamaModel, Special};
use llama_cpp_4::sampling::LlamaSampler;
use mogfish_traits::{
    Annotation, Classification, ClassificationCategory, GroundingContext, InferenceEngine,
};

/// Maximum tokens to generate per response.
const MAX_TOKENS: usize = 1024;

/// Context window size for inference.
const N_CTX: u32 = 2048;

/// Inference engine backed by llama.cpp for local GGUF model inference.
pub struct MistralRsEngine {
    backend: LlamaBackend,
    model: LlamaModel,
    // Mutex to serialize access — llama.cpp contexts are not thread-safe.
    generation_lock: Mutex<()>,
}

// SAFETY: LlamaModel is Send+Sync (declared in llama-cpp-4).
// LlamaBackend is a singleton marker. We serialize context access via Mutex.
unsafe impl Sync for MistralRsEngine {}

impl MistralRsEngine {
    /// Load a GGUF model from the given path.
    pub fn from_gguf(model_path: &Path) -> anyhow::Result<Self> {
        if !model_path.exists() {
            anyhow::bail!("model file not found: {}", model_path.display());
        }

        let backend =
            LlamaBackend::init().map_err(|e| anyhow::anyhow!("backend init failed: {e}"))?;

        let model_params = LlamaModelParams::default().with_n_gpu_layers(999);
        let model = LlamaModel::load_from_file(&backend, model_path, &model_params)
            .map_err(|e| anyhow::anyhow!("model load failed: {e}"))?;

        Ok(Self {
            backend,
            model,
            generation_lock: Mutex::new(()),
        })
    }

    /// Format messages using Gemma 3 instruct format, create a context,
    /// tokenize, decode, and sample until EOS or max tokens.
    ///
    /// The GGUF's embedded chat template is ChatML (from fine-tuning tooling)
    /// but the model's actual vocabulary uses Gemma tokens. We format manually.
    fn chat(&self, system_prompt: &str, user_message: &str) -> anyhow::Result<String> {
        let _lock = self
            .generation_lock
            .lock()
            .map_err(|e| anyhow::anyhow!("lock poisoned: {e}"))?;

        // Gemma 3 instruct format — combine instruction (system) + input (user)
        // into the user turn, matching the Alpaca fine-tuning data layout.
        let prompt = if system_prompt.is_empty() {
            format!(
                "<start_of_turn>user\n{user_message}<end_of_turn>\n<start_of_turn>model\n"
            )
        } else {
            format!(
                "<start_of_turn>user\n{system_prompt}\n\n{user_message}<end_of_turn>\n<start_of_turn>model\n"
            )
        };

        eprintln!("[chat] prompt ({} chars): {:?}", prompt.len(), &prompt[..prompt.len().min(500)]);

        // Tokenize
        let tokens = self
            .model
            .str_to_token(&prompt, AddBos::Never)
            .map_err(|e| anyhow::anyhow!("tokenize error: {e}"))?;

        // Create context
        let ctx_params =
            LlamaContextParams::default().with_n_ctx(Some(NonZeroU32::new(N_CTX).unwrap()));
        let mut ctx = self
            .model
            .new_context(&self.backend, ctx_params)
            .map_err(|e| anyhow::anyhow!("context creation failed: {e}"))?;

        // Feed prompt tokens
        let mut batch = LlamaBatch::new(N_CTX as usize, 1);
        let last_idx = (tokens.len() - 1) as i32;
        for (i, &token) in tokens.iter().enumerate() {
            let is_last = i as i32 == last_idx;
            batch
                .add(token, i as i32, &[0], is_last)
                .map_err(|e| anyhow::anyhow!("batch add error: {e}"))?;
        }
        ctx.decode(&mut batch)
            .map_err(|e| anyhow::anyhow!("decode error: {e}"))?;

        // Sample tokens
        let mut sampler = LlamaSampler::chain_simple([
            LlamaSampler::temp(0.1),
            LlamaSampler::greedy(),
        ]);

        let mut output = String::new();
        let mut n_cur = tokens.len() as i32;
        let eos = self.model.token_eos();

        for _ in 0..MAX_TOKENS {
            let token = sampler.sample(&ctx, -1);
            sampler.accept(token);

            if token == eos {
                break;
            }

            // Use Special::Tokenize to see special tokens, then filter them
            let piece = self
                .model
                .token_to_str(token, Special::Tokenize)
                .map_err(|e| anyhow::anyhow!("token to str error: {e}"))?;

            // Stop on any end-of-generation marker
            if piece.contains("<end_of_turn>") || piece.contains("</s>") || piece.contains("<|im_end|>") {
                break;
            }

            output.push_str(&piece);

            // Prepare next batch with just this token
            batch.clear();
            batch
                .add(token, n_cur, &[0], true)
                .map_err(|e| anyhow::anyhow!("batch add error: {e}"))?;
            ctx.decode(&mut batch)
                .map_err(|e| anyhow::anyhow!("decode error: {e}"))?;

            n_cur += 1;
        }

        // Clean SentencePiece artifacts from MLX-trained models:
        // - U+2581 (▁) space markers
        // - [UNK_BYTE_0xe29681...] strings that llama.cpp emits for unknown tokens
        let output = output.replace('\u{2581}', " ");
        // Strip [UNK_BYTE_0xe29681 X] patterns — keep the X (the actual content after the space)
        let mut cleaned = String::with_capacity(output.len());
        let mut chars = output.chars().peekable();
        while let Some(c) = chars.next() {
            if c == '[' {
                // Check for [UNK_BYTE_0xe29681 ...]
                let rest: String = chars.clone().take(20).collect();
                if rest.starts_with("UNK_BYTE_0xe29681") {
                    // Skip past the closing ]
                    while let Some(ch) = chars.next() {
                        if ch == ']' {
                            break;
                        }
                    }
                    continue;
                }
            }
            cleaned.push(c);
        }
        Ok(cleaned)
    }

    /// Extract JSON from a response that may contain markdown code fences
    /// or have JSON embedded in surrounding text.
    fn extract_json(text: &str) -> &str {
        let trimmed = text.trim();
        // Try markdown code fences first
        if let Some(start) = trimmed.find("```json") {
            let after = &trimmed[start + 7..];
            if let Some(end) = after.find("```") {
                return after[..end].trim();
            }
        }
        if let Some(start) = trimmed.find("```") {
            let after = &trimmed[start + 3..];
            if let Some(end) = after.find("```") {
                return after[..end].trim();
            }
        }
        // Try to find a JSON object by matching braces
        if let Some(json) = Self::find_json_object(trimmed) {
            return json;
        }
        trimmed
    }

    /// Find the first complete JSON object `{...}` in text by matching braces.
    fn find_json_object(text: &str) -> Option<&str> {
        let start = text.find('{')?;
        let mut depth = 0i32;
        let mut in_string = false;
        let mut escape_next = false;
        for (i, ch) in text[start..].char_indices() {
            if escape_next {
                escape_next = false;
                continue;
            }
            match ch {
                '\\' if in_string => escape_next = true,
                '"' => in_string = !in_string,
                '{' if !in_string => depth += 1,
                '}' if !in_string => {
                    depth -= 1;
                    if depth == 0 {
                        return Some(&text[start..start + i + 1]);
                    }
                }
                _ => {}
            }
        }
        None
    }
}

impl InferenceEngine for MistralRsEngine {
    fn annotate(&self, command_name: &str, help_text: &str) -> anyhow::Result<Annotation> {
        // Must match the Alpaca training format exactly:
        //   instruction: "Generate a mogfish annotation for this command documentation"
        //   input: "Command: {name}\n\n{help_text}"
        let system = "Generate a mogfish annotation for this command documentation";
        let user_msg = format!("Command: {command_name}\n\n{help_text}");
        let raw = self.chat(system, &user_msg)?;
        eprintln!("[annotate] raw response ({} chars): {:?}", raw.len(), &raw[..raw.len().min(500)]);
        let json_str = Self::extract_json(&raw);
        eprintln!("[annotate] extracted JSON: {:?}", &json_str[..json_str.len().min(500)]);

        // Parse as Value first to fix flags missing the "description" field —
        // the 1B model sometimes omits it.
        let mut v: serde_json::Value = serde_json::from_str(json_str)
            .with_context(|| format!("failed to parse annotation JSON from: {json_str}"))?;
        if let Some(flags) = v.get_mut("flags").and_then(|f| f.as_array_mut()) {
            flags.retain(|f| f.get("flag").is_some());
            for flag in flags.iter_mut() {
                if flag.get("description").is_none() {
                    flag.as_object_mut()
                        .unwrap()
                        .insert("description".to_string(), serde_json::json!(""));
                }
            }
        }
        let ann: Annotation = serde_json::from_value(v)
            .with_context(|| format!("failed to deserialize annotation from: {json_str}"))?;
        Ok(ann)
    }

    fn classify(&self, input: &str) -> anyhow::Result<Classification> {
        let system = r#"Classify this input and respond with ONLY a JSON object: {"category": "KnownCommand", "confidence": 0.9, "command": "name"}"#;

        let raw = self.chat(system, input)?;
        eprintln!("[classify] raw response ({} chars): {:?}", raw.len(), &raw[..raw.len().min(500)]);
        let json_str = Self::extract_json(&raw);
        eprintln!("[classify] extracted JSON: {:?}", &json_str[..json_str.len().min(500)]);

        // The fine-tuned model may not reliably classify — parse what we can,
        // falling back to sensible defaults if the JSON is malformed.
        let v: serde_json::Value = match serde_json::from_str(json_str) {
            Ok(v) => v,
            Err(_) => {
                // Try to find any JSON object in the response
                if let Some(json) = Self::find_json_object(&raw) {
                    serde_json::from_str(json)
                        .with_context(|| format!("failed to parse classification JSON from: {json}"))?
                } else {
                    // Model can't classify — return a safe default
                    return Ok(Classification {
                        category: ClassificationCategory::Passthrough,
                        confidence: 0.5,
                        command: None,
                    });
                }
            }
        };

        let category = match v["category"].as_str().unwrap_or("Passthrough") {
            "KnownCommand" => ClassificationCategory::KnownCommand,
            "CachedSkill" => ClassificationCategory::CachedSkill,
            "GenerateNew" => ClassificationCategory::GenerateNew,
            _ => ClassificationCategory::Passthrough,
        };

        let confidence = v["confidence"].as_f64().unwrap_or(0.5).clamp(0.0, 1.0);
        let command = v["command"].as_str().map(String::from);

        Ok(Classification {
            category,
            confidence,
            command,
        })
    }

    fn generate_mog(&self, intent: &str, context: &GroundingContext) -> anyhow::Result<String> {
        let commands_list = context.available_commands.join(", ");
        let cwd = context
            .working_directory
            .as_ref()
            .map(|p| p.display().to_string())
            .unwrap_or_else(|| ".".to_string());

        let system = "You are a shell script generator. Given a user intent and available commands, \
            generate a shell script that accomplishes the intent. \
            Respond with ONLY the script, no explanation or markdown fences.";

        let user_msg = format!(
            "Intent: {intent}\nAvailable commands: {commands_list}\nWorking directory: {cwd}"
        );

        self.chat(system, &user_msg)
    }
}
