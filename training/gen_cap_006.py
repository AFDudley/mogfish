#!/usr/bin/env python3
"""Generate Mog translations from cap_batch_006.jsonl."""

import json
import subprocess
import sys
import os
import re

MOGC = "/home/rix/.exophial/dc/mogfish/mog/compiler/target/release/mogc"
VALIDATE_DIR = "/home/rix/.exophial/dc/mogfish/training/validate_env"
OUTPUT_FILE = "/home/rix/.exophial/dc/mogfish/training/cap_translations_006.jsonl"
INPUT_FILE = "/home/rix/.exophial/dc/mogfish/training/cap_batch_006.jsonl"


def validate_mog(code: str) -> bool:
    """Write code to test.mog and compile, return True if exit 0."""
    test_path = os.path.join(VALIDATE_DIR, "test.mog")
    with open(test_path, "w") as f:
        f.write(code)
    result = subprocess.run(
        [MOGC, test_path, "--emit-ir"],
        capture_output=True,
        timeout=10,
    )
    return result.returncode == 0


def emit(out, description: str, code: str) -> bool:
    if validate_mog(code):
        entry = {
            "instruction": "Generate a Mog script for this task",
            "input": description,
            "output": code,
        }
        out.write(json.dumps(entry) + "\n")
        return True
    return False


def gen_git_translations(out):
    """Generate git-related Mog translations."""
    templates = [
        # git status
        ("Show git working tree status", """requires git;
async fn main() -> i64 {
  status: string = git.status();
  println(status);
  return 0;
}"""),
        # git diff
        ("Show git diff of uncommitted changes", """requires git;
async fn main() -> i64 {
  diff: string = git.diff();
  println(diff);
  return 0;
}"""),
        # git log
        ("Show recent git commit history", """requires git;
async fn main() -> i64 {
  history: string = git.log("--oneline -10");
  println(history);
  return 0;
}"""),
        ("Show last 5 git commits", """requires git;
async fn main() -> i64 {
  history: string = git.log("--oneline -5");
  println(history);
  return 0;
}"""),
        ("Show git log with graph", """requires git;
async fn main() -> i64 {
  history: string = git.log("--oneline --graph -20");
  println(history);
  return 0;
}"""),
        ("Show git log for a specific file", """requires git;
async fn main() -> i64 {
  history: string = git.log("--oneline -10 -- src/main.rs");
  println(history);
  return 0;
}"""),
        # git branch
        ("List git branches", """requires git;
async fn main() -> i64 {
  branches: string = git.branch();
  println(branches);
  return 0;
}"""),
        ("Show current git branch", """requires git;
async fn main() -> i64 {
  branches: string = git.branch();
  println(branches);
  return 0;
}"""),
        # git add + commit
        ("Stage a file and commit with a message", """requires git;
async fn main() -> i64 {
  git.add("src/main.rs");
  result: string = git.commit("Fix compilation error in main");
  println(result);
  return 0;
}"""),
        ("Stage all changes and commit", """requires git;
async fn main() -> i64 {
  git.add(".");
  result: string = git.commit("Update project files");
  println(result);
  return 0;
}"""),
        ("Stage and commit a configuration file", """requires git;
async fn main() -> i64 {
  git.add("config.toml");
  result: string = git.commit("Update configuration settings");
  println(result);
  return 0;
}"""),
        # git checkout
        ("Switch to the main branch", """requires git;
async fn main() -> i64 {
  git.checkout("main");
  status: string = git.status();
  println(status);
  return 0;
}"""),
        ("Switch to a feature branch", """requires git;
async fn main() -> i64 {
  git.checkout("feature/new-api");
  status: string = git.status();
  println(status);
  return 0;
}"""),
        ("Create and switch to a new branch", """requires git;
async fn main() -> i64 {
  git.checkout("-b feature/auth-refactor");
  branches: string = git.branch();
  println(branches);
  return 0;
}"""),
        # git merge
        ("Merge a branch into current branch", """requires git;
async fn main() -> i64 {
  result: string = git.merge("feature/new-api");
  println(result);
  return 0;
}"""),
        ("Merge main into current branch", """requires git;
async fn main() -> i64 {
  result: string = git.merge("main");
  println(result);
  return 0;
}"""),
        # git rebase
        ("Rebase current branch onto main", """requires git;
async fn main() -> i64 {
  result: string = git.rebase("main");
  println(result);
  return 0;
}"""),
        ("Rebase onto upstream/main", """requires git;
async fn main() -> i64 {
  result: string = git.rebase("upstream/main");
  println(result);
  return 0;
}"""),
        # git stash
        ("Stash current changes", """requires git;
async fn main() -> i64 {
  result: string = git.stash("push");
  println(result);
  return 0;
}"""),
        ("Pop the latest stash", """requires git;
async fn main() -> i64 {
  result: string = git.stash("pop");
  println(result);
  return 0;
}"""),
        ("List all stashes", """requires git;
async fn main() -> i64 {
  result: string = git.stash("list");
  println(result);
  return 0;
}"""),
        # git push
        ("Push current branch to origin", """requires git;
async fn main() -> i64 {
  result: string = await git.push("origin", "main");
  println(result);
  return 0;
}"""),
        ("Push feature branch to origin", """requires git;
async fn main() -> i64 {
  result: string = await git.push("origin", "feature/new-api");
  println(result);
  return 0;
}"""),
        # git pull
        ("Pull latest changes from origin main", """requires git;
async fn main() -> i64 {
  result: string = await git.pull("origin", "main");
  println(result);
  return 0;
}"""),
        ("Pull from upstream main", """requires git;
async fn main() -> i64 {
  result: string = await git.pull("upstream", "main");
  println(result);
  return 0;
}"""),
        # Compound git workflows
        ("Check status, stage changes, and commit", """requires git;
async fn main() -> i64 {
  status: string = git.status();
  println(status);
  git.add(".");
  result: string = git.commit("Apply formatting fixes");
  println(result);
  return 0;
}"""),
        ("Pull latest, check diff, then commit", """requires git;
async fn main() -> i64 {
  await git.pull("origin", "main");
  diff: string = git.diff();
  println(diff);
  return 0;
}"""),
        ("Stash changes, switch branch, pop stash", """requires git;
async fn main() -> i64 {
  git.stash("push");
  git.checkout("feature/hotfix");
  git.stash("pop");
  status: string = git.status();
  println(status);
  return 0;
}"""),
        ("Show git log with author filter", """requires git;
async fn main() -> i64 {
  history: string = git.log("--oneline --author=rix -10");
  println(history);
  return 0;
}"""),
        ("Show commits since yesterday", """requires git;
async fn main() -> i64 {
  history: string = git.log("--oneline --since=yesterday");
  println(history);
  return 0;
}"""),
    ]
    count = 0
    for desc, code in templates:
        if emit(out, desc, code):
            count += 1
        else:
            print(f"  FAIL: {desc}", file=sys.stderr)
    return count


