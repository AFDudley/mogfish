// Layer 5 acceptance tests — MCP server
//
// The MCP server exposes mogfish capabilities over JSON-RPC:
// - Query annotated commands by filter
// - Classify user input
// - Store/retrieve skills
//
// Tests use the server as a library (no subprocess), calling
// handlers directly with JSON request objects.
//
// See docs/plans/mogfish-outside-in-tdd.md, Layer 5

use serde_json::{json, Value};
use tempfile::TempDir;

/// List available tools — MCP initialize handshake.
#[test]
fn list_tools() {
    let tmp = TempDir::new().unwrap();
    let server = mogfish_mcp::MogfishMcp::new(tmp.path(), &["git", "ls"]).unwrap();

    let tools = server.list_tools();
    assert!(!tools.is_empty(), "should expose at least one tool");

    let names: Vec<&str> = tools.iter().map(|t| t.name.as_str()).collect();
    assert!(names.contains(&"classify_input"), "missing classify_input tool");
    assert!(names.contains(&"store_skill"), "missing store_skill tool");
    assert!(names.contains(&"get_skill"), "missing get_skill tool");
    assert!(names.contains(&"annotate_completions"), "missing annotate_completions tool");
}

/// Classify input via MCP tool call.
#[test]
fn classify_input_tool() {
    let tmp = TempDir::new().unwrap();
    let server = mogfish_mcp::MogfishMcp::new(tmp.path(), &["git", "ls"]).unwrap();

    let result = server.call_tool("classify_input", json!({"input": "git status"})).unwrap();
    let category = result["category"].as_str().unwrap();
    assert_eq!(category, "KnownCommand");
    assert_eq!(result["command"].as_str().unwrap(), "git");
}

/// Store and retrieve a skill via MCP.
#[test]
fn store_and_get_skill() {
    let tmp = TempDir::new().unwrap();
    let server = mogfish_mcp::MogfishMcp::new(tmp.path(), &[]).unwrap();

    // Store
    let store_result = server.call_tool("store_skill", json!({
        "intent": "find big files",
        "mog_script": "fs.find(\".\", size > 100mb)",
        "dependencies": ["find"]
    })).unwrap();
    assert_eq!(store_result["status"].as_str().unwrap(), "stored");

    // Retrieve
    let get_result = server.call_tool("get_skill", json!({
        "intent": "find big files"
    })).unwrap();
    assert_eq!(get_result["intent"].as_str().unwrap(), "find big files");
    assert_eq!(get_result["mog_script"].as_str().unwrap(), "fs.find(\".\", size > 100mb)");
}

/// Annotate completions via MCP tool call.
#[test]
fn annotate_completions_tool() {
    let tmp = TempDir::new().unwrap();
    let completions_dir = tmp.path().join("completions");
    std::fs::create_dir(&completions_dir).unwrap();
    std::fs::write(
        completions_dir.join("test.fish"),
        "complete -c test -s h -d 'help'\n",
    ).unwrap();

    let server = mogfish_mcp::MogfishMcp::new(tmp.path(), &[]).unwrap();

    let result = server.call_tool("annotate_completions", json!({
        "dir": completions_dir.to_str().unwrap()
    })).unwrap();

    assert!(result["annotated"].as_u64().unwrap() >= 1);

    let content = std::fs::read_to_string(completions_dir.join("test.fish")).unwrap();
    assert!(content.contains("# mog-description:"));
}

/// Unknown tool returns error.
#[test]
fn unknown_tool_returns_error() {
    let tmp = TempDir::new().unwrap();
    let server = mogfish_mcp::MogfishMcp::new(tmp.path(), &[]).unwrap();

    let result = server.call_tool("nonexistent_tool", json!({}));
    assert!(result.is_err());
}
