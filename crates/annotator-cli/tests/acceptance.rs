// Layer 0 acceptance test — the outermost shell.
//
// This test defines the first user-visible behavior:
// run the annotator on a directory of .fish completion files,
// get annotated output with mog metadata comments.
//
// Everything behind this test is mocked. The test drives what to build.
//
// See docs/plans/mogfish-outside-in-tdd.md, Layer 0

use std::fs;
use std::path::Path;
use std::process::Command;

use tempfile::TempDir;

/// Copy a few real .fish completion files into a temp dir for testing.
fn setup_completions_dir() -> TempDir {
    let tmp = TempDir::new().expect("create temp dir");

    // Use real completion files from the fish subtree as test fixtures.
    // These are small, simple completions good for testing.
    let fish_completions = Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap()
        .parent()
        .unwrap()
        .join("fish/share/completions");

    for name in &["ls.fish", "cat.fish", "true.fish"] {
        let src = fish_completions.join(name);
        if src.exists() {
            fs::copy(&src, tmp.path().join(name)).expect("copy completion file");
        }
    }

    // Verify we have at least one file
    let count = fs::read_dir(tmp.path())
        .unwrap()
        .filter(|e| {
            e.as_ref()
                .map(|e| e.path().extension().is_some_and(|ext| ext == "fish"))
                .unwrap_or(false)
        })
        .count();
    assert!(count >= 1, "need at least 1 .fish file for test, got {count}");

    tmp
}

/// The outermost acceptance test.
///
/// Given: a temp dir with real .fish completion files
/// When: `mogfish-annotate batch --dir {tmpdir} --engine mock`
/// Then: exit 0
/// And: each .fish file contains # mog-description, # mog-intent, # mog-flags
/// And: original completion content is preserved outside the annotation block
/// And: summary printed to stdout
#[test]
fn batch_annotate_with_mock_engine() {
    let tmp = setup_completions_dir();

    // Snapshot original file contents (for preservation check)
    let originals: Vec<(String, String)> = fs::read_dir(tmp.path())
        .unwrap()
        .filter_map(|e| e.ok())
        .filter(|e| e.path().extension().is_some_and(|ext| ext == "fish"))
        .map(|e| {
            let name = e.file_name().to_string_lossy().to_string();
            let content = fs::read_to_string(e.path()).unwrap();
            (name, content)
        })
        .collect();

    assert!(!originals.is_empty(), "no .fish files found");

    // Run the CLI
    let bin = env!("CARGO_BIN_EXE_mogfish-annotate");
    let output = Command::new(bin)
        .args(["batch", "--dir", tmp.path().to_str().unwrap(), "--engine", "mock"])
        .output()
        .expect("failed to execute mogfish-annotate");

    // Should exit 0
    assert!(
        output.status.success(),
        "mogfish-annotate failed: {}",
        String::from_utf8_lossy(&output.stderr),
    );

    // Should print a summary to stdout
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(
        stdout.contains("processed") || stdout.contains("annotated"),
        "expected summary in stdout, got: {stdout}",
    );

    // Each .fish file should now contain annotation comments
    for (name, original_content) in &originals {
        let annotated = fs::read_to_string(tmp.path().join(name))
            .unwrap_or_else(|_| panic!("read annotated {name}"));

        // Must contain mog annotation markers
        assert!(
            annotated.contains("# mog-description:"),
            "{name} missing # mog-description",
        );
        assert!(
            annotated.contains("# mog-intent:"),
            "{name} missing # mog-intent",
        );
        assert!(
            annotated.contains("# mog-flags:"),
            "{name} missing # mog-flags",
        );

        // Original content must be preserved (appears somewhere in the annotated file)
        // The annotation block is prepended, so the original content follows it.
        assert!(
            annotated.contains(original_content),
            "{name}: original content not preserved in annotated output",
        );
    }
}

/// Dry-run should not modify files.
#[test]
fn batch_dry_run_does_not_modify() {
    let tmp = setup_completions_dir();

    // Snapshot
    let before: Vec<(String, String)> = fs::read_dir(tmp.path())
        .unwrap()
        .filter_map(|e| e.ok())
        .filter(|e| e.path().extension().is_some_and(|ext| ext == "fish"))
        .map(|e| {
            let name = e.file_name().to_string_lossy().to_string();
            let content = fs::read_to_string(e.path()).unwrap();
            (name, content)
        })
        .collect();

    let bin = env!("CARGO_BIN_EXE_mogfish-annotate");
    let output = Command::new(bin)
        .args([
            "batch",
            "--dir",
            tmp.path().to_str().unwrap(),
            "--engine",
            "mock",
            "--dry-run",
        ])
        .output()
        .expect("failed to execute mogfish-annotate");

    assert!(output.status.success(), "dry-run should exit 0");

    // Files should be unchanged
    for (name, original) in &before {
        let after = fs::read_to_string(tmp.path().join(name)).unwrap();
        assert_eq!(
            &after, original,
            "{name} was modified during dry-run",
        );
    }
}

/// Annotating an already-annotated directory should be idempotent.
#[test]
fn batch_annotate_is_idempotent() {
    let tmp = setup_completions_dir();

    let bin = env!("CARGO_BIN_EXE_mogfish-annotate");

    // First run
    let out1 = Command::new(bin)
        .args(["batch", "--dir", tmp.path().to_str().unwrap(), "--engine", "mock"])
        .output()
        .expect("first run");
    assert!(out1.status.success(), "first run failed");

    // Snapshot after first run
    let after_first: Vec<(String, String)> = fs::read_dir(tmp.path())
        .unwrap()
        .filter_map(|e| e.ok())
        .filter(|e| e.path().extension().is_some_and(|ext| ext == "fish"))
        .map(|e| {
            let name = e.file_name().to_string_lossy().to_string();
            let content = fs::read_to_string(e.path()).unwrap();
            (name, content)
        })
        .collect();

    // Second run
    let out2 = Command::new(bin)
        .args(["batch", "--dir", tmp.path().to_str().unwrap(), "--engine", "mock"])
        .output()
        .expect("second run");
    assert!(out2.status.success(), "second run failed");

    // Files should be identical after second run
    for (name, first_content) in &after_first {
        let second_content = fs::read_to_string(tmp.path().join(name)).unwrap();
        assert_eq!(
            &second_content, first_content,
            "{name} changed on second annotation (not idempotent)",
        );
    }
}