def gen_grep_translations(out):
    """Generate grep-related Mog translations."""
    templates = [
        ("Search for a pattern in a file", """requires grep;
async fn main() -> i64 {
  matches: string = grep.search("TODO", "src/main.rs");
  println(matches);
  return 0;
}"""),
        ("Search for function definitions in a file", """requires grep;
async fn main() -> i64 {
  matches: string = grep.search("fn ", "src/lib.rs");
  println(matches);
  return 0;
}"""),
        ("Search for error handling patterns", """requires grep;
async fn main() -> i64 {
  matches: string = grep.search("unwrap\\(\\)", "src/main.rs");
  println(matches);
  return 0;
}"""),
        ("Recursively search a directory for a pattern", """requires grep;
async fn main() -> i64 {
  matches: string = await grep.search_recursive("TODO", "src/");
  println(matches);
  return 0;
}"""),
        ("Recursively search for import statements", """requires grep;
async fn main() -> i64 {
  matches: string = await grep.search_recursive("import ", "src/");
  println(matches);
  return 0;
}"""),
        ("Recursively search for error messages", """requires grep;
async fn main() -> i64 {
  matches: string = await grep.search_recursive("ERROR", "logs/");
  println(matches);
  return 0;
}"""),
        ("Count occurrences of a pattern in a file", """requires grep;
async fn main() -> i64 {
  count: int = grep.count("TODO", "src/main.rs");
  println(f"Found {count} TODOs");
  return 0;
}"""),
        ("Count test functions in a test file", """requires grep;
async fn main() -> i64 {
  count: int = grep.count("def test_", "tests/test_main.py");
  println(f"Found {count} test functions");
  return 0;
}"""),
        ("Find files containing a pattern", """requires grep;
async fn main() -> i64 {
  files: string = grep.files_matching("class.*Model", "src/");
  println(files);
  return 0;
}"""),
        ("Find files containing database queries", """requires grep;
async fn main() -> i64 {
  files: string = grep.files_matching("SELECT.*FROM", "src/");
  println(files);
  return 0;
}"""),
        ("Search for a fixed string in a file", """requires grep;
async fn main() -> i64 {
  matches: string = grep.search_fixed("config.toml", "src/settings.rs");
  println(matches);
  return 0;
}"""),
        ("Search for literal text without regex", """requires grep;
async fn main() -> i64 {
  matches: string = grep.search_fixed("hello world", "README.md");
  println(matches);
  return 0;
}"""),
        ("Find lines NOT matching a pattern", """requires grep;
async fn main() -> i64 {
  non_matches: string = grep.invert_match("^#", "config.ini");
  println(non_matches);
  return 0;
}"""),
        ("Show non-comment lines in a config file", """requires grep;
async fn main() -> i64 {
  lines: string = grep.invert_match("^//", "src/config.rs");
  println(lines);
  return 0;
}"""),
        ("Search with line numbers", """requires grep;
async fn main() -> i64 {
  matches: string = grep.search_numbered("panic!", "src/main.rs");
  println(matches);
  return 0;
}"""),
        ("Find numbered lines containing a keyword", """requires grep;
async fn main() -> i64 {
  matches: string = grep.search_numbered("async fn", "src/server.rs");
  println(matches);
  return 0;
}"""),
        ("Search for pattern and count matches in multiple steps", """requires grep;
async fn main() -> i64 {
  matches: string = grep.search("warn", "app.log");
  count: int = grep.count("warn", "app.log");
  println(f"Warnings ({count}):");
  println(matches);
  return 0;
}"""),
        ("Find files with errors and show matching lines", """requires grep;
async fn main() -> i64 {
  files: string = grep.files_matching("Error", "src/");
  println("Files with errors:");
  println(files);
  return 0;
}"""),
    ]
    count = 0
    for desc, code in templates:
        if emit(out, desc, code):
            count += 1
        else:
            print(f"  FAIL: {desc}", file=sys.stderr)
    return count


def gen_find_translations(out):
    """Generate find-related Mog translations."""
    templates = [
        ("Find all Rust source files", """requires find;
async fn main() -> i64 {
  files: string = await find.by_name("*.rs", "src/");
  println(files);
  return 0;
}"""),
        ("Find all Python files in a directory", """requires find;
async fn main() -> i64 {
  files: string = await find.by_name("*.py", ".");
  println(files);
  return 0;
}"""),
        ("Find all YAML config files", """requires find;
async fn main() -> i64 {
  files: string = await find.by_name("*.yml", "config/");
  println(files);
  return 0;
}"""),
        ("Find all JSON files", """requires find;
async fn main() -> i64 {
  files: string = await find.by_name("*.json", ".");
  println(files);
  return 0;
}"""),
        ("Find all Markdown documentation files", """requires find;
async fn main() -> i64 {
  files: string = await find.by_name("*.md", "docs/");
  println(files);
  return 0;
}"""),
        ("Find all directories in a path", """requires find;
async fn main() -> i64 {
  dirs: string = await find.by_type("d", "src/");
  println(dirs);
  return 0;
}"""),
        ("Find all regular files in current directory", """requires find;
async fn main() -> i64 {
  files: string = await find.by_type("f", ".");
  println(files);
  return 0;
}"""),
        ("Find all symlinks", """requires find;
async fn main() -> i64 {
  links: string = await find.by_type("l", ".");
  println(links);
  return 0;
}"""),
        ("Find large files over 10MB", """requires find;
async fn main() -> i64 {
  files: string = await find.by_min_size(10485760, ".");
  println(files);
  return 0;
}"""),
        ("Find large files over 100MB", """requires find;
async fn main() -> i64 {
  files: string = await find.by_min_size(104857600, "/var/log/");
  println(files);
  return 0;
}"""),
        ("Find small files under 1KB", """requires find;
async fn main() -> i64 {
  files: string = await find.by_max_size(1024, "src/");
  println(files);
  return 0;
}"""),
        ("Find files modified in the last hour", """requires find;
async fn main() -> i64 {
  files: string = await find.modified_within(3600, ".");
  println(files);
  return 0;
}"""),
        ("Find files modified in the last 5 minutes", """requires find;
async fn main() -> i64 {
  files: string = await find.modified_within(300, "src/");
  println(files);
  return 0;
}"""),
        ("Find files modified in the last day", """requires find;
async fn main() -> i64 {
  files: string = await find.modified_within(86400, ".");
  println(files);
  return 0;
}"""),
        ("Find files not modified in the last week", """requires find;
async fn main() -> i64 {
  files: string = await find.modified_before(604800, "logs/");
  println(files);
  return 0;
}"""),
        ("Find old log files", """requires find;
async fn main() -> i64 {
  files: string = await find.modified_before(2592000, "/var/log/");
  println(files);
  return 0;
}"""),
        ("Find Python files that are regular files", """requires find;
async fn main() -> i64 {
  files: string = await find.by_name_and_type("*.py", "f", "src/");
  println(files);
  return 0;
}"""),
        ("Find test directories", """requires find;
async fn main() -> i64 {
  dirs: string = await find.by_name_and_type("test*", "d", ".");
  println(dirs);
  return 0;
}"""),
        ("Find Dockerfile files", """requires find;
async fn main() -> i64 {
  files: string = await find.by_name_and_type("Dockerfile*", "f", ".");
  println(files);
  return 0;
}"""),
        ("Count Rust source files", """requires find;
async fn main() -> i64 {
  count: int = await find.count("*.rs", "src/");
  println(f"Found {count} Rust files");
  return 0;
}"""),
        ("Count Python test files", """requires find;
async fn main() -> i64 {
  count: int = await find.count("test_*.py", "tests/");
  println(f"Found {count} test files");
  return 0;
}"""),
        ("Count TOML configuration files", """requires find;
async fn main() -> i64 {
  count: int = await find.count("*.toml", ".");
  println(f"Found {count} TOML files");
  return 0;
}"""),
    ]
    count = 0
    for desc, code in templates:
        if emit(out, desc, code):
            count += 1
        else:
            print(f"  FAIL: {desc}", file=sys.stderr)
    return count


