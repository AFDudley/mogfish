// Layer 1 tests — annotator parser edge cases
//
// These test behaviors not covered by the Layer 0 acceptance tests:
// malformed files, empty files, non-fish files mixed in, binary content.
//
// See docs/plans/mogfish-outside-in-tdd.md, Layer 1

use std::fs;
use std::process::Command;

use tempfile::TempDir;

fn bin() -> String {
    env!("CARGO_BIN_EXE_mogfish-annotate").to_string()
}

/// Empty .fish file should be annotated without error.
#[test]
fn empty_fish_file_gets_annotated() {
    let tmp = TempDir::new().unwrap();
    fs::write(tmp.path().join("empty.fish"), "").unwrap();

    let output = Command::new(bin())
        .args(["batch", "--dir", tmp.path().to_str().unwrap(), "--engine", "mock"])
        .output()
        .unwrap();

    assert!(output.status.success(), "failed on empty file: {}", String::from_utf8_lossy(&output.stderr));

    let content = fs::read_to_string(tmp.path().join("empty.fish")).unwrap();
    assert!(content.contains("# mog-description:"), "empty file should still get annotations");
}

/// Non-.fish files in the directory should be ignored.
#[test]
fn non_fish_files_ignored() {
    let tmp = TempDir::new().unwrap();
    fs::write(tmp.path().join("readme.md"), "# hello").unwrap();
    fs::write(tmp.path().join("script.py"), "print('hi')").unwrap();
    fs::write(tmp.path().join("real.fish"), "complete -c test\n").unwrap();

    let output = Command::new(bin())
        .args(["batch", "--dir", tmp.path().to_str().unwrap(), "--engine", "mock"])
        .output()
        .unwrap();

    assert!(output.status.success());

    // Non-fish files should be untouched
    assert_eq!(fs::read_to_string(tmp.path().join("readme.md")).unwrap(), "# hello");
    assert_eq!(fs::read_to_string(tmp.path().join("script.py")).unwrap(), "print('hi')");

    // Fish file should be annotated
    let fish = fs::read_to_string(tmp.path().join("real.fish")).unwrap();
    assert!(fish.contains("# mog-description:"));
}

/// Directory with no .fish files should succeed with 0 processed.
#[test]
fn empty_directory_succeeds() {
    let tmp = TempDir::new().unwrap();

    let output = Command::new(bin())
        .args(["batch", "--dir", tmp.path().to_str().unwrap(), "--engine", "mock"])
        .output()
        .unwrap();

    assert!(output.status.success());
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(
        stdout.contains("0 processed") || stdout.contains("0 "),
        "should report 0 files: {stdout}",
    );
}

/// File with binary/non-UTF8 content should be skipped, not crash.
#[test]
fn binary_file_skipped_gracefully() {
    let tmp = TempDir::new().unwrap();
    fs::write(tmp.path().join("binary.fish"), b"\x00\x01\x02\xff\xfe").unwrap();
    fs::write(tmp.path().join("good.fish"), "complete -c test\n").unwrap();

    let output = Command::new(bin())
        .args(["batch", "--dir", tmp.path().to_str().unwrap(), "--engine", "mock"])
        .output()
        .unwrap();

    // Should not crash — the good file should still be annotated
    assert!(output.status.success(), "crashed on binary file: {}", String::from_utf8_lossy(&output.stderr));

    let good = fs::read_to_string(tmp.path().join("good.fish")).unwrap();
    assert!(good.contains("# mog-description:"));
}

/// Fish file with existing comments should preserve them.
#[test]
fn existing_comments_preserved() {
    let tmp = TempDir::new().unwrap();
    let original = "# Custom header comment\n# Another comment\ncomplete -c myapp -s h -d 'help'\n";
    fs::write(tmp.path().join("myapp.fish"), original).unwrap();

    let output = Command::new(bin())
        .args(["batch", "--dir", tmp.path().to_str().unwrap(), "--engine", "mock"])
        .output()
        .unwrap();

    assert!(output.status.success());

    let annotated = fs::read_to_string(tmp.path().join("myapp.fish")).unwrap();
    assert!(annotated.contains("# mog-description:"), "missing annotation");
    assert!(annotated.contains(original), "original content not preserved");
}
