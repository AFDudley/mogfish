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
use llama_cpp_4::model::{AddBos, LlamaChatMessage, LlamaModel, Special};
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

    /// Format messages using the model's chat template, create a context,
    /// tokenize, decode, and sample until EOS or max tokens.
    fn chat(&self, system_prompt: &str, user_message: &str) -> anyhow::Result<String> {
        let _lock = self
            .generation_lock
            .lock()
            .map_err(|e| anyhow::anyhow!("lock poisoned: {e}"))?;

        // Build chat messages and apply template
        let messages = vec![
            LlamaChatMessage::new("system".to_string(), system_prompt.to_string())
                .map_err(|e| anyhow::anyhow!("chat message error: {e}"))?,
            LlamaChatMessage::new("user".to_string(), user_message.to_string())
                .map_err(|e| anyhow::anyhow!("chat message error: {e}"))?,
        ];

        let prompt = self
            .model
            .apply_chat_template(None, messages, true)
            .map_err(|e| anyhow::anyhow!("chat template error: {e}"))?;

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

            let piece = self
                .model
                .token_to_str(token, Special::Plaintext)
                .map_err(|e| anyhow::anyhow!("token to str error: {e}"))?;
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

        Ok(output)
    }

    /// Extract JSON from a response that may contain markdown code fences.
    fn extract_json(text: &str) -> &str {
        let trimmed = text.trim();
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
        trimmed
    }
}

impl InferenceEngine for MistralRsEngine {
    fn annotate(&self, command_name: &str, help_text: &str) -> anyhow::Result<Annotation> {
        let system = r#"You are a CLI documentation analyzer. Given a command name and its help text, produce a JSON object with this exact schema:
{
  "description": "one-line description of what the command does",
  "intents": ["intent1", "intent2"],
  "flags": [{"flag": "--name", "description": "what the flag does"}]
}
Respond with ONLY the JSON object, no other text."#;

        let user_msg = format!("Command: {command_name}\n\nHelp text:\n{help_text}");
        let raw = self.chat(system, &user_msg)?;
        let json_str = Self::extract_json(&raw);
        let ann: Annotation =
            serde_json::from_str(json_str).context("failed to parse annotation JSON")?;
        Ok(ann)
    }

    fn classify(&self, input: &str) -> anyhow::Result<Classification> {
        let system = r#"You are an input classifier. Given user input, classify it as one of:
- "KnownCommand" if it starts with a recognized CLI command
- "CachedSkill" if it matches a cached skill pattern
- "GenerateNew" if it needs new code generation
- "Passthrough" if no action is needed

Respond with ONLY a JSON object:
{
  "category": "KnownCommand|CachedSkill|GenerateNew|Passthrough",
  "confidence": 0.0-1.0,
  "command": "the command name or null"
}"#;

        let raw = self.chat(system, input)?;
        let json_str = Self::extract_json(&raw);

        let v: serde_json::Value =
            serde_json::from_str(json_str).context("failed to parse classification JSON")?;

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
