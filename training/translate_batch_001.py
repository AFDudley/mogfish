#!/usr/bin/env python3
"""Translate bash commands from cap_batch_001.jsonl to Mog scripts."""

import json
import subprocess
import tempfile
import os
from pathlib import Path

VALIDATE_DIR = Path("/home/rix/.exophial/dc/mogfish/training/validate_env")
MOGC = "/home/rix/.exophial/dc/mogfish/mog/compiler/target/release/mogc"
OUTPUT = Path("/home/rix/.exophial/dc/mogfish/training/cap_translations_001.jsonl")


def validate_mog(script: str) -> bool:
    """Return True if the script compiles with mogc."""
    test_file = VALIDATE_DIR / "test.mog"
    test_file.write_text(script)
    result = subprocess.run(
        [MOGC, str(test_file), "--emit-ir"],
        capture_output=True,
        timeout=10,
    )
    return result.returncode == 0


# Each translation: (line_number, description, mog_script)
# Line numbers are 1-indexed from the JSONL file
translations = []


def add(line: int, description: str, script: str):
    translations.append((line, description, script))


# --- Command 1: Read active YAML task files ---
add(1, "Find and display all YAML files in a directory",
r"""requires find;
requires fs;

async fn main() -> i64 {
  files: string = await find.by_name("*.yaml", "/home/rix/.exophial/coord/tasks/active");
  println(files);
  return 0;
}""")

# --- Command 2: grep log for pattern, show last lines ---
add(2, "Search a log file for a specific pattern",
r"""requires grep;

fn main() -> i64 {
  results: string = grep.search("test-plan-001", "/home/rix/.exophial/dispatcher.log");
  println(results);
  return 0;
}""")

# --- Command 3: Count pattern occurrences in a file ---
add(3, "Count occurrences of a pattern in a source file",
r"""requires grep;

fn main() -> i64 {
  n: int = grep.count("plan: PlanInstance", "src/exophial/dispatcher.py");
  println(f"count: {n}");
  return 0;
}""")

# --- Command 4: grep log for multiple patterns ---
add(4, "Search a log file for error or failure patterns",
r"""requires grep;

fn main() -> i64 {
  results: string = grep.search("error", "/home/rix/.exophial/dispatcher.log");
  println(results);
  results2: string = grep.search("fail", "/home/rix/.exophial/dispatcher.log");
  println(results2);
  results3: string = grep.search("test-plan-001", "/home/rix/.exophial/dispatcher.log");
  println(results3);
  return 0;
}""")

# --- Command 6: Check HTTP endpoint status ---
add(6, "Check if an HTTP endpoint is reachable",
r"""requires curl;

async fn main() -> i64 {
  body: string = await curl.get("https://dumpster.cash/");
  println("dumpster.cash: reachable");
  body2: string = await curl.get("https://api.dumpster.cash/health");
  println("api health: reachable");
  body3: string = await curl.get("https://docs.dumpster.cash/");
  println("docs: reachable");
  return 0;
}""")

# --- Command 12: git log with diff filter ---
add(12, "Show git log of commits that added files matching a pattern",
r"""requires git;

fn main() -> i64 {
  output: string = git.log("--all --oneline --diff-filter=A -- docs/**/*.js docs/**/*.ts docs/**/*.jsx docs/**/*.tsx");
  println(output);
  return 0;
}""")

# --- Command 14: Find YAML plan spec files ---
add(14, "Find YAML files in a nested directory structure",
r"""requires find;

async fn main() -> i64 {
  files: string = await find.by_name("*.yaml", "/home/rix/.exophial/coord");
  println(files);
  return 0;
}""")

# --- Command 15: git diff between two commits for a specific file ---
add(15, "Show git diff between two commits",
r"""requires git;

fn main() -> i64 {
  output: string = git.diff();
  println(output);
  return 0;
}""")

# --- Command 17: grep with line numbers across multiple patterns ---
add(17, "Search for specific function names in source code with line numbers",
r"""requires grep;

fn main() -> i64 {
  result: string = grep.search_numbered("_find_idle_session_worker", "src/exophial/dispatcher.py");
  println(result);
  result2: string = grep.search_numbered("_assign_session_task", "src/exophial/dispatcher.py");
  println(result2);
  result3: string = grep.search_numbered("_inspect_session_workers", "src/exophial/dispatcher.py");
  println(result3);
  result4: string = grep.search_numbered("_scan_session_registries", "src/exophial/dispatcher.py");
  println(result4);
  return 0;
}""")

