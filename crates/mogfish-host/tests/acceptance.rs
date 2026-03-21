// Acceptance tests for mogfish-host capability implementations.
//
// Each test calls a capability function through the host and asserts
// the result matches running the real CLI tool. These tests define
// the contract between .mogdecl declarations and host implementations.
//
// ALL TESTS SHOULD FAIL until the host runtime is implemented.

use std::process::Command;

use tempfile::TempDir;

// ============================================================================
// Test infrastructure
// ============================================================================

/// Call a capability function through the host runtime.
/// Returns the string output.
///
/// This is the function that doesn't exist yet — all tests fail here.
fn host_call(capability: &str, function: &str, args: &[&str]) -> anyhow::Result<String> {
    mogfish_host::call(capability, function, args)
}

/// Run a real CLI command and return stdout.
fn real_command(program: &str, args: &[&str]) -> String {
    let output = Command::new(program)
        .args(args)
        .output()
        .unwrap_or_else(|_| panic!("{program} not found"));
    String::from_utf8_lossy(&output.stdout).to_string()
}

// ============================================================================
// git capability
// ============================================================================

#[test]
fn git_status_matches_real() {
    let expected = real_command("git", &["status"]);
    let result = host_call("git", "status", &[]).unwrap();
    assert_eq!(result.trim(), expected.trim());
}

#[test]
fn git_branch_matches_real() {
    let expected = real_command("git", &["branch"]);
    let result = host_call("git", "branch", &[]).unwrap();
    assert_eq!(result.trim(), expected.trim());
}

#[test]
fn git_log_returns_output() {
    let result = host_call("git", "log", &["--oneline -5"]).unwrap();
    assert!(!result.is_empty(), "git log should produce output");
}

// ============================================================================
// grep capability
// ============================================================================

#[test]
fn grep_search_finds_pattern() {
    let tmp = TempDir::new().unwrap();
    let file = tmp.path().join("test.txt");
    std::fs::write(&file, "hello world\nfoo bar\nhello again\n").unwrap();

    let result = host_call("grep", "search", &["hello", file.to_str().unwrap()]).unwrap();
    assert!(result.contains("hello world"));
    assert!(result.contains("hello again"));
    assert!(!result.contains("foo bar"));
}

#[test]
fn grep_count_matches() {
    let tmp = TempDir::new().unwrap();
    let file = tmp.path().join("test.txt");
    std::fs::write(&file, "aaa\nbbb\naaa\nccc\naaa\n").unwrap();

    let result = host_call("grep", "count", &["aaa", file.to_str().unwrap()]).unwrap();
    assert_eq!(result.trim(), "3");
}

// ============================================================================
// find capability
// ============================================================================

#[test]
fn find_by_name_discovers_files() {
    let tmp = TempDir::new().unwrap();
    std::fs::write(tmp.path().join("foo.txt"), "").unwrap();
    std::fs::write(tmp.path().join("bar.txt"), "").unwrap();
    std::fs::write(tmp.path().join("foo.rs"), "").unwrap();

    let result = host_call("find", "by_name", &["*.txt", tmp.path().to_str().unwrap()]).unwrap();
    assert!(result.contains("foo.txt"));
    assert!(result.contains("bar.txt"));
    assert!(!result.contains("foo.rs"));
}

// ============================================================================
// sed capability
// ============================================================================

#[test]
fn sed_substitute_replaces_first() {
    let result = host_call("sed", "substitute", &["foo", "bar", "foo baz foo"]).unwrap();
    assert_eq!(result.trim(), "bar baz foo");
}

#[test]
fn sed_substitute_all_replaces_all() {
    let result = host_call("sed", "substitute_all", &["foo", "bar", "foo baz foo"]).unwrap();
    assert_eq!(result.trim(), "bar baz bar");
}

#[test]
fn sed_delete_matching_removes_lines() {
    let input = "keep this\ndelete this\nkeep that";
    let result = host_call("sed", "delete_matching", &["delete", input]).unwrap();
    assert!(result.contains("keep this"));
    assert!(result.contains("keep that"));
    assert!(!result.contains("delete this"));
}

// ============================================================================
// awk capability
// ============================================================================

#[test]
fn awk_field_extracts_column() {
    let input = "alice 95\nbob 87\ncarol 92";
    let result = host_call("awk", "field", &["2", " ", input]).unwrap();
    assert!(result.contains("95"));
    assert!(result.contains("87"));
    assert!(result.contains("92"));
}

#[test]
fn awk_count_matching_counts() {
    let input = "error: something\ninfo: ok\nerror: another\ninfo: fine";
    let result = host_call("awk", "count_matching", &["error", input]).unwrap();
    assert_eq!(result.trim(), "2");
}

// ============================================================================
// jq capability
// ============================================================================

#[test]
fn jq_query_extracts_field() {
    let json = r#"{"name": "mogfish", "version": 1}"#;
    let result = host_call("jq", "query", &[".name", json]).unwrap();
    assert_eq!(result.trim().trim_matches('"'), "mogfish");
}

#[test]
fn jq_keys_lists_keys() {
    let json = r#"{"a": 1, "b": 2, "c": 3}"#;
    let result = host_call("jq", "keys", &[json]).unwrap();
    assert!(result.contains("a"));
    assert!(result.contains("b"));
    assert!(result.contains("c"));
}

// ============================================================================
// python3 capability
// ============================================================================

#[test]
fn python3_eval_expression() {
    let result = host_call("python3", "eval", &["2 + 2"]).unwrap();
    assert_eq!(result.trim(), "4");
}

#[test]
fn python3_exec_code() {
    let result = host_call("python3", "exec", &["print('hello from python')"]).unwrap();
    assert_eq!(result.trim(), "hello from python");
}

// ============================================================================
// cargo capability
// ============================================================================

#[test]
fn cargo_check_returns_exit_code() {
    // Run cargo check on the mogfish workspace
    let workspace = env!("CARGO_MANIFEST_DIR")
        .strip_suffix("/crates/mogfish-host")
        .unwrap_or(env!("CARGO_MANIFEST_DIR"));
    let result = host_call("cargo", "check", &[workspace]).unwrap();
    // Should return "0" for a workspace that compiles
    assert!(
        result.trim() == "0" || result.contains("Finished"),
        "cargo check should succeed on mogfish workspace, got: {result}"
    );
}

// ============================================================================
// curl capability (needs network — may skip in CI)
// ============================================================================

#[test]
fn curl_get_returns_response() {
    // Use a reliable endpoint
    let result = host_call("curl", "get", &["https://httpbin.org/get"]);
    match result {
        Ok(body) => assert!(body.contains("httpbin.org") || body.contains("headers")),
        Err(_) => eprintln!("curl test skipped — no network"),
    }
}

// ============================================================================
// Allowlist enforcement
// ============================================================================

#[test]
fn unknown_capability_rejected() {
    let result = host_call("evil", "rm_rf", &["/"]);
    assert!(result.is_err(), "unknown capability should be rejected");
}

#[test]
fn unknown_function_rejected() {
    let result = host_call("git", "format_hard_drive", &[]);
    assert!(result.is_err(), "unknown function should be rejected");
}
