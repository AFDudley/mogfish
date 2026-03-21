// mogfish-traits — shared traits and types for mogfish
//
// See docs/plans/mogfish-outside-in-tdd.md

use std::path::Path;

/// Semantic annotation produced by an inference engine.
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct Annotation {
    pub description: String,
    pub intents: Vec<String>,
    pub flags: Vec<FlagDoc>,
}

/// Documentation for a single CLI flag.
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct FlagDoc {
    pub flag: String,
    pub description: String,
}

/// Classification result for user input.
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct Classification {
    pub category: ClassificationCategory,
    pub confidence: f64,
    pub command: Option<String>,
}

/// What kind of input this is.
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub enum ClassificationCategory {
    KnownCommand,
    CachedSkill,
    GenerateNew,
    Passthrough,
    /// Escalate to a large model (via exophial) for capability fixes,
    /// source code review, or tasks beyond the local model's ability.
    Escalate,
}

/// Core trait for LLM-backed inference. Implementations:
/// - `MockInferenceEngine` (deterministic, for testing)
/// - Future: mistral.rs, ollama, etc.
pub trait InferenceEngine: Send + Sync {
    fn annotate(
        &self,
        command_name: &str,
        help_text: &str,
    ) -> anyhow::Result<Annotation>;

    fn classify(&self, input: &str) -> anyhow::Result<Classification>;

    fn generate_mog(
        &self,
        intent: &str,
        context: &GroundingContext,
    ) -> anyhow::Result<String>;
}

/// Context provided to the engine when generating Mog scripts.
#[derive(Debug, Clone)]
pub struct GroundingContext {
    pub available_commands: Vec<String>,
    pub working_directory: Option<Box<Path>>,
}

/// Deterministic mock engine for testing. Returns fixed responses.
pub struct MockInferenceEngine {
    pub annotation: Annotation,
    pub classification: Classification,
    pub mog_script: String,
}

impl MockInferenceEngine {
    pub fn new() -> Self {
        Self {
            annotation: Annotation {
                description: "Mock description".to_string(),
                intents: vec!["mock-intent".to_string()],
                flags: vec![FlagDoc {
                    flag: "--mock".to_string(),
                    description: "A mock flag".to_string(),
                }],
            },
            classification: Classification {
                category: ClassificationCategory::Passthrough,
                confidence: 1.0,
                command: None,
            },
            mog_script: "// mock mog script\n".to_string(),
        }
    }
}

impl Default for MockInferenceEngine {
    fn default() -> Self {
        Self::new()
    }
}

impl InferenceEngine for MockInferenceEngine {
    fn annotate(
        &self,
        _command_name: &str,
        _help_text: &str,
    ) -> anyhow::Result<Annotation> {
        Ok(self.annotation.clone())
    }

    fn classify(&self, _input: &str) -> anyhow::Result<Classification> {
        Ok(self.classification.clone())
    }

    fn generate_mog(
        &self,
        _intent: &str,
        _context: &GroundingContext,
    ) -> anyhow::Result<String> {
        Ok(self.mog_script.clone())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn mock_engine_implements_trait() {
        let engine = MockInferenceEngine::new();
        let ann = engine.annotate("git", "git help text").unwrap();
        assert_eq!(ann.description, "Mock description");
        assert!(!ann.intents.is_empty());
        assert!(!ann.flags.is_empty());
    }

    #[test]
    fn mock_engine_is_send_sync() {
        fn assert_send_sync<T: Send + Sync>() {}
        assert_send_sync::<MockInferenceEngine>();
    }

    #[test]
    fn mock_classify_returns_passthrough() {
        let engine = MockInferenceEngine::new();
        let cls = engine.classify("some input").unwrap();
        assert!(matches!(cls.category, ClassificationCategory::Passthrough));
    }
}