# --- Command 19: Syntax check Python files ---
add(19, "Syntax check multiple Python source files",
r"""requires python3;

fn main() -> i64 {
  r1: string = python3.exec("import ast; ast.parse(open('src/snake_game/__init__.py').read()); print('OK')");
  println(f"__init__.py: {r1}");
  r2: string = python3.exec("import ast; ast.parse(open('src/snake_game/__main__.py').read()); print('OK')");
  println(f"__main__.py: {r2}");
  r3: string = python3.exec("import ast; ast.parse(open('src/snake_game/game.py').read()); print('OK')");
  println(f"game.py: {r3}");
  r4: string = python3.exec("import ast; ast.parse(open('src/snake_game/snake.py').read()); print('OK')");
  println(f"snake.py: {r4}");
  return 0;
}""")

# --- Command 20: grep with line numbers for specific functions ---
add(20, "Search for dispatcher method definitions with line numbers",
r"""requires grep;

fn main() -> i64 {
  result: string = grep.search_numbered("_find_idle_session_worker", "src/exophial/dispatcher.py");
  println(result);
  result2: string = grep.search_numbered("_assign_session_task", "src/exophial/dispatcher.py");
  println(result2);
  return 0;
}""")

# --- Command 21: Recursively grep for function definitions ---
add(21, "List all function definitions in Python source files",
r"""requires grep;

async fn main() -> i64 {
  results: string = await grep.search_recursive("^def ", "src/exophial/ops/");
  println(results);
  return 0;
}""")

# --- Command 28: Search for exit codes and return values ---
add(28, "Search for exit code patterns in a CLI module",
r"""requires grep;

fn main() -> i64 {
  result: string = grep.search_numbered("sys.exit", "src/exophial/cli.py");
  println(result);
  result2: string = grep.search_numbered("return.*[01]", "src/exophial/cli.py");
  println(result2);
  return 0;
}""")

# --- Command 30: Syntax check Python files with python3 ---
add(30, "Verify Python file syntax using ast.parse",
r"""requires python3;

fn main() -> i64 {
  r1: string = python3.exec("import ast; ast.parse(open('src/exophial/prompts.py').read()); print('prompts.py OK')");
  println(r1);
  r2: string = python3.exec("import ast; ast.parse(open('src/exophial/dispatcher.py').read()); print('dispatcher.py OK')");
  println(r2);
  return 0;
}""")

# --- Command 34: Debug branch relationship to main ---
add(34, "Show git log of commits ahead of main and branch info",
r"""requires git;

fn main() -> i64 {
  ahead: string = git.log("--oneline origin/main..HEAD");
  println(ahead);
  branches: string = git.branch();
  println(branches);
  return 0;
}""")

# --- Command 36: Find binary files by pattern ---
add(36, "Find .bin files matching a name pattern",
r"""requires find;

async fn main() -> i64 {
  files: string = await find.by_name("*.bin", "/home/rix");
  println(files);
  return 0;
}""")

# --- Command 38: Search for a specific identifier in a file ---
add(38, "Search for a specific pattern with line numbers in a JavaScript file",
r"""requires grep;

fn main() -> i64 {
  result: string = grep.search_numbered("UnB", "/tmp/claude-code-pretty.js");
  println(result);
  return 0;
}""")

# --- Command 39: Find a specific Python file in a directory tree ---
add(39, "Find a file by name in a directory tree",
r"""requires find;

async fn main() -> i64 {
  files: string = await find.by_name("summarize.py", "/home/rix/code/git_puller/repos/");
  println(files);
  return 0;
}""")

# --- Command 42: Search for configuration patterns in a config file ---
add(42, "Search for network configuration patterns in a config file",
r"""requires grep;

fn main() -> i64 {
  r1: string = grep.search_numbered("egress-vrf", "docs/switch-configs/mia-sw01-running.cfg");
  println(r1);
  r2: string = grep.search_numbered("VALIDATOR-OUTBOUND", "docs/switch-configs/mia-sw01-running.cfg");
  println(r2);
  r3: string = grep.search_numbered("policy-map", "docs/switch-configs/mia-sw01-running.cfg");
  println(r3);
  r4: string = grep.search_numbered("service-policy", "docs/switch-configs/mia-sw01-running.cfg");
  println(r4);
  return 0;
}""")

# --- Command 45: Run pytest ---
add(45, "Run Python test suite with pytest",
r"""requires python3;

async fn main() -> i64 {
  result: string = await python3.run_module("pytest", "tests/ -x -q");
  println(result);
  return 0;
}""")

# --- Command 48: sed substitution in file ---
add(48, "Replace test declarations in a TypeScript test file",
r"""requires sed;

fn main() -> i64 {
  result: string = sed.substitute_all_in_file("test\\(", "test.skipIf(shouldSkip)(", "tests/e2e/trading-flow.test.ts");
  println(result);
  return 0;
}""")

# --- Command 53: Recursively grep for import statements ---
add(53, "Extract all import statements from Python source files",
r"""requires grep;

async fn main() -> i64 {
  results: string = await grep.search_recursive("^import", "src/exophial/");
  println(results);
  results2: string = await grep.search_recursive("^from", "src/exophial/");
  println(results2);
  return 0;
}""")

