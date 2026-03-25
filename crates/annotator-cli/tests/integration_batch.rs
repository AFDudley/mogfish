// Integration test: batch annotation with a real model.
//
// This test exercises the real mogfish-annotate CLI with a real LLM engine
// (mistralrs). It validates output quality — not just "did it run."
//
// Gated behind `MOGFISH_TEST_MODEL` env var and `#[ignore]`.
// Run with:
//   MOGFISH_TEST_MODEL=/path/to/model MOGFISH_USE_GPU=1 \
//     cargo test -p mogfish-annotator-cli -- --ignored --test-threads=1

use std::collections::HashMap;
use std::fs;
use std::path::Path;
use std::process::Command;

use tempfile::TempDir;

/// Fish completion files to test, in roughly ascending size order.
/// If a file doesn't exist, we try alternatives from the same directory.
const PRIMARY_FILES: &[&str] = &[
    "cat.fish",  // ~1KB
    "grep.fish", // ~4KB
    "ls.fish",   // ~10KB
    "curl.fish", // ~20KB
    "git.fish",  // ~246KB
];

const FALLBACK_FILES: &[&str] = &[
    "true.fish",
    "cd.fish",
    "cp.fish",
    "rm.fish",
    "mv.fish",
    "sed.fish",
    "awk.fish",
    "tar.fish",
    "ssh.fish",
    "make.fish",
];

fn fish_completions_dir() -> std::path::PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap()
        .parent()
        .unwrap()
        .join("fish/share/completions")
}

/// Set up a temp dir with 5 fish completion files.
fn setup_batch_dir() -> TempDir {
    let tmp = TempDir::new().expect("create temp dir");
    let src_dir = fish_completions_dir();

    let mut copied = 0usize;

    // Try primary files first
    for name in PRIMARY_FILES {
        let src = src_dir.join(name);
        if src.exists() {
            fs::copy(&src, tmp.path().join(name)).expect("copy completion file");
            copied += 1;
        }
    }

    // Fill remaining slots from fallbacks
    if copied < 5 {
        for name in FALLBACK_FILES {
            if copied >= 5 {
                break;
            }
            let src = src_dir.join(name);
            if src.exists() && !tmp.path().join(name).exists() {
                fs::copy(&src, tmp.path().join(name)).expect("copy fallback file");
                copied += 1;
            }
        }
    }

    assert!(
        copied >= 3,
        "need at least 3 .fish files for batch integration test, got {copied}"
    );

    tmp
}

/// Detect degenerate/repetitive output.
///
/// If any single whitespace-delimited token accounts for more than 50% of all
/// tokens in the string, the content is considered garbage.
fn is_degenerate(text: &str) -> bool {
    let tokens: Vec<&str> = text.split_whitespace().collect();
    if tokens.len() < 3 {
        // Too short to judge — not degenerate
        return false;
    }

    let mut counts: HashMap<&str, usize> = HashMap::new();
    for t in &tokens {
        *counts.entry(t).or_default() += 1;
    }

    let max_count = counts.values().copied().max().unwrap_or(0);
    let threshold = tokens.len() / 2;
    max_count > threshold
}

