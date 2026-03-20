// Layer 3 acceptance tests — skill cache
//
// A skill is: intent + mog script + fish completion stub.
// The cache stores them, retrieves by intent, and generates .fish stubs.
//
// See docs/plans/mogfish-outside-in-tdd.md, Layer 3

use std::fs;

use tempfile::TempDir;

/// Store a skill and retrieve it by intent.
#[test]
fn store_and_retrieve_skill() {
    let tmp = TempDir::new().unwrap();
    let cache = mogfish_skill_cache::SkillCache::open(tmp.path()).unwrap();

    let mog_script = "// list files sorted by size\nfs.list(\".\") |> sort_by(.size)";
    cache
        .store("list files by size", mog_script, &["ls", "du"])
        .unwrap();

    let skill = cache.get("list files by size").unwrap();
    assert!(skill.is_some(), "skill not found after store");

    let skill = skill.unwrap();
    assert_eq!(skill.intent, "list files by size");
    assert_eq!(skill.mog_script, mog_script);
    assert_eq!(skill.dependencies, vec!["ls", "du"]);
}

/// Retrieve returns None for unknown intent.
#[test]
fn get_unknown_returns_none() {
    let tmp = TempDir::new().unwrap();
    let cache = mogfish_skill_cache::SkillCache::open(tmp.path()).unwrap();

    let result = cache.get("nonexistent skill").unwrap();
    assert!(result.is_none());
}

/// List all cached skills.
#[test]
fn list_skills() {
    let tmp = TempDir::new().unwrap();
    let cache = mogfish_skill_cache::SkillCache::open(tmp.path()).unwrap();

    cache.store("skill one", "// one", &[]).unwrap();
    cache.store("skill two", "// two", &["git"]).unwrap();

    let skills = cache.list().unwrap();
    assert_eq!(skills.len(), 2);

    let intents: Vec<&str> = skills.iter().map(|s| s.intent.as_str()).collect();
    assert!(intents.contains(&"skill one"));
    assert!(intents.contains(&"skill two"));
}

/// Generate a .fish completion stub from a cached skill.
#[test]
fn generate_fish_stub() {
    let tmp = TempDir::new().unwrap();
    let cache = mogfish_skill_cache::SkillCache::open(tmp.path()).unwrap();

    cache
        .store("find large files", "fs.find(\".\", size > 100mb)", &["find"])
        .unwrap();

    let stub = cache.generate_fish_stub("find large files").unwrap();
    assert!(stub.is_some(), "stub not generated");

    let stub = stub.unwrap();
    // Stub should be valid fish completion syntax
    assert!(stub.contains("complete"), "stub missing 'complete' command");
    assert!(
        stub.contains("find large files") || stub.contains("find-large-files"),
        "stub should reference the intent",
    );
}

/// Invalidate a skill by dependency.
#[test]
fn invalidate_by_dependency() {
    let tmp = TempDir::new().unwrap();
    let cache = mogfish_skill_cache::SkillCache::open(tmp.path()).unwrap();

    cache.store("use fd", "// fd stuff", &["fd"]).unwrap();
    cache.store("use rg", "// rg stuff", &["rg"]).unwrap();
    cache
        .store("use both", "// fd and rg", &["fd", "rg"])
        .unwrap();

    let invalidated = cache.invalidate_dependency("fd").unwrap();
    assert_eq!(invalidated, 2, "should invalidate 'use fd' and 'use both'");

    // "use rg" should still be valid
    let rg = cache.get("use rg").unwrap();
    assert!(rg.is_some());
    assert!(!rg.unwrap().stale);

    // "use fd" should be marked stale
    let fd = cache.get("use fd").unwrap();
    assert!(fd.is_some());
    assert!(fd.unwrap().stale);
}

/// Storing a skill with the same intent overwrites.
#[test]
fn overwrite_existing_skill() {
    let tmp = TempDir::new().unwrap();
    let cache = mogfish_skill_cache::SkillCache::open(tmp.path()).unwrap();

    cache.store("my skill", "// v1", &[]).unwrap();
    cache.store("my skill", "// v2", &["new-dep"]).unwrap();

    let skill = cache.get("my skill").unwrap().unwrap();
    assert_eq!(skill.mog_script, "// v2");
    assert_eq!(skill.dependencies, vec!["new-dep"]);

    let all = cache.list().unwrap();
    assert_eq!(all.len(), 1, "overwrite should not duplicate");
}