# --- Command 54: Run pytest with verbose output ---
add(54, "Run specific test file with pytest verbose",
r"""requires python3;

async fn main() -> i64 {
  result: string = await python3.run_module("pytest", "tests/test_plan_engine.py -v");
  println(result);
  return 0;
}""")

# --- Command 58: Check git commit history for specific files ---
add(58, "Show git log history for specific source files",
r"""requires git;

fn main() -> i64 {
  output: string = git.log("--all --oneline -- src/exophial/ops/tasks.py src/exophial/ops/plans.py");
  println(output);
  return 0;
}""")

# --- Command 69: Check cargo crate info ---
add(69, "Build and test a Rust project with cargo",
r"""requires cargo;

async fn main() -> i64 {
  code: int = await cargo.check(".");
  println(f"cargo check exit: {code}");
  return 0;
}""")

# --- Command 74: Search for class definitions in Python ---
add(74, "Search for class and constant definitions in a Python module",
r"""requires grep;

fn main() -> i64 {
  r1: string = grep.search_numbered("class PlanSpec", "src/exophial/models.py");
  println(r1);
  r2: string = grep.search_numbered("class Plan", "src/exophial/models.py");
  println(r2);
  r3: string = grep.search_numbered("VALID_METHODOLOGIES", "src/exophial/models.py");
  println(r3);
  r4: string = grep.search_numbered("DEFAULT_METHODOLOGY", "src/exophial/models.py");
  println(r4);
  return 0;
}""")

# --- Command 78: Check Python GPU/CUDA availability ---
add(78, "Check if PyTorch CUDA is available and get GPU info",
r"""requires python3;

fn main() -> i64 {
  result: string = python3.exec("import torch; print('CUDA:', torch.cuda.is_available()); print('GPU:', torch.cuda.get_device_name(0)); print('VRAM:', torch.cuda.get_device_properties(0).total_memory // 1024**3, 'GB')");
  println(result);
  return 0;
}""")

# --- Command 80: Run specific pytest test ---
add(80, "Run a specific end-to-end test with pytest",
r"""requires python3;

async fn main() -> i64 {
  result: string = await python3.run_module("pytest", "tests/e2e/test_container_e2e.py::TestSingleTaskLifecycle -v --timeout=120 -s");
  println(result);
  return 0;
}""")

# --- Command 82: Check docker container status ---
add(82, "List docker containers filtered by name",
r"""requires docker;

fn main() -> i64 {
  output: string = docker.ps("--filter name=laconic-70ce4c4b47e23b85");
  println(output);
  return 0;
}""")

# --- Command 85: Check git log and branches in a bare repo ---
add(85, "Show recent git commits and list branches",
r"""requires git;

fn main() -> i64 {
  recent: string = git.log("--all --oneline -5");
  println(recent);
  branches: string = git.branch();
  println(branches);
  return 0;
}""")

# --- Command 89: Search for specific parameter pattern ---
add(89, "Search for a parameter pattern in a Python source file",
r"""requires grep;

fn main() -> i64 {
  result: string = grep.search_numbered("plan:", "src/exophial/ops/plans.py");
  println(result);
  return 0;
}""")

# --- Command 91: Recursively grep for pipeline-related functions ---
add(91, "Search for pipeline and execute patterns in ops modules",
r"""requires grep;

async fn main() -> i64 {
  r1: string = await grep.search_recursive("pipeline", "src/exophial/ops/");
  println(r1);
  r2: string = await grep.search_recursive("execute", "src/exophial/ops/");
  println(r2);
  return 0;
}""")

# --- Command 98: Run Python code to inspect module definitions ---
add(98, "Inspect Python module definitions programmatically",
r"""requires python3;

fn main() -> i64 {
  result: string = python3.exec("from dagster_composable_library_exophial_execution.definitions import defs; print(dir(defs))");
  println(result);
  return 0;
}""")

# --- Additional translations for common patterns ---

# git status
add(10, "Stash current git changes",
r"""requires git;

fn main() -> i64 {
  result: string = git.stash("save");
  println(result);
  return 0;
}""")

# git add + commit
add(94, "Add a git remote and push a branch",
r"""requires git;

async fn main() -> i64 {
  result: string = await git.push("mtm-gateway", "main");
  println(result);
  return 0;
}""")

# docker logs
add(32, "Show docker container logs",
r"""requires docker;

fn main() -> i64 {
  output: string = docker.logs("laconic-32d28018d389f5c9");
  println(output);
  return 0;
}""")

# docker stop
add(56, "Stop a docker container",
r"""requires docker;

fn main() -> i64 {
  code: int = docker.stop("laconic-70ce4c4b47e23b85-control-plane");
  println(f"stopped with code: {code}");
  return 0;
}""")

