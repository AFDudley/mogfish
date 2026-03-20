// Layer 4 acceptance tests — classifier
//
// The classifier routes user input through fast paths before
// falling back to the inference engine:
//   1. Known command set → KnownCommand
//   2. Skill cache prefix match → CachedSkill
//   3. Engine fallback → whatever the engine says
//
// See docs/plans/mogfish-outside-in-tdd.md, Layer 4

use tempfile::TempDir;

use mogfish_traits::{ClassificationCategory, MockInferenceEngine};

/// Input matching a known command should classify as KnownCommand
/// without calling the engine.
#[test]
fn known_command_fast_path() {
    let tmp = TempDir::new().unwrap();
    let cache = mogfish_skill_cache::SkillCache::open(tmp.path()).unwrap();
    let engine = MockInferenceEngine::new();

    let classifier = mogfish_classifier::Classifier::new(
        &["git", "ls", "cd", "cat"],
        &cache,
        &engine,
    );

    let result = classifier.classify("git status").unwrap();
    assert!(
        matches!(result.category, ClassificationCategory::KnownCommand),
        "expected KnownCommand, got {:?}",
        result.category,
    );
    assert_eq!(result.command.as_deref(), Some("git"));
}

/// Input matching a cached skill should classify as CachedSkill.
#[test]
fn cached_skill_match() {
    let tmp = TempDir::new().unwrap();
    let cache = mogfish_skill_cache::SkillCache::open(tmp.path()).unwrap();
    cache.store("find large files", "// mog", &["find"]).unwrap();

    let engine = MockInferenceEngine::new();
    let classifier = mogfish_classifier::Classifier::new(&[], &cache, &engine);

    let result = classifier.classify("find large files in /tmp").unwrap();
    assert!(
        matches!(result.category, ClassificationCategory::CachedSkill),
        "expected CachedSkill, got {:?}",
        result.category,
    );
}

/// Input that matches nothing falls through to engine.
#[test]
fn engine_fallback() {
    let tmp = TempDir::new().unwrap();
    let cache = mogfish_skill_cache::SkillCache::open(tmp.path()).unwrap();
    let engine = MockInferenceEngine::new();

    let classifier = mogfish_classifier::Classifier::new(&[], &cache, &engine);

    let result = classifier.classify("do something completely novel").unwrap();
    // MockInferenceEngine returns Passthrough by default
    assert!(
        matches!(result.category, ClassificationCategory::Passthrough),
        "expected Passthrough from mock engine, got {:?}",
        result.category,
    );
}

/// Known commands take priority over cached skills.
#[test]
fn known_command_takes_priority() {
    let tmp = TempDir::new().unwrap();
    let cache = mogfish_skill_cache::SkillCache::open(tmp.path()).unwrap();
    // Store a skill that starts with "git"
    cache.store("git helper", "// mog", &[]).unwrap();

    let engine = MockInferenceEngine::new();
    let classifier = mogfish_classifier::Classifier::new(&["git"], &cache, &engine);

    let result = classifier.classify("git push origin main").unwrap();
    assert!(
        matches!(result.category, ClassificationCategory::KnownCommand),
        "known command should win over cached skill",
    );
}