def gen_fs_translations(out):
    """Generate fs-related Mog translations."""
    templates = [
        ("Read a configuration file", """requires fs;
async fn main() -> i64 {
  contents: string = await fs.read_file("config.toml");
  println(contents);
  return 0;
}"""),
        ("Read a log file", """requires fs;
async fn main() -> i64 {
  contents: string = await fs.read_file("/var/log/app.log");
  println(contents);
  return 0;
}"""),
        ("Write text to a file", """requires fs;
async fn main() -> i64 {
  await fs.write_file("output.txt", "Hello, World!");
  println("File written successfully");
  return 0;
}"""),
        ("Write JSON data to a file", """requires fs;
async fn main() -> i64 {
  await fs.write_file("data.json", "{\"name\": \"test\", \"value\": 42}");
  println("JSON written");
  return 0;
}"""),
        ("Append a log entry to a file", """requires fs;
async fn main() -> i64 {
  await fs.append_file("app.log", "INFO: Application started\n");
  println("Log entry appended");
  return 0;
}"""),
        ("Append multiple lines to a file", """requires fs;
async fn main() -> i64 {
  await fs.append_file("notes.txt", "Line 1\n");
  await fs.append_file("notes.txt", "Line 2\n");
  await fs.append_file("notes.txt", "Line 3\n");
  println("Lines appended");
  return 0;
}"""),
        ("Check if a file exists", """requires fs;
async fn main() -> i64 {
  exists: bool = await fs.exists("config.toml");
  if exists {
    println("Config file exists");
  } else {
    println("Config file not found");
  }
  return 0;
}"""),
        ("Check if a log directory exists", """requires fs;
async fn main() -> i64 {
  exists: bool = await fs.exists("/var/log/app/");
  if exists {
    println("Log directory exists");
  } else {
    println("Log directory not found");
  }
  return 0;
}"""),
        ("Delete a temporary file", """requires fs;
async fn main() -> i64 {
  await fs.remove("/tmp/temp_output.txt");
  println("Temporary file removed");
  return 0;
}"""),
        ("Get the size of a file", """requires fs;
async fn main() -> i64 {
  size: int = await fs.file_size("data.bin");
  println(f"File size: {size} bytes");
  return 0;
}"""),
        ("Get file size in kilobytes", """requires fs;
async fn main() -> i64 {
  size: int = await fs.file_size("archive.tar.gz");
  kb: int = size / 1024;
  println(f"File size: {kb} KB");
  return 0;
}"""),
        ("Read a file, modify content, and write it back", """requires fs;
requires sed;
async fn main() -> i64 {
  contents: string = await fs.read_file("config.ini");
  modified: string = sed.substitute_all("localhost", "production.server.com", contents);
  await fs.write_file("config.ini", modified);
  println("Config updated");
  return 0;
}"""),
        ("Copy a file by reading and writing", """requires fs;
async fn main() -> i64 {
  contents: string = await fs.read_file("source.txt");
  await fs.write_file("backup.txt", contents);
  println("File copied");
  return 0;
}"""),
        ("Create a file only if it does not exist", """requires fs;
async fn main() -> i64 {
  exists: bool = await fs.exists("settings.json");
  if !exists {
    await fs.write_file("settings.json", "{\"debug\": false}");
    println("Created default settings");
  } else {
    println("Settings already exist");
  }
  return 0;
}"""),
        ("Write and verify a file round-trip", """requires fs;
async fn main() -> i64 {
  await fs.write_file("/tmp/test.txt", "test data");
  contents: string = await fs.read_file("/tmp/test.txt");
  println(f"Read back: {contents}");
  await fs.remove("/tmp/test.txt");
  return 0;
}"""),
    ]
    count = 0
    for desc, code in templates:
        if emit(out, desc, code):
            count += 1
        else:
            print(f"  FAIL: {desc}", file=sys.stderr)
    return count


def gen_curl_translations(out):
    """Generate curl/http-related Mog translations."""
    templates = [
        ("Fetch a web page", """requires curl;
async fn main() -> i64 {
  body: string = await curl.get("https://example.com");
  println(body);
  return 0;
}"""),
        ("Check API health endpoint", """requires curl;
async fn main() -> i64 {
  response: string = await curl.get("http://localhost:8080/health");
  println(response);
  return 0;
}"""),
        ("Fetch JSON from an API", """requires curl;
async fn main() -> i64 {
  response: string = await curl.get("https://api.example.com/data");
  println(response);
  return 0;
}"""),
        ("Post JSON data to an API", """requires curl;
async fn main() -> i64 {
  body: string = "{\"name\": \"test\", \"value\": 42}";
  response: string = await curl.post("https://api.example.com/items", body);
  println(response);
  return 0;
}"""),
        ("Post form data to an endpoint", """requires curl;
async fn main() -> i64 {
  response: string = await curl.post("https://api.example.com/login", "username=admin&password=secret");
  println(response);
  return 0;
}"""),
        ("Update a resource with PUT", """requires curl;
async fn main() -> i64 {
  body: string = "{\"status\": \"active\"}";
  response: string = await curl.put("https://api.example.com/items/1", body);
  println(response);
  return 0;
}"""),
        ("Delete a resource", """requires curl;
async fn main() -> i64 {
  response: string = await curl.delete("https://api.example.com/items/1");
  println(response);
  return 0;
}"""),
        ("Download a file from URL", """requires curl;
async fn main() -> i64 {
  bytes: int = await curl.download("https://example.com/data.csv", "/tmp/data.csv");
  println(f"Downloaded {bytes} bytes");
  return 0;
}"""),
        ("Download a binary artifact", """requires curl;
async fn main() -> i64 {
  bytes: int = await curl.download("https://releases.example.com/v1.0/app.tar.gz", "/tmp/app.tar.gz");
  println(f"Downloaded {bytes} bytes");
  return 0;
}"""),
        ("GET with authorization header", """requires curl;
async fn main() -> i64 {
  response: string = await curl.get_with_header("https://api.example.com/private", "Authorization: Bearer token123");
  println(response);
  return 0;
}"""),
        ("GET with custom content type header", """requires curl;
async fn main() -> i64 {
  response: string = await curl.get_with_header("https://api.example.com/data", "Accept: application/json");
  println(response);
  return 0;
}"""),
        ("Fetch data and save to file", """requires curl;
requires fs;
async fn main() -> i64 {
  data: string = await curl.get("https://api.example.com/export");
  await fs.write_file("export.json", data);
  println("Data saved to export.json");
  return 0;
}"""),
        ("Use http capability to GET a URL", """requires http;
async fn main() -> i64 {
  response: string = await http.get("https://example.com/api/status");
  println(response);
  return 0;
}"""),
        ("Use http capability to POST data", """requires http;
async fn main() -> i64 {
  response: string = await http.post("https://example.com/api/data", "{\"key\": \"value\"}");
  println(response);
  return 0;
}"""),
    ]
    count = 0
    for desc, code in templates:
        if emit(out, desc, code):
            count += 1
        else:
            print(f"  FAIL: {desc}", file=sys.stderr)
    return count