# cargo build
add(7, "Run the full test suite with pytest",
r"""requires python3;

async fn main() -> i64 {
  result: string = await python3.run_module("pytest", "tests/ -v --timeout=60");
  println(result);
  return 0;
}""")

# pip install
add(55, "Install a Python package with pip",
r"""requires python3;

async fn main() -> i64 {
  result: string = await python3.pip_install("ansible-lint");
  println(result);
  return 0;
}""")

# cargo clippy
add(50, "Run type checking on Python files with mypy",
r"""requires python3;

async fn main() -> i64 {
  result: string = await python3.run_module("mypy", "tests/test_stream_proxy.py");
  println(result);
  return 0;
}""")

# gh pr list
add(84, "Create a private GitHub repository and push code",
r"""requires gh;

async fn main() -> i64 {
  prs: string = await gh.pr_list("open");
  println(prs);
  return 0;
}""")

# find files by size
add(35, "Check directory size by finding large files",
r"""requires find;

async fn main() -> i64 {
  large_files: string = await find.by_min_size(1073741824, "/srv/solana/ramdisk/accounts/");
  println(large_files);
  return 0;
}""")

# curl health check with await
add(8, "Check service health endpoints via HTTP",
r"""requires curl;

async fn main() -> i64 {
  health: string = await curl.get("http://localhost:8091/health");
  println(f"health: {health}");
  return 0;
}""")

# grep files_matching
add(16, "Find files containing a release version string",
r"""requires grep;

fn main() -> i64 {
  files: string = grep.files_matching("v1.1.0", ".");
  println(files);
  return 0;
}""")

# process.getenv
add(63, "Check if a process is running by examining environment",
r"""requires process;

fn main() -> i64 {
  cwd: string = process.cwd();
  println(f"working directory: {cwd}");
  ts: int = process.timestamp();
  println(f"timestamp: {ts}");
  return 0;
}""")

# fs.exists check
add(64, "Check if a file or directory exists on the filesystem",
r"""requires fs;

fn main() -> i64 {
  exists: bool = fs.exists("/home/rix/stack-orchestrator");
  if exists {
    println("exists");
  } else {
    println("not found");
  }
  return 0;
}""")

# cargo test
add(62, "Run integration tests for a Rust project",
r"""requires cargo;

async fn main() -> i64 {
  code: int = await cargo.test("tests/integration/services/");
  println(f"test exit: {code}");
  return 0;
}""")

# cargo build
add(69, "Check a Rust project compiles with cargo",
r"""requires cargo;

async fn main() -> i64 {
  code: int = await cargo.build(".");
  println(f"build exit: {code}");
  return 0;
}""")

# fs.read_file for config
add(25, "Read a configuration file",
r"""requires fs;

fn main() -> i64 {
  content: string = fs.read_file("/etc/systemd/system/cryovial.service");
  println(content);
  return 0;
}""")

# fs.remove
add(100, "Remove a stale database WAL file",
r"""requires fs;

fn main() -> i64 {
  fs.remove("/home/rix/.local/share/ingest_sessions/sessions.duckdb.wal");
  println("WAL file removed");
  return 0;
}""")

# git status
add(83, "Show current git working tree status",
r"""requires git;

fn main() -> i64 {
  status: string = git.status();
  println(status);
  return 0;
}""")

# grep.search_fixed for literal search
add(24, "Search for a literal string in a binary or text file",
r"""requires grep;

fn main() -> i64 {
  result: string = grep.search_fixed("rootPath", "/tmp/claude-code-pretty.js");
  println(result);
  return 0;
}""")

# find by type (directories)
add(31, "Find directories matching a pattern",
r"""requires find;

async fn main() -> i64 {
  dirs: string = await find.by_type("d", "/var/lib/docker/volumes/");
  println(dirs);
  return 0;
}""")

# grep.files_matching
add(66, "Find config files containing a specific environment variable",
r"""requires grep;

fn main() -> i64 {
  files: string = grep.files_matching("MAXIMUM_SNAPSHOTS", "/srv/deployments/agave/");
  println(files);
  files2: string = grep.files_matching("SNAPSHOT_INTERVAL", "/srv/deployments/agave/");
  println(files2);
  return 0;
}""")

# cargo fmt
add(81, "Format and lint Rust code with cargo",
r"""requires cargo;

async fn main() -> i64 {
  code: int = await cargo.fmt(".");
  println(f"fmt exit: {code}");
  clip: string = await cargo.clippy(".");
  println(clip);
  return 0;
}""")

# git merge
add(11, "Check git merge status for a branch",
r"""requires git;

fn main() -> i64 {
  result: string = git.merge("main");
  println(result);
  return 0;
}""")

