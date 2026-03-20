// mogfish-classifier — input classification
//
// See docs/plans/mogfish-outside-in-tdd.md, Layer 4
//
// Routes input through fast paths before engine fallback:
//   1. Known command set (first word match)
//   2. Skill cache (intent prefix match)
//   3. InferenceEngine::classify() fallback

use mogfish_skill_cache::SkillCache;
use mogfish_traits::{Classification, ClassificationCategory, InferenceEngine};

/// Classifies user input into categories for routing.
pub struct Classifier<'a> {
    known_commands: Vec<String>,
    cache: &'a SkillCache,
    engine: &'a dyn InferenceEngine,
}

impl<'a> Classifier<'a> {
    pub fn new(
        known_commands: &[&str],
        cache: &'a SkillCache,
        engine: &'a dyn InferenceEngine,
    ) -> Self {
        Self {
            known_commands: known_commands.iter().map(|s| s.to_string()).collect(),
            cache,
            engine,
        }
    }

    /// Classify user input.
    pub fn classify(&self, input: &str) -> anyhow::Result<Classification> {
        let first_word = input.split_whitespace().next().unwrap_or("");

        // Fast path 1: known command
        if self.known_commands.iter().any(|c| c == first_word) {
            return Ok(Classification {
                category: ClassificationCategory::KnownCommand,
                confidence: 1.0,
                command: Some(first_word.to_string()),
            });
        }

        // Fast path 2: cached skill (intent prefix match)
        if let Ok(skills) = self.cache.list() {
            for skill in &skills {
                if !skill.stale && input.starts_with(&skill.intent) {
                    return Ok(Classification {
                        category: ClassificationCategory::CachedSkill,
                        confidence: 0.9,
                        command: None,
                    });
                }
            }
        }

        // Fallback: engine
        self.engine.classify(input)
    }
}
