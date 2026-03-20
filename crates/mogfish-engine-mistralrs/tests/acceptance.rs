// Acceptance tests for MistralRsEngine
//
// These test the public API of mogfish-engine-mistralrs through the
// InferenceEngine trait. Tests that require a real model are gated
// behind MOGFISH_TEST_MODEL env var and marked #[ignore].

use std::path::Path;

use mogfish_engine_mistralrs::MistralRsEngine;
use mogfish_traits::{ClassificationCategory, GroundingContext, InferenceEngine};

/// Helper: skip if no model path is set.
fn test_model_path() -> Option<String> {
    std::env::var("MOGFISH_TEST_MODEL").ok()
}

fn make_engine() -> MistralRsEngine {
    let path = test_model_path().expect("MOGFISH_TEST_MODEL must be set");
    MistralRsEngine::from_gguf(Path::new(&path)).expect("failed to load model")
}

// -- Structural tests (no model needed) --

#[test]
fn engine_is_send_sync() {
    fn assert_send_sync<T: Send + Sync>() {}
    assert_send_sync::<MistralRsEngine>();
}

#[test]
fn from_gguf_rejects_missing_file() {
    let result = MistralRsEngine::from_gguf(Path::new("/nonexistent/model.gguf"));
    assert!(result.is_err());
}

// -- Integration tests (require a GGUF model) --

#[test]
#[ignore]
fn annotate_returns_valid_annotation() {
    let engine = make_engine();
    let ann = engine
        .annotate("git", "git - the stupid content tracker")
        .expect("annotate failed");

    assert!(!ann.description.is_empty(), "description must not be empty");
    assert!(!ann.intents.is_empty(), "must have at least one intent");
}

#[test]
#[ignore]
fn classify_returns_valid_classification() {
    let engine = make_engine();
    let cls = engine.classify("git status").expect("classify failed");

    assert!(
        cls.confidence >= 0.0 && cls.confidence <= 1.0,
        "confidence must be in [0, 1]"
    );
    // Should recognize "git status" as a known command
    assert!(matches!(
        cls.category,
        ClassificationCategory::KnownCommand | ClassificationCategory::Passthrough
    ));
}

#[test]
#[ignore]
fn generate_mog_returns_nonempty_script() {
    let engine = make_engine();
    let ctx = GroundingContext {
        available_commands: vec!["git".to_string(), "ls".to_string()],
        working_directory: None,
    };
    let script = engine
        .generate_mog("list files in current directory", &ctx)
        .expect("generate_mog failed");

    assert!(!script.is_empty(), "mog script must not be empty");
}

#[test]
#[ignore]
fn annotate_produces_flag_docs_for_complex_command() {
    let engine = make_engine();
    let help_text = "\
Usage: rsync [OPTION]... SRC [SRC]... DEST
  -v, --verbose        increase verbosity
  -a, --archive        archive mode
  -n, --dry-run        perform a trial run with no changes made";

    let ann = engine
        .annotate("rsync", help_text)
        .expect("annotate failed");

    // A model should extract at least some flags from structured help text
    assert!(
        !ann.flags.is_empty(),
        "should extract flags from help text"
    );
}