def gen_docker_translations(out):
    """Generate docker-related Mog translations."""
    templates = [
        ("List running Docker containers", """requires docker;
async fn main() -> i64 {
  containers: string = docker.ps("");
  println(containers);
  return 0;
}"""),
        ("List all Docker containers including stopped", """requires docker;
async fn main() -> i64 {
  containers: string = docker.ps("-a");
  println(containers);
  return 0;
}"""),
        ("Run a Docker container", """requires docker;
async fn main() -> i64 {
  output: string = docker.run("alpine:latest", "echo hello");
  println(output);
  return 0;
}"""),
        ("Run an nginx container in detached mode", """requires docker;
async fn main() -> i64 {
  output: string = docker.run("nginx:latest", "-d -p 8080:80");
  println(output);
  return 0;
}"""),
        ("Execute a command inside a running container", """requires docker;
async fn main() -> i64 {
  output: string = docker.exec("my-container", "ls -la /app");
  println(output);
  return 0;
}"""),
        ("Check environment variables in a container", """requires docker;
async fn main() -> i64 {
  output: string = docker.exec("my-container", "env");
  println(output);
  return 0;
}"""),
        ("View container logs", """requires docker;
async fn main() -> i64 {
  logs: string = docker.logs("my-container");
  println(logs);
  return 0;
}"""),
        ("Stop a running container", """requires docker;
async fn main() -> i64 {
  result: int = docker.stop("my-container");
  println(f"Stop exit code: {result}");
  return 0;
}"""),
        ("Remove a stopped container", """requires docker;
async fn main() -> i64 {
  result: int = docker.rm("my-container");
  println(f"Remove exit code: {result}");
  return 0;
}"""),
        ("Stop and remove a container", """requires docker;
async fn main() -> i64 {
  docker.stop("my-container");
  docker.rm("my-container");
  println("Container stopped and removed");
  return 0;
}"""),
        ("List Docker images", """requires docker;
async fn main() -> i64 {
  images: string = docker.images("");
  println(images);
  return 0;
}"""),
        ("List Docker images with filter", """requires docker;
async fn main() -> i64 {
  images: string = docker.images("--filter dangling=true");
  println(images);
  return 0;
}"""),
        ("Build a Docker image", """requires docker;
async fn main() -> i64 {
  result: string = await docker.build(".", "my-app:latest");
  println(result);
  return 0;
}"""),
        ("Build a Docker image with a custom tag", """requires docker;
async fn main() -> i64 {
  result: string = await docker.build(".", "registry.example.com/my-app:v1.0");
  println(result);
  return 0;
}"""),
    ]
    count = 0
    for desc, code in templates:
        if emit(out, desc, code):
            count += 1
        else:
            print(f"  FAIL: {desc}", file=sys.stderr)
    return count


def gen_gh_translations(out):
    """Generate gh (GitHub CLI) translations."""
    templates = [
        ("Create a GitHub pull request", """requires gh;
async fn main() -> i64 {
  result: string = await gh.pr_create("Fix authentication bug", "Resolves issue with token refresh");
  println(result);
  return 0;
}"""),
        ("Create a PR with detailed description", """requires gh;
async fn main() -> i64 {
  result: string = await gh.pr_create("Add user settings page", "## Summary\n- New settings UI\n- Theme toggle\n- Language selector");
  println(result);
  return 0;
}"""),
        ("List open pull requests", """requires gh;
async fn main() -> i64 {
  prs: string = await gh.pr_list("open");
  println(prs);
  return 0;
}"""),
        ("List closed pull requests", """requires gh;
async fn main() -> i64 {
  prs: string = await gh.pr_list("closed");
  println(prs);
  return 0;
}"""),
        ("List all pull requests", """requires gh;
async fn main() -> i64 {
  prs: string = await gh.pr_list("all");
  println(prs);
  return 0;
}"""),
        ("View a specific pull request", """requires gh;
async fn main() -> i64 {
  pr: string = await gh.pr_view(42);
  println(pr);
  return 0;
}"""),
        ("View pull request number 1", """requires gh;
async fn main() -> i64 {
  pr: string = await gh.pr_view(1);
  println(pr);
  return 0;
}"""),
        ("Create a GitHub issue", """requires gh;
async fn main() -> i64 {
  result: string = await gh.issue_create("Login page broken", "Users cannot log in after the latest deploy");
  println(result);
  return 0;
}"""),
        ("Create a feature request issue", """requires gh;
async fn main() -> i64 {
  result: string = await gh.issue_create("Add dark mode support", "Users have requested dark mode for the application");
  println(result);
  return 0;
}"""),
        ("List open issues", """requires gh;
async fn main() -> i64 {
  issues: string = await gh.issue_list("open");
  println(issues);
  return 0;
}"""),
        ("List closed issues", """requires gh;
async fn main() -> i64 {
  issues: string = await gh.issue_list("closed");
  println(issues);
  return 0;
}"""),
        ("Clone a repository", """requires gh;
async fn main() -> i64 {
  result: int = await gh.repo_clone("octocat/hello-world", "/tmp/hello-world");
  println(f"Clone exit code: {result}");
  return 0;
}"""),
        ("List CI workflow runs", """requires gh;
async fn main() -> i64 {
  runs: string = await gh.run_list("ci.yml");
  println(runs);
  return 0;
}"""),
        ("List test workflow runs", """requires gh;
async fn main() -> i64 {
  runs: string = await gh.run_list("test.yml");
  println(runs);
  return 0;
}"""),
        ("View a specific CI run", """requires gh;
async fn main() -> i64 {
  run: string = await gh.run_view(12345);
  println(run);
  return 0;
}"""),
    ]
    count = 0
    for desc, code in templates:
        if emit(out, desc, code):
            count += 1
        else:
            print(f"  FAIL: {desc}", file=sys.stderr)
    return count