/// Run mogfish-annotate batch with the real mistralrs engine.
///
/// Requires `MOGFISH_TEST_MODEL` to point at a model directory.
/// Optionally set `MOGFISH_USE_GPU=1` to enable GPU inference.
#[test]
#[ignore]
fn batch_annotate_real_model_quality() {
    let model_path = std::env::var("MOGFISH_TEST_MODEL")
        .expect("MOGFISH_TEST_MODEL must be set to run this test");

    let use_gpu = std::env::var("MOGFISH_USE_GPU").unwrap_or_else(|_| "0".to_string());

    let tmp = setup_batch_dir();

    // Snapshot original file contents
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

    assert!(
        originals.len() >= 3,
        "expected at least 3 .fish files, got {}",
        originals.len()
    );

    // Run the CLI with real engine
    let bin = env!("CARGO_BIN_EXE_mogfish-annotate");
    let output = Command::new(bin)
        .args([
            "batch",
            "--dir",
            tmp.path().to_str().unwrap(),
            "--engine",
            "mistralrs",
        ])
        .env("MOGFISH_MODEL_PATH", &model_path)
        .env("MOGFISH_USE_GPU", &use_gpu)
        .output()
        .expect("failed to execute mogfish-annotate");

    assert!(
        output.status.success(),
        "mogfish-annotate batch failed:\nstdout: {}\nstderr: {}",
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr),
    );

    let end_marker = "# --- end mog annotations ---";

    // Validate EACH output file
    let mut pass_count = 0usize;
    let mut failures: Vec<String> = Vec::new();

    for (name, original_content) in &originals {
        let annotated = fs::read_to_string(tmp.path().join(name))
            .unwrap_or_else(|_| panic!("failed to read annotated {name}"));

        // --- Check 1: contains # mog-description: with non-empty content ---
        let description = annotated
            .lines()
            .find(|l| l.starts_with("# mog-description:"))
            .map(|l| l.trim_start_matches("# mog-description:").trim());

        match description {
            None => {
                failures.push(format!("{name}: missing # mog-description: line"));
                continue;
            }
            Some(d) if d.is_empty() => {
                failures.push(format!("{name}: # mog-description: is empty"));
                continue;
            }
            Some(_) => {}
        }
        let description_text = description.unwrap();

        // --- Check 2: contains at least one # mog-intent: line ---
        let intent_lines: Vec<&str> = annotated
            .lines()
            .filter(|l| l.starts_with("# mog-intent:"))
            .collect();

        if intent_lines.is_empty() {
            failures.push(format!("{name}: missing # mog-intent: line(s)"));
            continue;
        }

        // --- Check 3: description is not degenerate ---
        if is_degenerate(description_text) {
            failures.push(format!(
                "{name}: degenerate description (repetitive tokens): {description_text}"
            ));
            continue;
        }

        // Check intent values are not degenerate either
        let mut intent_ok = true;
        for line in &intent_lines {
            let value = line.trim_start_matches("# mog-intent:").trim();
            if value.is_empty() {
                failures.push(format!("{name}: empty # mog-intent: value"));
                intent_ok = false;
                break;
            }
            if is_degenerate(value) {
                failures.push(format!(
                    "{name}: degenerate intent (repetitive tokens): {value}"
                ));
                intent_ok = false;
                break;
            }
        }
        if !intent_ok {
            continue;
        }

        // --- Check 4: original fish content preserved after end marker ---
        if let Some(marker_pos) = annotated.find(end_marker) {
            let after_marker = &annotated[marker_pos + end_marker.len()..];
            // Strip leading newlines after marker
            let after_marker = after_marker.trim_start_matches('\n');

            assert!(
                after_marker.contains(original_content.trim()),
                "{name}: original content not preserved after end marker.\n\
                 After marker starts with: {:?}",
                &after_marker[..after_marker.len().min(200)]
            );
        } else {
            failures.push(format!("{name}: missing end marker '{end_marker}'"));
            continue;
        }

        pass_count += 1;
    }

    // ALL files must pass quality checks
    assert!(
        failures.is_empty(),
        "batch annotation quality failures ({pass_count}/{} passed):\n{}",
        originals.len(),
        failures.join("\n"),
    );

    assert_eq!(
        pass_count,
        originals.len(),
        "expected all {0} files to pass quality checks, got {pass_count}/{0}",
        originals.len(),
    );
}

#[test]
fn is_degenerate_detects_repetition() {
    assert!(is_degenerate("the the the the the foo"));
    assert!(!is_degenerate("Generate completions for the cat command"));
    assert!(!is_degenerate("short"));
    assert!(!is_degenerate(""));
}
