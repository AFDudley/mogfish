// Acceptance tests for MistralRsEngine
//
// These test the public API of mogfish-engine-mistralrs through the
// InferenceEngine trait. Tests that require a real model are gated
// behind MOGFISH_TEST_MODEL env var and marked #[ignore].

use std::sync::OnceLock;

use mogfish_engine_mistralrs::MistralRsEngine;
use mogfish_traits::{ClassificationCategory, GroundingContext, InferenceEngine};

/// Shared engine instance — mistral.rs model loading is expensive,
/// so we share a single engine across all tests in this process.
static ENGINE: OnceLock<MistralRsEngine> = OnceLock::new();

fn get_engine() -> &'static MistralRsEngine {
    ENGINE.get_or_init(|| {
        let model_id =
            std::env::var("MOGFISH_TEST_MODEL").expect("MOGFISH_TEST_MODEL must be set");
        let use_gpu = std::env::var("MOGFISH_USE_GPU")
            .map(|v| v == "1" || v == "true")
            .unwrap_or(false);
        MistralRsEngine::from_hf_model(&model_id, use_gpu).expect("failed to load model")
    })
}

// -- Structural tests (no model needed) --

#[test]
fn engine_is_send_sync() {
    fn assert_send_sync<T: Send + Sync>() {}
    assert_send_sync::<MistralRsEngine>();
}

#[test]
fn from_local_model_rejects_missing_dir() {
    let path = std::path::Path::new("/nonexistent/model");
    assert!(!path.exists());
}

// -- Integration tests (require a HF model) --

#[test]
#[ignore]
fn annotate_returns_valid_annotation() {
    let engine = get_engine();
    let ann = engine
        .annotate("git", "git - the stupid content tracker")
        .expect("annotate failed");

    assert!(!ann.description.is_empty(), "description must not be empty");
    assert!(!ann.intents.is_empty(), "must have at least one intent");
}

#[test]
#[ignore]
fn classify_returns_valid_classification() {
    let engine = get_engine();
    let cls = engine.classify("git status").expect("classify failed");

    assert!(
        cls.confidence >= 0.0 && cls.confidence <= 1.0,
        "confidence must be in [0, 1]"
    );
    assert!(matches!(
        cls.category,
        ClassificationCategory::KnownCommand | ClassificationCategory::Passthrough
    ));
}

#[test]
#[ignore]
fn generate_mog_returns_nonempty_script() {
    let engine = get_engine();
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
    let engine = get_engine();
    let help_text = "\
Usage: rsync [OPTION]... SRC [SRC]... DEST
  -v, --verbose        increase verbosity
  -a, --archive        archive mode
  -n, --dry-run        perform a trial run with no changes made";

    let ann = engine
        .annotate("rsync", help_text)
        .expect("annotate failed");

    assert!(
        !ann.flags.is_empty(),
        "should extract flags from help text"
    );
}