def gen_sed_translations(out):
    """Generate sed-related Mog translations."""
    templates = [
        ("Replace first occurrence of a word in text", """requires sed;
async fn main() -> i64 {
  text: string = "hello world hello";
  result: string = sed.substitute("hello", "hi", text);
  println(result);
  return 0;
}"""),
        ("Replace first match of a pattern", """requires sed;
async fn main() -> i64 {
  text: string = "version: 1.0.0";
  result: string = sed.substitute("1.0.0", "2.0.0", text);
  println(result);
  return 0;
}"""),
        ("Replace all occurrences of a word", """requires sed;
async fn main() -> i64 {
  text: string = "foo bar foo baz foo";
  result: string = sed.substitute_all("foo", "qux", text);
  println(result);
  return 0;
}"""),
        ("Replace all tabs with spaces", """requires sed;
async fn main() -> i64 {
  text: string = "col1\tcol2\tcol3";
  result: string = sed.substitute_all("\t", "  ", text);
  println(result);
  return 0;
}"""),
        ("Delete lines matching a pattern", """requires sed;
async fn main() -> i64 {
  text: string = "keep this\n# comment\nkeep this too\n# another comment";
  result: string = sed.delete_matching("^#", text);
  println(result);
  return 0;
}"""),
        ("Remove blank lines from text", """requires sed;
async fn main() -> i64 {
  text: string = "line1\n\nline2\n\nline3";
  result: string = sed.delete_matching("^$", text);
  println(result);
  return 0;
}"""),
        ("Insert text before matching lines", """requires sed;
async fn main() -> i64 {
  text: string = "section A\ndata\nsection B\ndata";
  result: string = sed.insert_before("section", "---", text);
  println(result);
  return 0;
}"""),
        ("Insert text after matching lines", """requires sed;
async fn main() -> i64 {
  text: string = "[header]\ndata\n[footer]";
  result: string = sed.insert_after("\\[header\\]", "# Auto-generated", text);
  println(result);
  return 0;
}"""),
        ("Extract lines between two patterns", """requires sed;
async fn main() -> i64 {
  text: string = "start\nimportant data\nmore data\nend\nignored";
  result: string = sed.extract_range("start", "end", text);
  println(result);
  return 0;
}"""),
        ("Extract a section from structured text", """requires sed;
async fn main() -> i64 {
  text: string = "BEGIN\nline 1\nline 2\nEND\nextra";
  result: string = sed.extract_range("BEGIN", "END", text);
  println(result);
  return 0;
}"""),
        ("Substitute in a file and show result", """requires sed;
async fn main() -> i64 {
  result: string = sed.substitute_in_file("old_value", "new_value", "config.ini");
  println(result);
  return 0;
}"""),
        ("Replace all occurrences in a file", """requires sed;
async fn main() -> i64 {
  result: string = sed.substitute_all_in_file("localhost", "production.server.com", "config.ini");
  println(result);
  return 0;
}"""),
        ("Update version string in a file", """requires sed;
async fn main() -> i64 {
  result: string = sed.substitute_in_file("0.1.0", "0.2.0", "Cargo.toml");
  println(result);
  return 0;
}"""),
    ]
    count = 0
    for desc, code in templates:
        if emit(out, desc, code):
            count += 1
        else:
            print(f"  FAIL: {desc}", file=sys.stderr)
    return count


def gen_awk_translations(out):
    """Generate awk-related Mog translations."""
    templates = [
        ("Extract a specific column from CSV data", """requires awk;
async fn main() -> i64 {
  data: string = "alice,95,A\nbob,87,B\ncarol,92,A";
  result: string = awk.field(1, ",", data);
  println(result);
  return 0;
}"""),
        ("Extract second field from tab-separated data", """requires awk;
async fn main() -> i64 {
  data: string = "id\tname\tscore\n1\talice\t95\n2\tbob\t87";
  result: string = awk.field(2, "\t", data);
  println(result);
  return 0;
}"""),
        ("Extract multiple columns from CSV", """requires awk;
async fn main() -> i64 {
  data: string = "alice,95,A\nbob,87,B\ncarol,92,A";
  result: string = awk.fields("1,3", ",", data);
  println(result);
  return 0;
}"""),
        ("Filter lines matching a pattern", """requires awk;
async fn main() -> i64 {
  data: string = "alice,95\nbob,87\ncarol,92\nalice,100";
  result: string = awk.filter("alice", data);
  println(result);
  return 0;
}"""),
        ("Filter log lines containing ERROR", """requires awk;
async fn main() -> i64 {
  log: string = "INFO: started\nERROR: failed\nINFO: running\nERROR: timeout";
  result: string = awk.filter("ERROR", log);
  println(result);
  return 0;
}"""),
        ("Sum values in a numeric column", """requires awk;
async fn main() -> i64 {
  data: string = "item1,10\nitem2,20\nitem3,30";
  total: float = awk.sum_field(2, ",", data);
  print_string("Total: ");
  print_f64(total);
  println("");
  return 0;
}"""),
        ("Count lines matching a pattern", """requires awk;
async fn main() -> i64 {
  data: string = "pass\nfail\npass\npass\nfail";
  count: int = awk.count_matching("pass", data);
  println(f"Passing: {count}");
  return 0;
}"""),
        ("Count error lines in a log", """requires awk;
async fn main() -> i64 {
  log: string = "INFO ok\nERROR bad\nINFO ok\nERROR worse\nERROR critical";
  count: int = awk.count_matching("ERROR", log);
  println(f"Errors: {count}");
  return 0;
}"""),
        ("Get unique values from a column", """requires awk;
async fn main() -> i64 {
  data: string = "alice,eng\nbob,sales\ncarol,eng\ndave,sales\neve,eng";
  unique: string = awk.unique_field(2, ",", data);
  println(unique);
  return 0;
}"""),
        ("Count number of fields in a line", """requires awk;
async fn main() -> i64 {
  data: string = "col1,col2,col3,col4,col5";
  count: int = awk.field_count(",", data);
  println(f"Number of columns: {count}");
  return 0;
}"""),
        ("Count fields in tab-separated data", """requires awk;
async fn main() -> i64 {
  data: string = "id\tname\tscore\tgrade";
  count: int = awk.field_count("\t", data);
  println(f"Columns: {count}");
  return 0;
}"""),
    ]
    count = 0
    for desc, code in templates:
        if emit(out, desc, code):
            count += 1
        else:
            print(f"  FAIL: {desc}", file=sys.stderr)
    return count


def gen_jq_translations(out):
    """Generate jq-related Mog translations."""
    templates = [
        ("Query a JSON field", """requires jq;
async fn main() -> i64 {
  json: string = "{\"name\": \"alice\", \"age\": 30}";
  result: string = jq.query(".name", json);
  println(result);
  return 0;
}"""),
        ("Query nested JSON fields", """requires jq;
async fn main() -> i64 {
  json: string = "{\"user\": {\"name\": \"bob\", \"role\": \"admin\"}}";
  result: string = jq.query(".user.name", json);
  println(result);
  return 0;
}"""),
        ("Filter a JSON array by condition", """requires jq;
async fn main() -> i64 {
  json: string = "[{\"name\": \"a\", \"score\": 90}, {\"name\": \"b\", \"score\": 70}]";
  result: string = jq.filter("select(.score > 80)", json);
  println(result);
  return 0;
}"""),
        ("Filter JSON array for active items", """requires jq;
async fn main() -> i64 {
  json: string = "[{\"id\": 1, \"active\": true}, {\"id\": 2, \"active\": false}]";
  result: string = jq.filter("select(.active == true)", json);
  println(result);
  return 0;
}"""),
        ("Transform JSON with jq expression", """requires jq;
async fn main() -> i64 {
  json: string = "{\"first\": \"John\", \"last\": \"Doe\"}";
  result: string = jq.transform("{full_name: (.first + \" \" + .last)}", json);
  println(result);
  return 0;
}"""),
        ("Extract keys from a JSON object", """requires jq;
async fn main() -> i64 {
  json: string = "{\"name\": \"test\", \"version\": \"1.0\", \"author\": \"rix\"}";
  keys: string = jq.keys(json);
  println(keys);
  return 0;
}"""),
        ("Extract values from a JSON object", """requires jq;
async fn main() -> i64 {
  json: string = "{\"a\": 1, \"b\": 2, \"c\": 3}";
  values: string = jq.values(json);
  println(values);
  return 0;
}"""),
        ("Extract array length from JSON", """requires jq;
async fn main() -> i64 {
  json: string = "[1, 2, 3, 4, 5]";
  result: string = jq.query("length", json);
  println(f"Array length: {result}");
  return 0;
}"""),
        ("Query and transform API response", """requires jq;
requires curl;
async fn main() -> i64 {
  response: string = await curl.get("https://api.example.com/users");
  names: string = jq.query(".[].name", response);
  println(names);
  return 0;
}"""),
    ]
    count = 0
    for desc, code in templates:
        if emit(out, desc, code):
            count += 1
        else:
            print(f"  FAIL: {desc}", file=sys.stderr)
    return count


