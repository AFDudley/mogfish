// Layer 6 acceptance tests — mogfish-classify binary
//
// Fast-path classifier: known commands + skill cache, no model.
// Output format: known:CMD | skill:INTENT | passthrough
//
// See docs/plans/mogfish-outside-in-tdd.md, Layer 6

use std::process::Command;

use tempfile::TempDir;

fn classify(args: &[&str]) -> std::process::Output {
    let bin = env!("CARGO_BIN_EXE_mogfish-classify");
    Command::new(bin)
        .args(args)
        .output()
        .expect("failed to execute mogfish-classify")
}

fn classify_with_env(
    args: &[&str],
    env_vars: &[(&str, &str)],
) -> std::process::Output {
    let bin = env!("CARGO_BIN_EXE_mogfish-classify");
    let mut cmd = Command::new(bin);
    cmd.args(args);
    for (k, v) in env_vars {
        cmd.env(k, v);
    }
    cmd.output().expect("failed to execute mogfish-classify")
}

/// Known command: first word matches a known shell command.
/// `mogfish-classify "git status"` → stdout `known:git`
#[test]
fn classify_known_command() {
    let out = classify(&["git status"]);
    assert!(out.status.success(), "exit 0 expected");
    let stdout = String::from_utf8_lossy(&out.stdout);
    assert_eq!(stdout.trim(), "known:git");
}

/// Unknown input with no cached skill → passthrough.
/// `mogfish-classify "xyzzy"` → stdout `passthrough`
#[test]
fn classify_unknown_passthrough() {
    let out = classify(&["xyzzy"]);
    assert!(out.status.success(), "exit 0 expected");
    let stdout = String::from_utf8_lossy(&out.stdout);
    assert_eq!(stdout.trim(), "passthrough");
}

/// Cached skill: input matches a stored skill's intent.
/// Store a skill, set MOGFISH_DATA_DIR, classify matching input → `skill:INTENT`
#[test]
fn classify_cached_skill() {
    let tmp = TempDir::new().unwrap();
    let skills_dir = tmp.path().join("skills");

    // Store a skill using the SkillCache API
    let cache = mogfish_skill_cache::SkillCache::open(&skills_dir).unwrap();
    cache
        .store("show disk hogs", "// mog script", &["du", "sort"])
        .unwrap();

    // "show" is not a known command, so this hits the skill cache path
    let out = classify_with_env(
        &["show disk hogs in /tmp"],
        &[("MOGFISH_DATA_DIR", tmp.path().to_str().unwrap())],
    );

    assert!(out.status.success(), "exit 0 expected");
    let stdout = String::from_utf8_lossy(&out.stdout);
    assert_eq!(stdout.trim(), "skill:show disk hogs");
}

/// Empty input → passthrough.
/// `mogfish-classify ""` → stdout `passthrough`
#[test]
fn classify_empty_input() {
    let out = classify(&[""]);
    assert!(out.status.success(), "exit 0 expected");
    let stdout = String::from_utf8_lossy(&out.stdout);
    assert_eq!(stdout.trim(), "passthrough");
}