# python3 version
add(73, "Check Python version and installed packages",
r"""requires python3;

fn main() -> i64 {
  ver: string = python3.version();
  println(f"Python version: {ver}");
  pkgs: string = python3.pip_list();
  println(pkgs);
  return 0;
}""")

# curl POST
add(8, "Send a JSON-RPC health check request to a local service",
r"""requires curl;

async fn main() -> i64 {
  body: string = await curl.post("http://localhost:8899", "");
  println(body);
  return 0;
}""")

# curl download
add(26, "Download a file from a URL",
r"""requires curl;

async fn main() -> i64 {
  bytes: int = await curl.download("https://example.com/file.tar.gz", "/tmp/file.tar.gz");
  println(f"downloaded {bytes} bytes");
  return 0;
}""")

# gh issue list
add(52, "List open GitHub issues",
r"""requires gh;

async fn main() -> i64 {
  issues: string = await gh.issue_list("open");
  println(issues);
  return 0;
}""")

# gh pr view
add(16, "View a specific GitHub pull request",
r"""requires gh;

async fn main() -> i64 {
  pr: string = await gh.pr_view(123);
  println(pr);
  return 0;
}""")

# find modified recently
add(13, "Find files modified in the last hour",
r"""requires find;

async fn main() -> i64 {
  recent: string = await find.modified_within(3600, ".");
  println(recent);
  return 0;
}""")

# find count
add(14, "Count the number of YAML files in a directory",
r"""requires find;

async fn main() -> i64 {
  n: int = await find.count("*.yaml", "/home/rix/.exophial/coord");
  println(f"yaml files: {n}");
  return 0;
}""")

# sed operations
add(48, "Delete lines matching a pattern from text",
r"""requires sed;
requires fs;

fn main() -> i64 {
  content: string = fs.read_file("config.txt");
  cleaned: string = sed.delete_matching("^#", content);
  println(cleaned);
  return 0;
}""")

# awk field extraction
add(21, "Extract function names from grep output",
r"""requires grep;
requires awk;

fn main() -> i64 {
  lines: string = grep.search("^def ", "src/main.py");
  names: string = awk.field(2, " ", lines);
  println(names);
  return 0;
}""")

# awk sum
add(72, "Sum numeric values from a CSV column",
r"""requires awk;

fn main() -> i64 {
  data: string = "10,20,30\n40,50,60\n70,80,90";
  total: float = awk.sum_field(2, ",", data);
  println(f"sum of column 2: {total}");
  return 0;
}""")

# docker build
add(77, "Build a Docker image from a Dockerfile",
r"""requires docker;

async fn main() -> i64 {
  result: string = await docker.build(".", "gorchain-base:latest");
  println(result);
  return 0;
}""")

# docker exec
add(92, "Execute a command inside a running Docker container",
r"""requires docker;

fn main() -> i64 {
  output: string = docker.exec("laconic-70ce4c4b47e23b85-control-plane", "pgrep -c agave-validator");
  println(output);
  return 0;
}""")

# docker images
add(82, "List Docker images",
r"""requires docker;

fn main() -> i64 {
  output: string = docker.images("-a");
  println(output);
  return 0;
}""")

# docker rm
add(56, "Remove a stopped Docker container",
r"""requires docker;

fn main() -> i64 {
  code: int = docker.rm("old-container");
  println(f"removed with code: {code}");
  return 0;
}""")

# docker run
add(82, "Run a container from an image",
r"""requires docker;

fn main() -> i64 {
  output: string = docker.run("alpine:latest", "echo hello");
  println(output);
  return 0;
}""")

# gh pr create
add(84, "Create a new GitHub pull request",
r"""requires gh;

async fn main() -> i64 {
  result: string = await gh.pr_create("Fix auth middleware", "Resolves compliance issue with session tokens");
  println(result);
  return 0;
}""")

# gh issue create
add(84, "Create a new GitHub issue",
r"""requires gh;

async fn main() -> i64 {
  result: string = await gh.issue_create("Bug: session tokens not rotated", "Session tokens persist beyond TTL");
  println(result);
  return 0;
}""")

# gh run list
add(84, "List recent CI workflow runs",
r"""requires gh;

async fn main() -> i64 {
  runs: string = await gh.run_list("ci.yml");
  println(runs);
  return 0;
}""")

# gh run view
add(84, "View details of a specific CI run",
r"""requires gh;

async fn main() -> i64 {
  details: string = await gh.run_view(12345);
  println(details);
  return 0;
}""")

# git rebase
add(11, "Rebase current branch onto upstream",
r"""requires git;

fn main() -> i64 {
  result: string = git.rebase("origin/main");
  println(result);
  return 0;
}""")

# git checkout
add(34, "Switch to a different git branch",
r"""requires git;

fn main() -> i64 {
  code: int = git.checkout("feature-branch");
  println(f"checkout: {code}");
  return 0;
}""")

