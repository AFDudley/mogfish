// mogfish-engine-mistralrs — InferenceEngine backed by mistral.rs
//
// Loads a HuggingFace safetensors model via mistral.rs with ISQ (in-situ
// quantization) at load time. Uses native JSON schema constraints for
// structured output (annotation, classification) and free-form generation
// for Mog scripts.
//
// See docs/plans/mogfish-outside-in-tdd.md

use std::path::{Path, PathBuf};

use anyhow::Context;
use mistralrs::blocking::BlockingModel;
use mistralrs::{
    Constraint, Device, DrySamplingParams, IsqType, MemoryGpuConfig, ModelBuilder,
    PagedAttentionMetaBuilder, RequestBuilder, TextMessageRole, TextMessages,
    TextModelBuilder, UqffTextModelBuilder,
};
use mogfish_traits::{
    Annotation, Classification, ClassificationCategory, GroundingContext, InferenceEngine,
};

/// Maximum input characters before truncation. Fish completion files
/// can be 200KB+ (git.fish); we truncate to fit the context window.
const MAX_INPUT_CHARS: usize = 8000;

/// Inference engine backed by mistral.rs for local safetensors inference.
///
/// Uses `BlockingModel` which owns a tokio runtime internally, bridging
/// the async mistral.rs API to the sync `InferenceEngine` trait.
pub struct MistralRsEngine {
    model: BlockingModel,
}

// BlockingModel owns Arc<Runtime> + Arc<MistralRs>, both Send+Sync.
unsafe impl Send for MistralRsEngine {}
unsafe impl Sync for MistralRsEngine {}

impl MistralRsEngine {
    /// Load a HuggingFace model (local path or HF model ID) with ISQ Q4K quantization.
    ///
    /// `model_id` can be:
    /// - A HuggingFace model ID like `"unsloth/gemma-3-1b-it"` (downloaded automatically)
    /// - A local path to a directory containing safetensors + config.json + tokenizer.json
    ///
    /// `use_gpu`: true to load on GPU with PagedAttention, false for CPU.
    /// Use `from_hf_model_gpu_no_pa` for GPU without PagedAttention (e.g.
    /// on GPUs where PA has kernel compatibility issues).
    pub fn from_hf_model(model_id: &str, use_gpu: bool) -> anyhow::Result<Self> {
        let mut builder = ModelBuilder::new(model_id)
            .with_isq(IsqType::Q4K)
            .with_logging();

        if use_gpu {
            // Limit KV cache to 4096 tokens via PagedAttention. Without this,
            // models with large max_position_embeddings (e.g. Gemma 3's 131072)
            // cause PA to pre-allocate a KV cache that exhausts VRAM on cards
            // with 12GB. Our actual usage is ~2000 input + 1024 output tokens.
            builder = builder.with_paged_attn(
                PagedAttentionMetaBuilder::default()
                    .with_gpu_memory(MemoryGpuConfig::ContextSize(4096))
                    .build()?,
            );
        } else {
            builder = builder.with_device(Device::Cpu);
        }

        let model = BlockingModel::from_auto_builder(builder)
            .map_err(|e| anyhow::anyhow!("model load failed: {e}"))?;

        Ok(Self { model })
    }

    /// Load on GPU without PagedAttention. Uses standard attention with
    /// the full KV cache in VRAM. Suitable for small models (1B Q4K ~700MB)
    /// on GPUs where PagedAttention kernels have compatibility issues
    /// (e.g. Blackwell sm_120).
    pub fn from_hf_model_gpu_no_pa(model_id: &str) -> anyhow::Result<Self> {
        let builder = ModelBuilder::new(model_id)
            .with_isq(IsqType::Q4K)
            .with_logging();

        let model = BlockingModel::from_auto_builder(builder)
            .map_err(|e| anyhow::anyhow!("model load failed: {e}"))?;

        Ok(Self { model })
    }

    /// Load from a local directory path, verifying it exists first.
    pub fn from_local_model(model_path: &Path, use_gpu: bool) -> anyhow::Result<Self> {
        if !model_path.exists() {
            anyhow::bail!("model directory not found: {}", model_path.display());
        }
        Self::from_hf_model(&model_path.to_string_lossy(), use_gpu)
    }

    /// Load from a pre-quantized UQFF file. Skips the fp16 intermediate —
    /// tensors go directly to the target device at the quantized size.
    ///
    /// `model_id` is the HF model directory (for tokenizer, config, etc.).
    /// `uqff_path` is the path to the first `.uqff` shard file (remaining
    /// shards are auto-discovered).
    pub fn from_uqff(model_id: &str, uqff_path: &Path, use_gpu: bool) -> anyhow::Result<Self> {
        if !uqff_path.exists() {
            anyhow::bail!("UQFF file not found: {}", uqff_path.display());
        }

        let uqff_builder =
            UqffTextModelBuilder::new(model_id, vec![PathBuf::from(uqff_path)]);
        let mut builder: TextModelBuilder = uqff_builder.into();

        if use_gpu {
            builder = builder.with_paged_attn(
                PagedAttentionMetaBuilder::default()
                    .with_gpu_memory(MemoryGpuConfig::ContextSize(4096))
                    .build()?,
            );
        } else {
            builder = builder.with_device(Device::Cpu);
        }

        builder = builder.with_logging();

        let model = BlockingModel::from_builder(builder)
            .map_err(|e| anyhow::anyhow!("UQFF model load failed: {e}"))?;

        Ok(Self { model })
    }

