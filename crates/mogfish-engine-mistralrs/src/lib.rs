// mogfish-engine-mistralrs — InferenceEngine backed by mistral.rs
//
// Loads GGUF models via mistralrs and runs local inference for
// annotation, classification, and Mog script generation.
//
// See docs/plans/mogfish-outside-in-tdd.md

use std::path::Path;
use std::sync::Arc;

use anyhow::Context;
use mistralrs::{GgufModelBuilder, Model, TextMessageRole, TextMessages};
use mogfish_traits::{
    Annotation, Classification, ClassificationCategory, GroundingContext, InferenceEngine,
};

/// Inference engine backed by mistral.rs for local GGUF model inference.
pub struct MistralRsEngine {
    model: Arc<Model>,
    runtime: tokio::runtime::Runtime,
}

impl MistralRsEngine {
    /// Load a GGUF model from the given path.
    ///
    /// `model_path` should point to a `.gguf` file on disk.
    pub fn from_gguf(model_path: &Path) -> anyhow::Result<Self> {
        if !model_path.exists() {
            anyhow::bail!("model file not found: {}", model_path.display());
        }

        let parent = model_path
            .parent()
            .context("model path has no parent directory")?;
        let filename = model_path
            .file_name()
            .context("model path has no filename")?
            .to_str()
            .context("filename is not valid UTF-8")?;
        let model_id = parent
            .to_str()
            .context("parent directory is not valid UTF-8")?;

        let runtime = tokio::runtime::Runtime::new().context("failed to create tokio runtime")?;

        let model = runtime
            .block_on(async {
                GgufModelBuilder::new(model_id, vec![filename])
                    .build()
                    .await
            })
            .context("failed to load GGUF model")?;

        Ok(Self {
            model: Arc::new(model),
            runtime,
        })
    }

    /// Send a chat request and return the text content of the first choice.
    fn chat(&self, system_prompt: &str, user_message: &str) -> anyhow::Result<String> {
        let messages = TextMessages::new()
            .add_message(TextMessageRole::System, system_prompt)
            .add_message(TextMessageRole::User, user_message);

        let response = self
            .runtime
            .block_on(async { self.model.send_chat_request(messages).await })
            .context("chat request failed")?;

        let content = response
            .choices
            .first()
            .and_then(|c| c.message.content.as_ref())
            .context("no response content")?;

        Ok(content.to_string())
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

        // Parse manually since the model returns category as a string
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