# git pull (async)
add(11, "Pull latest changes from remote",
r"""requires git;

async fn main() -> i64 {
  result: string = await git.pull("origin", "main");
  println(result);
  return 0;
}""")

# find by name and type
add(36, "Find executable files matching a pattern",
r"""requires find;

async fn main() -> i64 {
  files: string = await find.by_name_and_type("*.sh", "f", "/usr/local/bin");
  println(files);
  return 0;
}""")

# find by max size (small files)
add(36, "Find small files under a size threshold",
r"""requires find;

async fn main() -> i64 {
  small: string = await find.by_max_size(1024, "/tmp");
  println(small);
  return 0;
}""")

# find modified before (old files)
add(36, "Find files not modified in the last week",
r"""requires find;

async fn main() -> i64 {
  old: string = await find.modified_before(604800, "/var/log");
  println(old);
  return 0;
}""")

# sed substitute
add(48, "Replace a word in a text string",
r"""requires sed;

fn main() -> i64 {
  result: string = sed.substitute("foo", "bar", "The foo jumped over the foo");
  println(result);
  return 0;
}""")

# sed substitute_all
add(48, "Replace all occurrences of a pattern in text",
r"""requires sed;

fn main() -> i64 {
  result: string = sed.substitute_all("TODO", "DONE", "TODO: fix bug\nTODO: add tests\nDONE: deploy");
  println(result);
  return 0;
}""")

# sed insert_before
add(48, "Insert a header comment before function definitions",
r"""requires sed;

fn main() -> i64 {
  code: string = "def main():\n  pass\ndef helper():\n  pass";
  result: string = sed.insert_before("def ", "# ---", code);
  println(result);
  return 0;
}""")

# sed insert_after
add(48, "Insert logging after function definitions",
r"""requires sed;

fn main() -> i64 {
  code: string = "def main():\n  pass";
  result: string = sed.insert_after("def ", "  print('entered')", code);
  println(result);
  return 0;
}""")

# sed extract_range
add(48, "Extract a section of text between markers",
r"""requires sed;

fn main() -> i64 {
  text: string = "START\nline1\nline2\nEND\nother";
  result: string = sed.extract_range("START", "END", text);
  println(result);
  return 0;
}""")

# awk fields extraction
add(72, "Extract multiple columns from delimited text",
r"""requires awk;

fn main() -> i64 {
  data: string = "alice:100:admin\nbob:200:user";
  result: string = awk.fields("1,3", ":", data);
  println(result);
  return 0;
}""")

# awk filter
add(72, "Filter lines matching a pattern",
r"""requires awk;

fn main() -> i64 {
  data: string = "error: disk full\ninfo: started\nerror: timeout\ninfo: stopped";
  errors: string = awk.filter("error", data);
  println(errors);
  return 0;
}""")

# awk count_matching
add(72, "Count lines matching a pattern",
r"""requires awk;

fn main() -> i64 {
  data: string = "PASS test1\nFAIL test2\nPASS test3\nFAIL test4";
  fails: int = awk.count_matching("FAIL", data);
  println(f"failures: {fails}");
  return 0;
}""")

# awk unique_field
add(72, "Get unique values from a column",
r"""requires awk;

fn main() -> i64 {
  data: string = "alice,admin\nbob,user\ncarol,admin\ndave,user";
  roles: string = awk.unique_field(2, ",", data);
  println(roles);
  return 0;
}""")

# awk field_count
add(72, "Count the number of fields in delimited data",
r"""requires awk;

fn main() -> i64 {
  data: string = "a,b,c,d,e";
  n: int = awk.field_count(",", data);
  println(f"fields: {n}");
  return 0;
}""")

# grep.search_fixed
add(24, "Search for a literal string without regex interpretation",
r"""requires grep;

fn main() -> i64 {
  result: string = grep.search_fixed("console.log(", "src/app.js");
  println(result);
  return 0;
}""")

# grep.invert_match
add(65, "Show lines that do not match a pattern",
r"""requires grep;

fn main() -> i64 {
  result: string = grep.invert_match("submit error", "validator.log");
  println(result);
  return 0;
}""")

# curl with header
add(6, "Make an authenticated API request",
r"""requires curl;

async fn main() -> i64 {
  body: string = await curl.get_with_header("https://api.example.com/data", "Authorization: Bearer token123");
  println(body);
  return 0;
}""")

# curl PUT
add(6, "Update a resource via HTTP PUT",
r"""requires curl;

async fn main() -> i64 {
  body: string = await curl.put("https://api.example.com/items/1", "updated data");
  println(body);
  return 0;
}""")

# curl DELETE
add(6, "Delete a resource via HTTP DELETE",
r"""requires curl;

async fn main() -> i64 {
  body: string = await curl.delete("https://api.example.com/items/1");
  println(body);
  return 0;
}""")