def gen_yq_translations(out):
    """Generate yq-related Mog translations."""
    templates = [
        ("Query a YAML value by path", """requires yq;
async fn main() -> i64 {
  yaml: string = "name: myapp\nversion: 1.0\nport: 8080";
  result: string = yq.get(yaml, ".name");
  println(result);
  return 0;
}"""),
        ("Get nested YAML value", """requires yq;
async fn main() -> i64 {
  yaml: string = "database:\n  host: localhost\n  port: 5432";
  result: string = yq.get(yaml, ".database.host");
  println(result);
  return 0;
}"""),
        ("Convert YAML to JSON", """requires yq;
async fn main() -> i64 {
  yaml: string = "name: test\nversion: 1.0\nitems:\n  - a\n  - b";
  json: string = yq.to_json(yaml);
  println(json);
  return 0;
}"""),
        ("Convert JSON to YAML", """requires yq;
async fn main() -> i64 {
  json: string = "{\"name\": \"test\", \"version\": \"1.0\"}";
  yaml: string = yq.from_json(json);
  println(yaml);
  return 0;
}"""),
        ("Set a value in YAML", """requires yq;
async fn main() -> i64 {
  yaml: string = "name: myapp\nport: 8080";
  updated: string = yq.set(yaml, ".port", "9090");
  println(updated);
  return 0;
}"""),
        ("Update database host in YAML config", """requires yq;
async fn main() -> i64 {
  yaml: string = "database:\n  host: localhost\n  port: 5432";
  updated: string = yq.set(yaml, ".database.host", "production.db.com");
  println(updated);
  return 0;
}"""),
        ("Delete a key from YAML", """requires yq;
async fn main() -> i64 {
  yaml: string = "name: myapp\ndebug: true\nport: 8080";
  result: string = yq.delete_key(yaml, ".debug");
  println(result);
  return 0;
}"""),
        ("Apply yq expression to YAML", """requires yq;
async fn main() -> i64 {
  yaml: string = "items:\n  - name: a\n  - name: b\n  - name: c";
  result: string = yq.query(yaml, ".items[].name");
  println(result);
  return 0;
}"""),
    ]
    count = 0
    for desc, code in templates:
        if emit(out, desc, code):
            count += 1
        else:
            print(f"  FAIL: {desc}", file=sys.stderr)
    return count


def gen_cargo_translations(out):
    """Generate cargo-related Mog translations."""
    templates = [
        ("Build a Rust project", """requires cargo;
async fn main() -> i64 {
  result: int = await cargo.build(".");
  println(f"Build exit code: {result}");
  return 0;
}"""),
        ("Build a Rust project at a specific path", """requires cargo;
async fn main() -> i64 {
  result: int = await cargo.build("/home/user/my-project");
  println(f"Build exit code: {result}");
  return 0;
}"""),
        ("Run Rust tests", """requires cargo;
async fn main() -> i64 {
  result: int = await cargo.test(".");
  println(f"Test exit code: {result}");
  return 0;
}"""),
        ("Run tests for a specific Rust project", """requires cargo;
async fn main() -> i64 {
  result: int = await cargo.test("/home/user/my-crate");
  println(f"Test exit code: {result}");
  return 0;
}"""),
        ("Type-check a Rust project", """requires cargo;
async fn main() -> i64 {
  result: int = await cargo.check(".");
  println(f"Check exit code: {result}");
  return 0;
}"""),
        ("Run clippy lints on a project", """requires cargo;
async fn main() -> i64 {
  output: string = await cargo.clippy(".");
  println(output);
  return 0;
}"""),
        ("Run a Rust binary", """requires cargo;
async fn main() -> i64 {
  output: string = await cargo.run(".", "--help");
  println(output);
  return 0;
}"""),
        ("Run a Rust binary with arguments", """requires cargo;
async fn main() -> i64 {
  output: string = await cargo.run(".", "-- input.txt --verbose");
  println(output);
  return 0;
}"""),
        ("Format Rust code", """requires cargo;
async fn main() -> i64 {
  result: int = await cargo.fmt(".");
  println(f"Format exit code: {result}");
  return 0;
}"""),
        ("Build, test, and lint a Rust project", """requires cargo;
async fn main() -> i64 {
  build_result: int = await cargo.build(".");
  println(f"Build: {build_result}");
  test_result: int = await cargo.test(".");
  println(f"Test: {test_result}");
  lint_output: string = await cargo.clippy(".");
  println(f"Clippy: {lint_output}");
  return 0;
}"""),
    ]
    count = 0
    for desc, code in templates:
        if emit(out, desc, code):
            count += 1
        else:
            print(f"  FAIL: {desc}", file=sys.stderr)
    return count


def gen_python3_translations(out):
    """Generate python3-related Mog translations."""
    templates = [
        ("Run a Python script", """requires python3;
async fn main() -> i64 {
  output: string = await python3.run_script("app.py");
  println(output);
  return 0;
}"""),
        ("Run a Python test script", """requires python3;
async fn main() -> i64 {
  output: string = await python3.run_script("tests/test_main.py");
  println(output);
  return 0;
}"""),
        ("Run a Python script with arguments", """requires python3;
async fn main() -> i64 {
  output: string = await python3.run_script_args("process.py", "--input data.csv --output results.json");
  println(output);
  return 0;
}"""),
        ("Evaluate a Python expression", """requires python3;
async fn main() -> i64 {
  result: string = python3.eval("2 ** 10");
  println(f"2^10 = {result}");
  return 0;
}"""),
        ("Evaluate a math expression in Python", """requires python3;
async fn main() -> i64 {
  result: string = python3.eval("sum(range(1, 101))");
  println(f"Sum 1-100 = {result}");
  return 0;
}"""),
        ("Execute Python code", """requires python3;
async fn main() -> i64 {
  output: string = python3.exec("import json; print(json.dumps({'hello': 'world'}))");
  println(output);
  return 0;
}"""),
        ("Execute Python code to process data", """requires python3;
async fn main() -> i64 {
  output: string = python3.exec("for i in range(5): print(f'Item {i}')");
  println(output);
  return 0;
}"""),
        ("Run pytest via Python module", """requires python3;
async fn main() -> i64 {
  output: string = await python3.run_module("pytest", "tests/ -v");
  println(output);
  return 0;
}"""),
        ("Run a Python module", """requires python3;
async fn main() -> i64 {
  output: string = await python3.run_module("http.server", "8080");
  println(output);
  return 0;
}"""),
        ("Check Python version", """requires python3;
async fn main() -> i64 {
  version: string = python3.version();
  println(f"Python version: {version}");
  return 0;
}"""),
        ("Install a Python package", """requires python3;
async fn main() -> i64 {
  result: string = await python3.pip_install("requests");
  println(result);
  return 0;
}"""),
        ("Install multiple Python packages", """requires python3;
async fn main() -> i64 {
  await python3.pip_install("flask");
  await python3.pip_install("sqlalchemy");
  await python3.pip_install("alembic");
  println("Packages installed");
  return 0;
}"""),
        ("List installed Python packages", """requires python3;
async fn main() -> i64 {
  packages: string = python3.pip_list();
  println(packages);
  return 0;
}"""),
    ]
    count = 0
    for desc, code in templates:
        if emit(out, desc, code):
            count += 1
        else:
            print(f"  FAIL: {desc}", file=sys.stderr)
    return count