    /// Build the annotation JSON schema as a serde_json::Value.
    fn annotation_schema() -> serde_json::Value {
        serde_json::json!({
            "type": "object",
            "properties": {
                "description": { "type": "string" },
                "intents": {
                    "type": "array",
                    "items": { "type": "string" },
                    "maxItems": 10
                },
                "flags": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "flag": { "type": "string" },
                            "description": { "type": "string" }
                        },
                        "required": ["flag", "description"]
                    },
                    "maxItems": 30
                }
            },
            "required": ["description", "intents", "flags"]
        })
    }

    /// Build the classification JSON schema as a serde_json::Value.
    fn classification_schema() -> serde_json::Value {
        serde_json::json!({
            "type": "object",
            "properties": {
                "category": {
                    "type": "string",
                    "enum": ["KnownCommand", "CachedSkill", "GenerateNew", "Passthrough", "Escalate"]
                },
                "confidence": { "type": "number", "minimum": 0.0, "maximum": 1.0 },
                "command": { "type": ["string", "null"] }
            },
            "required": ["category", "confidence"]
        })
    }

    /// Send a constrained chat request and return the raw response text.
    fn chat_constrained(
        &self,
        system_prompt: &str,
        user_message: &str,
        schema: serde_json::Value,
    ) -> anyhow::Result<String> {
        let messages: RequestBuilder = TextMessages::new()
            .add_message(TextMessageRole::System, system_prompt)
            .add_message(TextMessageRole::User, user_message)
            .into();

        let dry = DrySamplingParams::new_with_defaults(0.8, None, None, None)
            .map_err(|e| anyhow::anyhow!("DRY params: {e}"))?;

        let request = messages
            .set_constraint(Constraint::JsonSchema(schema))
            .set_sampler_temperature(0.1)
            .set_sampler_max_len(512)
            .set_sampler_dry_params(dry);

        let response = self
            .model
            .send_chat_request(request)
            .map_err(|e| anyhow::anyhow!("inference failed: {e}"))?;

        response
            .choices
            .into_iter()
            .next()
            .and_then(|c| c.message.content)
            .ok_or_else(|| anyhow::anyhow!("empty response from model"))
    }

    /// Send an unconstrained chat request and return the raw response text.
    fn chat_free(
        &self,
        system_prompt: &str,
        user_message: &str,
    ) -> anyhow::Result<String> {
        let messages: RequestBuilder = TextMessages::new()
            .add_message(TextMessageRole::System, system_prompt)
            .add_message(TextMessageRole::User, user_message)
            .into();

        let dry = DrySamplingParams::new_with_defaults(0.8, None, None, None)
            .map_err(|e| anyhow::anyhow!("DRY params: {e}"))?;

        let request = messages
            .set_sampler_temperature(0.1)
            .set_sampler_max_len(512)
            .set_sampler_dry_params(dry);

        let response = self
            .model
            .send_chat_request(request)
            .map_err(|e| anyhow::anyhow!("inference failed: {e}"))?;

        response
            .choices
            .into_iter()
            .next()
            .and_then(|c| c.message.content)
            .ok_or_else(|| anyhow::anyhow!("empty response from model"))
    }
}

impl InferenceEngine for MistralRsEngine {
    fn annotate(&self, command_name: &str, help_text: &str) -> anyhow::Result<Annotation> {
        let system = "Generate a mogfish annotation for this command documentation";
        let truncated_help = if help_text.len() > MAX_INPUT_CHARS {
            &help_text[..MAX_INPUT_CHARS]
        } else {
            help_text
        };
        let user_msg = format!("Command: {command_name}\n\n{truncated_help}");

        let raw = self.chat_constrained(system, &user_msg, Self::annotation_schema())?;
        eprintln!(
            "[annotate] response ({} chars): {:?}",
            raw.len(),
            &raw
        );

        let mut v: serde_json::Value = serde_json::from_str(&raw)
            .with_context(|| format!("failed to parse annotation JSON from: {raw}"))?;

        // Fix flags missing the "description" field — the 1B model sometimes omits it
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
            .with_context(|| format!("failed to deserialize annotation from: {raw}"))?;
        Ok(ann)
    }

    fn classify(&self, input: &str) -> anyhow::Result<Classification> {
        let system = r#"Classify this input and respond with ONLY a JSON object: {"category": "KnownCommand", "confidence": 0.9, "command": "name"}"#;

        let raw = self.chat_constrained(system, input, Self::classification_schema())?;
        eprintln!(
            "[classify] response ({} chars): {:?}",
            raw.len(),
            &raw
        );

        let v: serde_json::Value = serde_json::from_str(&raw)
            .with_context(|| format!("failed to parse classification JSON from: {raw}"))?;

        let category = match v["category"].as_str().unwrap_or("Passthrough") {
            "KnownCommand" => ClassificationCategory::KnownCommand,
            "CachedSkill" => ClassificationCategory::CachedSkill,
            "GenerateNew" => ClassificationCategory::GenerateNew,
            "Escalate" => ClassificationCategory::Escalate,
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
        // Match the training data format: instruction/input pairs for Mog generation
        let system = "Generate a Mog script for this task";

        let mut user_msg = intent.to_string();
        if !context.available_commands.is_empty() {
            user_msg.push_str(&format!(
                "\nAvailable commands: {}",
                context.available_commands.join(", ")
            ));
        }

        self.chat_free(system, &user_msg)
    }
}