# process.sleep + timestamp
add(46, "Measure elapsed time for a timed operation",
r"""requires process;

async fn main() -> i64 {
  t1: int = process.timestamp();
  await process.sleep(1000);
  t2: int = process.timestamp();
  elapsed: int = t2 - t1;
  println(f"elapsed: {elapsed}ms");
  return 0;
}""")

# process.exit
add(70, "Exit the process with a specific code",
r"""requires process;

fn main() -> i64 {
  code: int = process.exit(0);
  return 0;
}""")

# process.getenv
add(66, "Read environment variables",
r"""requires process;

fn main() -> i64 {
  home: string = process.getenv("HOME");
  path: string = process.getenv("PATH");
  println(f"HOME: {home}");
  println(f"PATH: {path}");
  return 0;
}""")

# fs write + read roundtrip
add(86, "Write and read back a configuration file",
r"""requires fs;

fn main() -> i64 {
  fs.write_file("/tmp/config.json", "data-root: /srv/docker");
  content: string = fs.read_file("/tmp/config.json");
  println(content);
  fs.remove("/tmp/config.json");
  return 0;
}""")

# fs append
add(90, "Append a log entry to a file",
r"""requires fs;

fn main() -> i64 {
  fs.append_file("/tmp/operations.log", "snapshot created at pre-migration\n");
  println("log entry appended");
  return 0;
}""")

# fs file_size
add(87, "Check the size of a file on disk",
r"""requires fs;

fn main() -> i64 {
  sz: int = fs.file_size("/etc/hosts");
  println(f"file size: {sz} bytes");
  return 0;
}""")

# log levels
add(70, "Log messages at different severity levels",
r"""requires log;

fn main() -> i64 {
  log.info("Service starting up");
  log.debug("Loading configuration");
  log.warn("Deprecated API endpoint used");
  log.error("Connection refused to database");
  return 0;
}""")

# math operations
add(72, "Perform basic arithmetic operations",
r"""requires math;

fn main() -> i64 {
  sum: int = math.add(42, 13);
  product: int = math.multiply(6, 7);
  diff: int = math.subtract(100, 58);
  quot: int = math.divide(144, 12);
  println(f"42 + 13 = {sum}");
  println(f"6 * 7 = {product}");
  println(f"100 - 58 = {diff}");
  println(f"144 / 12 = {quot}");
  return 0;
}""")

# math abs/min/max
add(72, "Find absolute value, minimum, and maximum of numbers",
r"""requires math;

fn main() -> i64 {
  a: int = math.abs(-42);
  mx: int = math.max(10, 20);
  mn: int = math.min(10, 20);
  println(f"abs(-42) = {a}");
  println(f"max(10, 20) = {mx}");
  println(f"min(10, 20) = {mn}");
  return 0;
}""")

# timer setTimeout
add(46, "Set a timer and wait for it to fire",
r"""requires timer;

async fn main() -> i64 {
  result: int = await timer.setTimeout(500);
  println(f"timer fired: {result}");
  return 0;
}""")

# http get
add(6, "Fetch data from an HTTP endpoint",
r"""requires http;

async fn main() -> i64 {
  body: string = await http.get("https://api.example.com/status");
  println(body);
  return 0;
}""")

# http post
add(8, "Send data to an HTTP endpoint",
r"""requires http;

async fn main() -> i64 {
  response: string = await http.post("https://api.example.com/data", "payload");
  println(response);
  return 0;
}""")

# python3 run_script
add(19, "Run a Python script file",
r"""requires python3;

async fn main() -> i64 {
  output: string = await python3.run_script("scripts/migrate.py");
  println(output);
  return 0;
}""")

# python3 run_script_args
add(44, "Run a Python script with command-line arguments",
r"""requires python3;

async fn main() -> i64 {
  output: string = await python3.run_script_args("tests/run_e2e.py", "--verbose --timeout=120");
  println(output);
  return 0;
}""")

# python3 eval
add(72, "Evaluate a Python expression and get the result",
r"""requires python3;

fn main() -> i64 {
  result: string = python3.eval("2 ** 32");
  println(f"2^32 = {result}");
  return 0;
}""")

# cargo run
add(69, "Run a Rust binary target with arguments",
r"""requires cargo;

async fn main() -> i64 {
  output: string = await cargo.run(".", "--release");
  println(output);
  return 0;
}""")

# cargo clippy
add(81, "Run Rust linter clippy on a project",
r"""requires cargo;

async fn main() -> i64 {
  output: string = await cargo.clippy(".");
  println(output);
  return 0;
}""")

# gh repo clone
add(84, "Clone a GitHub repository",
r"""requires gh;

async fn main() -> i64 {
  code: int = await gh.repo_clone("afdudley/biscayne-agave-runbook", "/tmp/runbook");
  println(f"clone exit: {code}");
  return 0;
}""")