def gen_process_translations(out):
    """Generate process capability translations."""
    templates = [
        ("Get the current working directory", """requires process;
async fn main() -> i64 {
  cwd: string = process.cwd();
  println(f"Current directory: {cwd}");
  return 0;
}"""),
        ("Get an environment variable", """requires process;
async fn main() -> i64 {
  home: string = process.getenv("HOME");
  println(f"HOME: {home}");
  return 0;
}"""),
        ("Get the PATH environment variable", """requires process;
async fn main() -> i64 {
  path: string = process.getenv("PATH");
  println(f"PATH: {path}");
  return 0;
}"""),
        ("Get the current user from environment", """requires process;
async fn main() -> i64 {
  user: string = process.getenv("USER");
  println(f"Current user: {user}");
  return 0;
}"""),
        ("Get current timestamp", """requires process;
async fn main() -> i64 {
  ts: int = process.timestamp();
  println(f"Timestamp: {ts} ms");
  return 0;
}"""),
        ("Sleep for 100 milliseconds", """requires process;
async fn main() -> i64 {
  await process.sleep(100);
  println("Slept for 100ms");
  return 0;
}"""),
        ("Measure elapsed time of an operation", """requires process;
async fn main() -> i64 {
  start: int = process.timestamp();
  await process.sleep(50);
  end_time: int = process.timestamp();
  elapsed: int = end_time - start;
  println(f"Elapsed: {elapsed} ms");
  return 0;
}"""),
        ("Exit with success code", """requires process;
async fn main() -> i64 {
  println("Done");
  process.exit(0);
  return 0;
}"""),
        ("Exit with error code", """requires process;
async fn main() -> i64 {
  println("Fatal error");
  process.exit(1);
  return 0;
}"""),
    ]
    count = 0
    for desc, code in templates:
        if emit(out, desc, code):
            count += 1
        else:
            print(f"  FAIL: {desc}", file=sys.stderr)
    return count


def gen_log_translations(out):
    """Generate log capability translations."""
    templates = [
        ("Log an informational message", """requires log;
async fn main() -> i64 {
  log.info("Application started successfully");
  return 0;
}"""),
        ("Log a warning message", """requires log;
async fn main() -> i64 {
  log.warn("Disk usage above 80%");
  return 0;
}"""),
        ("Log an error message", """requires log;
async fn main() -> i64 {
  log.error("Failed to connect to database");
  return 0;
}"""),
        ("Log a debug message", """requires log;
async fn main() -> i64 {
  log.debug("Processing item 42");
  return 0;
}"""),
        ("Log at multiple levels", """requires log;
async fn main() -> i64 {
  log.info("Starting batch process");
  log.debug("Loading configuration");
  log.warn("Using default settings");
  log.info("Batch process complete");
  return 0;
}"""),
    ]
    count = 0
    for desc, code in templates:
        if emit(out, desc, code):
            count += 1
        else:
            print(f"  FAIL: {desc}", file=sys.stderr)
    return count


def gen_math_translations(out):
    """Generate math capability translations."""
    templates = [
        ("Add two numbers using math capability", """requires math;
async fn main() -> i64 {
  result: int = math.add(25, 17);
  println(f"25 + 17 = {result}");
  return 0;
}"""),
        ("Multiply two numbers", """requires math;
async fn main() -> i64 {
  result: int = math.multiply(7, 8);
  println(f"7 * 8 = {result}");
  return 0;
}"""),
        ("Subtract two numbers", """requires math;
async fn main() -> i64 {
  result: int = math.subtract(100, 37);
  println(f"100 - 37 = {result}");
  return 0;
}"""),
        ("Divide two numbers", """requires math;
async fn main() -> i64 {
  result: int = math.divide(144, 12);
  println(f"144 / 12 = {result}");
  return 0;
}"""),
        ("Get absolute value", """requires math;
async fn main() -> i64 {
  result: int = math.abs(-42);
  println(f"|-42| = {result}");
  return 0;
}"""),
        ("Find maximum of two numbers", """requires math;
async fn main() -> i64 {
  result: int = math.max(15, 27);
  println(f"max(15, 27) = {result}");
  return 0;
}"""),
        ("Find minimum of two numbers", """requires math;
async fn main() -> i64 {
  result: int = math.min(15, 27);
  println(f"min(15, 27) = {result}");
  return 0;
}"""),
        ("Chain multiple math operations", """requires math;
async fn main() -> i64 {
  sum: int = math.add(10, 20);
  product: int = math.multiply(sum, 3);
  result: int = math.subtract(product, 10);
  println(f"(10 + 20) * 3 - 10 = {result}");
  return 0;
}"""),
    ]
    count = 0
    for desc, code in templates:
        if emit(out, desc, code):
            count += 1
        else:
            print(f"  FAIL: {desc}", file=sys.stderr)
    return count


def gen_timer_translations(out):
    """Generate timer capability translations."""
    templates = [
        ("Set a timeout for 1 second", """requires timer;
async fn main() -> i64 {
  result: int = await timer.setTimeout(1000);
  println(f"Timer completed: {result}");
  return 0;
}"""),
        ("Set a short timeout", """requires timer;
async fn main() -> i64 {
  result: int = await timer.setTimeout(100);
  println("100ms timer fired");
  return 0;
}"""),
        ("Chain multiple timers", """requires timer;
async fn main() -> i64 {
  await timer.setTimeout(50);
  println("Step 1 done");
  await timer.setTimeout(50);
  println("Step 2 done");
  await timer.setTimeout(50);
  println("Step 3 done");
  return 0;
}"""),
    ]
    count = 0
    for desc, code in templates:
        if emit(out, desc, code):
            count += 1
        else:
            print(f"  FAIL: {desc}", file=sys.stderr)
    return count