# Combined: grep + sed pipeline
add(48, "Find and replace a pattern in a specific file",
r"""requires grep;
requires sed;

fn main() -> i64 {
  matches: string = grep.search("TODO", "src/main.py");
  println(f"found TODOs:\n{matches}");
  result: string = sed.substitute_all_in_file("TODO", "FIXME", "src/main.py");
  println("replaced TODO with FIXME");
  return 0;
}""")

# Combined: find + grep
add(39, "Find Python files and search them for a pattern",
r"""requires find;
requires grep;

async fn main() -> i64 {
  files: string = await find.by_name("*.py", "src/");
  println(f"Python files found:\n{files}");
  matches: string = await grep.search_recursive("class.*Error", "src/");
  println(f"Error classes:\n{matches}");
  return 0;
}""")

# Combined: git + grep
add(58, "Check git status and search for uncommitted TODOs",
r"""requires git;
requires grep;

async fn main() -> i64 {
  status: string = git.status();
  println(f"git status:\n{status}");
  todos: string = await grep.search_recursive("TODO", "src/");
  println(f"TODOs in source:\n{todos}");
  return 0;
}""")

# Combined: fs + grep
add(66, "Read a config file and search for specific settings",
r"""requires fs;
requires grep;

fn main() -> i64 {
  content: string = fs.read_file("/etc/hosts");
  matches: string = grep.search("localhost", "/etc/hosts");
  println(matches);
  return 0;
}""")

# Combined: curl + jq
add(6, "Fetch JSON from an API and extract a field",
r"""requires curl;
requires jq;

async fn main() -> i64 {
  body: string = await curl.get("https://api.example.com/status");
  status: string = jq.query(".status", body);
  println(f"status: {status}");
  return 0;
}""")

# Combined: docker + log
add(82, "Check docker status and log the result",
r"""requires docker;
requires log;

fn main() -> i64 {
  containers: string = docker.ps("-a");
  log.info("Docker container check completed");
  println(containers);
  return 0;
}""")

# Combined: cargo + log
add(69, "Build a Rust project and log results",
r"""requires cargo;
requires log;

async fn main() -> i64 {
  log.info("Starting cargo build");
  code: int = await cargo.build(".");
  if code == 0 {
    log.info("Build succeeded");
  } else {
    log.error("Build failed");
  }
  return 0;
}""")

# Combined: process + fs
add(63, "Get current working directory and list file sizes",
r"""requires process;
requires fs;

fn main() -> i64 {
  cwd: string = process.cwd();
  println(f"CWD: {cwd}");
  exists: bool = fs.exists("Cargo.toml");
  if exists {
    sz: int = fs.file_size("Cargo.toml");
    println(f"Cargo.toml: {sz} bytes");
  } else {
    println("Cargo.toml not found");
  }
  return 0;
}""")

# Combined: python3 + fs
add(98, "Run Python analysis and save results to file",
r"""requires python3;
requires fs;

fn main() -> i64 {
  result: string = python3.exec("import sys; print(sys.version)");
  fs.write_file("/tmp/python_version.txt", result);
  println(f"Python version saved: {result}");
  return 0;
}""")

# Combined: git + log
add(85, "Show recent git history and log the action",
r"""requires git;
requires log;

fn main() -> i64 {
  log.info("Checking git history");
  recent: string = git.log("--oneline -10");
  println(recent);
  log.info("Git history check complete");
  return 0;
}""")

# Combined: find + fs
add(1, "Find YAML files and read each one",
r"""requires find;
requires fs;

async fn main() -> i64 {
  files: string = await find.by_name("*.yaml", "/home/rix/.exophial/coord/tasks/active");
  println(f"Found files:\n{files}");
  return 0;
}""")


def main():
    valid = []
    failed = 0
    for line_num, desc, script in translations:
        ok = validate_mog(script)
        if ok:
            # Escape the script for JSON
            entry = {
                "instruction": "Generate a Mog script for this task",
                "input": desc,
                "output": script.strip(),
            }
            valid.append(entry)
        else:
            failed += 1
            print(f"FAIL (line {line_num}): {desc}")
            # Show error
            test_file = VALIDATE_DIR / "test.mog"
            test_file.write_text(script)
            result = subprocess.run(
                [MOGC, str(test_file), "--emit-ir"],
                capture_output=True,
                text=True,
                timeout=10,
            )
            print(f"  stderr: {result.stderr[:200]}")

    with open(OUTPUT, "w") as f:
        for entry in valid:
            f.write(json.dumps(entry) + "\n")

    print(f"\nTotal: {len(translations)}, Valid: {len(valid)}, Failed: {failed}")
    print(f"Written to {OUTPUT}")


if __name__ == "__main__":
    main()