def gen_composite_translations(out):
    """Generate multi-capability composite translations."""
    templates = [
        ("Search for TODOs in source and log the count", """requires grep;
requires log;
async fn main() -> i64 {
  count: int = grep.count("TODO", "src/main.rs");
  log.info(f"Found {count} TODOs in main.rs");
  println(f"TODO count: {count}");
  return 0;
}"""),
        ("Read a config file and extract a field with jq", """requires fs;
requires jq;
async fn main() -> i64 {
  contents: string = await fs.read_file("config.json");
  name: string = jq.query(".name", contents);
  println(f"Project name: {name}");
  return 0;
}"""),
        ("Git status check and log result", """requires git;
requires log;
async fn main() -> i64 {
  status: string = git.status();
  log.info("Checked git status");
  println(status);
  return 0;
}"""),
        ("Find Python files and count them", """requires find;
async fn main() -> i64 {
  count: int = await find.count("*.py", "src/");
  println(f"Python files: {count}");
  return 0;
}"""),
        ("Download JSON and parse it", """requires curl;
requires jq;
async fn main() -> i64 {
  response: string = await curl.get("https://api.example.com/config");
  version: string = jq.query(".version", response);
  println(f"Remote version: {version}");
  return 0;
}"""),
        ("Read YAML config and convert to JSON", """requires fs;
requires yq;
async fn main() -> i64 {
  yaml: string = await fs.read_file("config.yml");
  json: string = yq.to_json(yaml);
  await fs.write_file("config.json", json);
  println("Converted YAML to JSON");
  return 0;
}"""),
        ("Build Rust project and check for warnings", """requires cargo;
requires grep;
async fn main() -> i64 {
  output: string = await cargo.clippy(".");
  warnings: string = grep.search("warning", output);
  println(warnings);
  return 0;
}"""),
        ("Git commit workflow with logging", """requires git;
requires log;
async fn main() -> i64 {
  log.info("Starting commit workflow");
  git.add(".");
  result: string = git.commit("Automated commit");
  log.info("Commit complete");
  println(result);
  return 0;
}"""),
        ("Timed file operation", """requires fs;
requires process;
async fn main() -> i64 {
  start: int = process.timestamp();
  contents: string = await fs.read_file("large_data.csv");
  end_time: int = process.timestamp();
  elapsed: int = end_time - start;
  println(f"Read file in {elapsed} ms");
  return 0;
}"""),
        ("Search files and replace text", """requires grep;
requires sed;
requires fs;
async fn main() -> i64 {
  files: string = grep.files_matching("deprecated_fn", "src/");
  println(f"Files to update: {files}");
  result: string = sed.substitute_all_in_file("deprecated_fn", "new_fn", "src/lib.rs");
  println("Updated src/lib.rs");
  return 0;
}"""),
        ("Create a GitHub issue from grep results", """requires grep;
requires gh;
async fn main() -> i64 {
  count: int = grep.count("FIXME", "src/main.rs");
  result: string = await gh.issue_create("Fix remaining FIXMEs", f"Found {count} FIXME comments in main.rs that need addressing");
  println(result);
  return 0;
}"""),
        ("Docker build and push workflow", """requires docker;
requires log;
async fn main() -> i64 {
  log.info("Building Docker image");
  result: string = await docker.build(".", "my-app:latest");
  log.info("Build complete");
  println(result);
  return 0;
}"""),
        ("CSV data processing pipeline", """requires fs;
requires awk;
async fn main() -> i64 {
  data: string = await fs.read_file("sales.csv");
  total: float = awk.sum_field(3, ",", data);
  print_string("Total sales: ");
  print_f64(total);
  println("");
  return 0;
}"""),
        ("Environment inspection script", """requires process;
requires log;
async fn main() -> i64 {
  cwd: string = process.cwd();
  user: string = process.getenv("USER");
  home: string = process.getenv("HOME");
  log.info(f"User: {user}, Home: {home}, CWD: {cwd}");
  println(f"User: {user}");
  println(f"Home: {home}");
  println(f"CWD: {cwd}");
  return 0;
}"""),
        ("Read JSON config and validate required fields", """requires fs;
requires jq;
requires log;
async fn main() -> i64 {
  contents: string = await fs.read_file("package.json");
  name: string = jq.query(".name", contents);
  version: string = jq.query(".version", contents);
  log.info(f"Package: {name} v{version}");
  println(f"Package: {name}");
  println(f"Version: {version}");
  return 0;
}"""),
        ("Find large files and report", """requires find;
requires log;
async fn main() -> i64 {
  large: string = await find.by_min_size(1048576, ".");
  log.warn("Large files found:");
  println(large);
  return 0;
}"""),
        ("Git diff and grep for specific changes", """requires git;
requires grep;
async fn main() -> i64 {
  diff: string = git.diff();
  additions: string = grep.search("^\\+", diff);
  println("Added lines:");
  println(additions);
  return 0;
}"""),
        ("Check file existence before reading", """requires fs;
requires log;
async fn main() -> i64 {
  exists: bool = await fs.exists("data.json");
  if exists {
    contents: string = await fs.read_file("data.json");
    println(contents);
  } else {
    log.error("data.json not found");
  }
  return 0;
}"""),
        ("Process management with timing", """requires process;
requires timer;
async fn main() -> i64 {
  start: int = process.timestamp();
  await timer.setTimeout(200);
  end_time: int = process.timestamp();
  elapsed: int = end_time - start;
  println(f"Timer took {elapsed} ms");
  return 0;
}"""),
        ("Backup a file before modifying", """requires fs;
requires sed;
async fn main() -> i64 {
  contents: string = await fs.read_file("config.toml");
  await fs.write_file("config.toml.bak", contents);
  modified: string = sed.substitute_all("debug = true", "debug = false", contents);
  await fs.write_file("config.toml", modified);
  println("Config updated, backup saved");
  return 0;
}"""),
    ]
    count = 0
    for desc, code in templates:
        if emit(out, desc, code):
            count += 1
        else:
            print(f"  FAIL: {desc}", file=sys.stderr)
    return count


def main():
    total = 0
    with open(OUTPUT_FILE, "w") as out:
        print("Generating git translations...", file=sys.stderr)
        total += gen_git_translations(out)
        print(f"  Running total: {total}", file=sys.stderr)

        print("Generating grep translations...", file=sys.stderr)
        total += gen_grep_translations(out)
        print(f"  Running total: {total}", file=sys.stderr)

        print("Generating find translations...", file=sys.stderr)
        total += gen_find_translations(out)
        print(f"  Running total: {total}", file=sys.stderr)

        print("Generating fs translations...", file=sys.stderr)
        total += gen_fs_translations(out)
        print(f"  Running total: {total}", file=sys.stderr)

        print("Generating curl translations...", file=sys.stderr)
        total += gen_curl_translations(out)
        print(f"  Running total: {total}", file=sys.stderr)

        print("Generating docker translations...", file=sys.stderr)
        total += gen_docker_translations(out)
        print(f"  Running total: {total}", file=sys.stderr)

        print("Generating gh translations...", file=sys.stderr)
        total += gen_gh_translations(out)
        print(f"  Running total: {total}", file=sys.stderr)

        print("Generating sed translations...", file=sys.stderr)
        total += gen_sed_translations(out)
        print(f"  Running total: {total}", file=sys.stderr)

        print("Generating awk translations...", file=sys.stderr)
        total += gen_awk_translations(out)
        print(f"  Running total: {total}", file=sys.stderr)

        print("Generating jq translations...", file=sys.stderr)
        total += gen_jq_translations(out)
        print(f"  Running total: {total}", file=sys.stderr)

        print("Generating yq translations...", file=sys.stderr)
        total += gen_yq_translations(out)
        print(f"  Running total: {total}", file=sys.stderr)

        print("Generating cargo translations...", file=sys.stderr)
        total += gen_cargo_translations(out)
        print(f"  Running total: {total}", file=sys.stderr)

        print("Generating python3 translations...", file=sys.stderr)
        total += gen_python3_translations(out)
        print(f"  Running total: {total}", file=sys.stderr)

        print("Generating process translations...", file=sys.stderr)
        total += gen_process_translations(out)
        print(f"  Running total: {total}", file=sys.stderr)

        print("Generating log translations...", file=sys.stderr)
        total += gen_log_translations(out)
        print(f"  Running total: {total}", file=sys.stderr)

        print("Generating math translations...", file=sys.stderr)
        total += gen_math_translations(out)
        print(f"  Running total: {total}", file=sys.stderr)

        print("Generating timer translations...", file=sys.stderr)
        total += gen_timer_translations(out)
        print(f"  Running total: {total}", file=sys.stderr)

        print("Generating composite translations...", file=sys.stderr)
        total += gen_composite_translations(out)
        print(f"  Running total: {total}", file=sys.stderr)

    print(f"\nTotal valid translations: {total}", file=sys.stderr)


if __name__ == "__main__":
    main()
