#!/usr/bin/env python3
"""Generate Mog training translations for cap_batch_009."""
import json

OUT = "/home/rix/.exophial/dc/mogfish/training/cap_translations_009.jsonl"

def e(input_desc: str, output_mog: str) -> dict:
    return {"instruction": "Generate a Mog script for this task", "input": input_desc, "output": output_mog}

examples = []

# === GREP-BASED (from batch + derived) ===

examples.append(e(
    "Search for worker and pane references in markdown documentation files",
    'requires grep;\n\nasync fn main() -> i64 {\n  results: string = await grep.search_recursive("worker|pane|WorkerPool", "docs/");\n  println(results);\n  return 0;\n}'
))

examples.append(e(
    "Count occurrences of PlanInstance and PlanTemplate_Meta in a Python source file",
    'requires grep;\n\nfn main() -> i64 {\n  n1: int = grep.count("PlanInstance", "src/exophial/dispatcher.py");\n  n2: int = grep.count("PlanTemplate_Meta", "src/exophial/dispatcher.py");\n  println(f"PlanInstance: {n1}");\n  println(f"PlanTemplate_Meta: {n2}");\n  return 0;\n}'
))

examples.append(e(
    "Find the _remove_plan_files function definition with line numbers",
    'requires grep;\n\nfn main() -> i64 {\n  result: string = grep.search_numbered("_remove_plan_files", "src/exophial/ops/plans.py");\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "Search for pipeline-related function definitions in a dispatcher module",
    'requires grep;\n\nfn main() -> i64 {\n  result: string = grep.search_numbered("def _process_plan|def dispatch_plan|pipeline.*True", "src/exophial/dispatcher.py");\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "Search recursively for resolve_agent_name in source code, excluding cache directories",
    'requires grep;\n\nasync fn main() -> i64 {\n  results: string = await grep.search_recursive("resolve_agent_name", "src/exophial/");\n  println(results);\n  return 0;\n}'
))

examples.append(e(
    "Find files containing a specific class or backend reference",
    'requires grep;\n\nfn main() -> i64 {\n  files: string = grep.files_matching("AgentSDKBackend|dc_backend|orchestrator", "src/exophial/");\n  println(files);\n  return 0;\n}'
))

examples.append(e(
    "Count external system calls in a dispatcher module",
    'requires grep;\n\nfn main() -> i64 {\n  n: int = grep.count("subprocess|os.kill|get_panes|send_keys|tmux|git.*run", "src/exophial/dispatcher.py");\n  println(f"external system calls: {n}");\n  return 0;\n}'
))

examples.append(e(
    "Search for import statements at the top of a Python module",
    'requires grep;\n\nfn main() -> i64 {\n  result: string = grep.search_numbered("^from|^import", "src/config/types.py");\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "Search for pipeline references in documentation files",
    'requires grep;\n\nasync fn main() -> i64 {\n  results: string = await grep.search_recursive("exophial-spec|exophial-plan|exophial-execution", "docs/");\n  println(results);\n  return 0;\n}'
))

examples.append(e(
    "Search for active status strings in a Python file",
    'requires grep;\n\nfn main() -> i64 {\n  result: string = grep.search_numbered("active", "src/exophial/dispatcher.py");\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "Find all function and class definitions in a Python source file",
    'requires grep;\n\nfn main() -> i64 {\n  result: string = grep.search_numbered("^def |^class ", "src/exophial/cli.py");\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "Count top-level function definitions in a module",
    'requires grep;\n\nfn main() -> i64 {\n  n: int = grep.count("^def ", "src/exophial/cli.py");\n  println(f"functions: {n}");\n  return 0;\n}'
))

examples.append(e(
    "Search for plan data dictionary access patterns",
    'requires grep;\n\nfn main() -> i64 {\n  r1: string = grep.search_numbered("plan_data", "src/exophial/dispatcher.py");\n  println(r1);\n  r2: string = grep.search_numbered("plan_data", "src/exophial/ops/plans.py");\n  println(r2);\n  return 0;\n}'
))

examples.append(e(
    "Search for YAML loading functions across Python source files",
    'requires grep;\n\nasync fn main() -> i64 {\n  results: string = await grep.search_recursive("def load_yaml", "src/exophial/");\n  println(results);\n  return 0;\n}'
))

examples.append(e(
    "Find template usage counts in YAML plan files",
    'requires grep;\n\nfn main() -> i64 {\n  result: string = grep.search("template:", "plans/active.yaml");\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "Search for socket file path definitions",
    'requires grep;\n\nasync fn main() -> i64 {\n  results: string = await grep.search_recursive("def get_socket_file|SOCKET_FILE|exophiald.sock", "src/exophial/");\n  println(results);\n  return 0;\n}'
))

examples.append(e(
    "Search for pipeline constants in a Python init file",
    'requires grep;\n\nfn main() -> i64 {\n  result: string = grep.search_numbered("EXECUTION_PIPELINE|PLAN_PIPELINE|SPEC_PIPELINE", "src/exophial/pipelines/__init__.py");\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "Find lines NOT matching a comment pattern in source code",
    'requires grep;\n\nfn main() -> i64 {\n  result: string = grep.invert_match("^#|^$", "src/config.py");\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "Search for error patterns in a log file",
    'requires grep;\n\nfn main() -> i64 {\n  errors: string = grep.search("ERROR|FAIL|CRITICAL", "/var/log/app.log");\n  println(errors);\n  return 0;\n}'
))

examples.append(e(
    "Find all TODO comments in source code recursively",
    'requires grep;\n\nasync fn main() -> i64 {\n  results: string = await grep.search_recursive("TODO|FIXME|HACK", "src/");\n  println(results);\n  return 0;\n}'
))

examples.append(e(
    "Search for a fixed string literal in a configuration file",
    'requires grep;\n\nfn main() -> i64 {\n  result: string = grep.search_fixed("DATABASE_URL", ".env");\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "Count the number of test functions in a test file",
    'requires grep;\n\nfn main() -> i64 {\n  n: int = grep.count("def test_", "tests/test_dispatcher.py");\n  println(f"test functions: {n}");\n  return 0;\n}'
))

examples.append(e(
    "Find all files containing a specific import",
    'requires grep;\n\nfn main() -> i64 {\n  files: string = grep.files_matching("from dataclasses import", "src/");\n  println(files);\n  return 0;\n}'
))

# === FIND-BASED ===

examples.append(e(
    "Find all Python files in a source directory",
    'requires find;\n\nasync fn main() -> i64 {\n  files: string = await find.by_name_and_type("*.py", "f", "src/exophial/");\n  println(files);\n  return 0;\n}'
))

examples.append(e(
    "Find all markdown documentation files in a docs directory",
    'requires find;\n\nasync fn main() -> i64 {\n  files: string = await find.by_name_and_type("*.md", "f", "docs/");\n  println(files);\n  return 0;\n}'
))

examples.append(e(
    "Find all Rust source files in a project",
    'requires find;\n\nasync fn main() -> i64 {\n  files: string = await find.by_name_and_type("*.rs", "f", "src/");\n  println(files);\n  return 0;\n}'
))

examples.append(e(
    "Find all ABI JSON files in a project",
    'requires find;\n\nasync fn main() -> i64 {\n  files: string = await find.by_name("*.abi.json", "wcm-docs/");\n  println(files);\n  return 0;\n}'
))

examples.append(e(
    "Find all files in a directory, excluding git metadata",
    'requires find;\n\nasync fn main() -> i64 {\n  files: string = await find.by_type("f", "project/");\n  println(files);\n  return 0;\n}'
))

examples.append(e(
    "Find all YAML and JSON config files in a project",
    'requires find;\n\nasync fn main() -> i64 {\n  yaml: string = await find.by_name("*.yaml", ".");\n  println(yaml);\n  yml: string = await find.by_name("*.yml", ".");\n  println(yml);\n  json_files: string = await find.by_name("*.json", ".");\n  println(json_files);\n  return 0;\n}'
))

examples.append(e(
    "Count Python files in a source directory",
    'requires find;\n\nasync fn main() -> i64 {\n  n: int = await find.count("*.py", "src/");\n  println(f"Python files: {n}");\n  return 0;\n}'
))

examples.append(e(
    "Find all directories in a project",
    'requires find;\n\nasync fn main() -> i64 {\n  dirs: string = await find.by_type("d", ".");\n  println(dirs);\n  return 0;\n}'
))

examples.append(e(
    "Find files modified within the last hour",
    'requires find;\n\nasync fn main() -> i64 {\n  files: string = await find.modified_within(3600, ".");\n  println(files);\n  return 0;\n}'
))

examples.append(e(
    "Find files larger than 1MB in a project",
    'requires find;\n\nasync fn main() -> i64 {\n  files: string = await find.by_min_size(1048576, ".");\n  println(files);\n  return 0;\n}'
))

examples.append(e(
    "Find all test files in a project",
    'requires find;\n\nasync fn main() -> i64 {\n  files: string = await find.by_name("test_*.py", "tests/");\n  println(files);\n  return 0;\n}'
))

examples.append(e(
    "Find all Dockerfile files in a project",
    'requires find;\n\nasync fn main() -> i64 {\n  files: string = await find.by_name("Dockerfile*", ".");\n  println(files);\n  return 0;\n}'
))

examples.append(e(
    "Find TOML configuration files",
    'requires find;\n\nasync fn main() -> i64 {\n  files: string = await find.by_name("*.toml", ".");\n  println(files);\n  return 0;\n}'
))

examples.append(e(
    "Find all shell scripts in a project",
    'requires find;\n\nasync fn main() -> i64 {\n  files: string = await find.by_name_and_type("*.sh", "f", ".");\n  println(files);\n  return 0;\n}'
))

examples.append(e(
    "Find files not modified in the last 30 days",
    'requires find;\n\nasync fn main() -> i64 {\n  files: string = await find.modified_before(2592000, "src/");\n  println(files);\n  return 0;\n}'
))

examples.append(e(
    "Find small files under 1KB",
    'requires find;\n\nasync fn main() -> i64 {\n  files: string = await find.by_max_size(1024, "src/");\n  println(files);\n  return 0;\n}'
))

# === GIT-BASED ===

examples.append(e(
    "Show git log of commits ahead of main",
    'requires git;\n\nfn main() -> i64 {\n  output: string = git.log("--oneline main..HEAD");\n  println(output);\n  return 0;\n}'
))

examples.append(e(
    "Show recent git log with dates",
    'requires git;\n\nfn main() -> i64 {\n  output: string = git.log("--oneline --format=%h %ai %s -10");\n  println(output);\n  return 0;\n}'
))

examples.append(e(
    "Show git status of the working tree",
    'requires git;\n\nfn main() -> i64 {\n  status: string = git.status();\n  println(status);\n  return 0;\n}'
))

examples.append(e(
    "Show git diff summary and recent commits",
    'requires git;\n\nfn main() -> i64 {\n  d: string = git.diff();\n  println(d);\n  println("---");\n  recent: string = git.log("--oneline -3");\n  println(recent);\n  return 0;\n}'
))

examples.append(e(
    "Show git log for a specific file",
    'requires git;\n\nfn main() -> i64 {\n  output: string = git.log("--oneline --all -- tests/test_base_branch.py");\n  println(output);\n  return 0;\n}'
))

examples.append(e(
    "Show the current branch name",
    'requires git;\n\nfn main() -> i64 {\n  branch: string = git.branch();\n  println(branch);\n  return 0;\n}'
))

examples.append(e(
    "Show the git diff of a specific file",
    'requires git;\n\nfn main() -> i64 {\n  d: string = git.diff();\n  println(d);\n  return 0;\n}'
))

examples.append(e(
    "Stage files and create a commit",
    'requires git;\n\nfn main() -> i64 {\n  git.add("src/main.py");\n  git.add("tests/test_main.py");\n  result: string = git.commit("Add main module with tests");\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "Checkout a branch",
    'requires git;\n\nfn main() -> i64 {\n  code: int = git.checkout("feature-branch");\n  println(f"checkout exit code: {code}");\n  return 0;\n}'
))

examples.append(e(
    "Stash changes and switch branches",
    'requires git;\n\nfn main() -> i64 {\n  stash_out: string = git.stash("push");\n  println(stash_out);\n  code: int = git.checkout("main");\n  println(f"checkout: {code}");\n  return 0;\n}'
))

examples.append(e(
    "Show commit history with grep filter",
    'requires git;\n\nfn main() -> i64 {\n  output: string = git.log("--all --oneline --grep=worker_pid");\n  println(output);\n  return 0;\n}'
))

examples.append(e(
    "Show recent commits across all branches since a date",
    'requires git;\n\nfn main() -> i64 {\n  output: string = git.log("--all --oneline --since=2026-03-10 --format=%h %ai %s");\n  println(output);\n  return 0;\n}'
))

examples.append(e(
    "Show full commit details for a specific hash",
    'requires git;\n\nfn main() -> i64 {\n  output: string = git.log("--format=%H %ai %s -1 abc1234");\n  println(output);\n  return 0;\n}'
))

examples.append(e(
    "Push changes to remote",
    'requires git;\n\nasync fn main() -> i64 {\n  result: string = await git.push("origin", "main");\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "Pull latest changes from remote",
    'requires git;\n\nasync fn main() -> i64 {\n  result: string = await git.pull("origin", "main");\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "Merge a feature branch into current branch",
    'requires git;\n\nfn main() -> i64 {\n  result: string = git.merge("feature-auth");\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "Rebase current branch onto upstream",
    'requires git;\n\nfn main() -> i64 {\n  result: string = git.rebase("main");\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "Show branch list and log of diverged commits",
    'requires git;\n\nfn main() -> i64 {\n  branches: string = git.branch();\n  println(branches);\n  ahead: string = git.log("--oneline origin/main..HEAD");\n  println(f"Ahead of main:\\n{ahead}");\n  return 0;\n}'
))

# === CARGO-BASED ===

examples.append(e(
    "Check if a Rust crate compiles",
    'requires cargo;\n\nasync fn main() -> i64 {\n  code: int = await cargo.check(".");\n  if code == 0 {\n    println("Check passed");\n  } else {\n    println("Check failed");\n  }\n  return code;\n}'
))

examples.append(e(
    "Run cargo tests for a project",
    'requires cargo;\n\nasync fn main() -> i64 {\n  code: int = await cargo.test(".");\n  if code == 0 {\n    println("All tests passed");\n  } else {\n    println("Some tests failed");\n  }\n  return code;\n}'
))

examples.append(e(
    "Build a Rust project",
    'requires cargo;\n\nasync fn main() -> i64 {\n  code: int = await cargo.build(".");\n  if code == 0 {\n    println("Build succeeded");\n  } else {\n    println("Build failed");\n  }\n  return code;\n}'
))

examples.append(e(
    "Run clippy lints on a Rust project",
    'requires cargo;\n\nasync fn main() -> i64 {\n  output: string = await cargo.clippy(".");\n  println(output);\n  return 0;\n}'
))

examples.append(e(
    "Format Rust code with cargo fmt",
    'requires cargo;\n\nasync fn main() -> i64 {\n  code: int = await cargo.fmt(".");\n  if code == 0 {\n    println("Code formatted");\n  } else {\n    println("Format failed");\n  }\n  return code;\n}'
))

examples.append(e(
    "Build and test a Rust project",
    'requires cargo;\n\nasync fn main() -> i64 {\n  build_code: int = await cargo.build(".");\n  if build_code != 0 {\n    println("Build failed");\n    return 1;\n  }\n  println("Build succeeded");\n  test_code: int = await cargo.test(".");\n  if test_code != 0 {\n    println("Tests failed");\n    return 1;\n  }\n  println("All tests passed");\n  return 0;\n}'
))

examples.append(e(
    "Run a Rust binary",
    'requires cargo;\n\nasync fn main() -> i64 {\n  output: string = await cargo.run(".", "--help");\n  println(output);\n  return 0;\n}'
))

examples.append(e(
    "Full Rust CI pipeline: check, clippy, test, fmt",
    'requires cargo;\nrequires log;\n\nasync fn main() -> i64 {\n  log.info("Running check...");\n  c: int = await cargo.check(".");\n  if c != 0 {\n    log.error("Check failed");\n    return 1;\n  }\n  log.info("Running clippy...");\n  lint: string = await cargo.clippy(".");\n  println(lint);\n  log.info("Running tests...");\n  t: int = await cargo.test(".");\n  if t != 0 {\n    log.error("Tests failed");\n    return 1;\n  }\n  log.info("Running fmt...");\n  f: int = await cargo.fmt(".");\n  log.info("CI complete");\n  return 0;\n}'
))

# === CURL/HTTP-BASED ===

examples.append(e(
    "Test if an API endpoint is accessible",
    'requires curl;\n\nasync fn main() -> i64 {\n  body: string = await curl.get("https://api.example.com/health");\n  println(f"Response: {body}");\n  return 0;\n}'
))

examples.append(e(
    "Send a JSON-RPC request to a Solana RPC endpoint",
    'requires curl;\n\nasync fn main() -> i64 {\n  body: string = await curl.post("http://localhost:8899", "{\\\"jsonrpc\\\":\\\"2.0\\\",\\\"id\\\":1,\\\"method\\\":\\\"getSlot\\\"}");\n  println(body);\n  return 0;\n}'
))

examples.append(e(
    "Check epoch info from a blockchain RPC",
    'requires curl;\n\nasync fn main() -> i64 {\n  body: string = await curl.post("https://rpc.example.com", "{\\\"jsonrpc\\\":\\\"2.0\\\",\\\"id\\\":1,\\\"method\\\":\\\"getEpochInfo\\\"}");\n  println(body);\n  return 0;\n}'
))

examples.append(e(
    "Download a file from a URL",
    'requires curl;\n\nasync fn main() -> i64 {\n  bytes: int = await curl.download("https://example.com/data.tar.gz", "/tmp/data.tar.gz");\n  println(f"Downloaded {bytes} bytes");\n  return 0;\n}'
))

examples.append(e(
    "Make an authenticated API request",
    'requires curl;\n\nasync fn main() -> i64 {\n  body: string = await curl.get_with_header("https://api.github.com/user", "Authorization: token ghp_xxxx");\n  println(body);\n  return 0;\n}'
))

examples.append(e(
    "Send a PUT request to update a resource",
    'requires curl;\n\nasync fn main() -> i64 {\n  body: string = await curl.put("https://api.example.com/users/1", "{\\\"name\\\":\\\"updated\\\"}");\n  println(body);\n  return 0;\n}'
))

examples.append(e(
    "Delete a resource via REST API",
    'requires curl;\n\nasync fn main() -> i64 {\n  body: string = await curl.delete("https://api.example.com/items/42");\n  println(f"Delete response: {body}");\n  return 0;\n}'
))

examples.append(e(
    "Query a GraphQL API",
    'requires curl;\n\nasync fn main() -> i64 {\n  query: string = "{\\\"query\\\": \\\"{ queryRecords { id } }\\\"}";\n  body: string = await curl.post("http://localhost:9473/api", query);\n  println(body);\n  return 0;\n}'
))

examples.append(e(
    "Check multiple API endpoints for health",
    'requires curl;\nrequires log;\n\nasync fn main() -> i64 {\n  r1: string = await curl.get("https://api.example.com/health");\n  log.info(f"API: {r1}");\n  r2: string = await curl.get("https://docs.example.com/");\n  log.info(f"Docs: {r2}");\n  r3: string = await curl.get("https://app.example.com/status");\n  log.info(f"App: {r3}");\n  return 0;\n}'
))

# === DOCKER-BASED ===

examples.append(e(
    "List running Docker containers",
    'requires docker;\n\nfn main() -> i64 {\n  output: string = docker.ps("");\n  println(output);\n  return 0;\n}'
))

examples.append(e(
    "Get logs from a Docker container",
    'requires docker;\n\nfn main() -> i64 {\n  output: string = docker.logs("my-validator-1");\n  println(output);\n  return 0;\n}'
))

examples.append(e(
    "List Docker images",
    'requires docker;\n\nfn main() -> i64 {\n  output: string = docker.images("");\n  println(output);\n  return 0;\n}'
))

examples.append(e(
    "Execute a command inside a running Docker container",
    'requires docker;\n\nfn main() -> i64 {\n  output: string = docker.exec("my-db-1", "psql -U admin -c SELECT 1");\n  println(output);\n  return 0;\n}'
))

examples.append(e(
    "Stop and remove a Docker container",
    'requires docker;\n\nfn main() -> i64 {\n  docker.stop("old-container");\n  docker.rm("old-container");\n  println("Container removed");\n  return 0;\n}'
))

examples.append(e(
    "Build a Docker image",
    'requires docker;\n\nasync fn main() -> i64 {\n  result: string = await docker.build(".", "myapp:latest");\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "Run a one-off Docker container",
    'requires docker;\n\nfn main() -> i64 {\n  output: string = docker.run("alpine:latest", "echo hello");\n  println(output);\n  return 0;\n}'
))

examples.append(e(
    "Check Docker container status and get logs",
    'requires docker;\n\nfn main() -> i64 {\n  ps_out: string = docker.ps("-a");\n  println(ps_out);\n  println("---");\n  logs: string = docker.logs("web-server");\n  println(logs);\n  return 0;\n}'
))

# === GH (GitHub CLI) ===

examples.append(e(
    "Create a GitHub pull request",
    'requires gh;\n\nasync fn main() -> i64 {\n  result: string = await gh.pr_create("Fix login bug", "Resolves issue #42. Updates auth middleware to handle expired tokens.");\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "List open GitHub pull requests",
    'requires gh;\n\nasync fn main() -> i64 {\n  prs: string = await gh.pr_list("open");\n  println(prs);\n  return 0;\n}'
))

examples.append(e(
    "View details of a specific pull request",
    'requires gh;\n\nasync fn main() -> i64 {\n  pr: string = await gh.pr_view(8);\n  println(pr);\n  return 0;\n}'
))

examples.append(e(
    "Create a GitHub issue",
    'requires gh;\n\nasync fn main() -> i64 {\n  result: string = await gh.issue_create("Bug: login fails with expired token", "Steps to reproduce: 1. Wait for token expiry 2. Try to login 3. See 500 error");\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "List open GitHub issues",
    'requires gh;\n\nasync fn main() -> i64 {\n  issues: string = await gh.issue_list("open");\n  println(issues);\n  return 0;\n}'
))

examples.append(e(
    "Check GitHub Actions CI run status",
    'requires gh;\n\nasync fn main() -> i64 {\n  runs: string = await gh.run_list("ci.yml");\n  println(runs);\n  return 0;\n}'
))

examples.append(e(
    "View details of a specific CI run",
    'requires gh;\n\nasync fn main() -> i64 {\n  run: string = await gh.run_view(12345);\n  println(run);\n  return 0;\n}'
))

examples.append(e(
    "Clone a GitHub repository",
    'requires gh;\n\nasync fn main() -> i64 {\n  code: int = await gh.repo_clone("org/repo", "/tmp/repo");\n  println(f"Clone exit code: {code}");\n  return 0;\n}'
))

# === PYTHON3-BASED ===

examples.append(e(
    "Syntax check Python files using ast.parse",
    'requires python3;\n\nfn main() -> i64 {\n  r1: string = python3.exec("import ast; ast.parse(open(\'src/main.py\').read()); print(\'OK\')");\n  println(f"main.py: {r1}");\n  r2: string = python3.exec("import ast; ast.parse(open(\'src/config.py\').read()); print(\'OK\')");\n  println(f"config.py: {r2}");\n  return 0;\n}'
))

examples.append(e(
    "Run a Python test suite",
    'requires python3;\n\nasync fn main() -> i64 {\n  output: string = await python3.run_module("pytest", "tests/ -v --tb=short");\n  println(output);\n  return 0;\n}'
))

examples.append(e(
    "Evaluate a Python expression",
    'requires python3;\n\nfn main() -> i64 {\n  result: string = python3.eval("2 ** 32");\n  println(f"2^32 = {result}");\n  return 0;\n}'
))

examples.append(e(
    "Check Python version",
    'requires python3;\n\nfn main() -> i64 {\n  ver: string = python3.version();\n  println(f"Python version: {ver}");\n  return 0;\n}'
))

examples.append(e(
    "Run a Python script file",
    'requires python3;\n\nasync fn main() -> i64 {\n  output: string = await python3.run_script("scripts/check-status.py");\n  println(output);\n  return 0;\n}'
))

examples.append(e(
    "Install a Python package",
    'requires python3;\n\nasync fn main() -> i64 {\n  output: string = await python3.pip_install("requests");\n  println(output);\n  return 0;\n}'
))

examples.append(e(
    "List installed Python packages",
    'requires python3;\n\nfn main() -> i64 {\n  packages: string = python3.pip_list();\n  println(packages);\n  return 0;\n}'
))

examples.append(e(
    "Execute inline Python code to parse JSON",
    'requires python3;\nrequires fs;\n\nfn main() -> i64 {\n  result: string = python3.exec("import json; data = json.loads(\'{\\\"key\\\": \\\"value\\\"}\'); print(data[\'key\'])");\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "Run Python linter on source files",
    'requires python3;\n\nasync fn main() -> i64 {\n  output: string = await python3.run_module("ruff", "check src/");\n  println(output);\n  return 0;\n}'
))

examples.append(e(
    "Run Python formatter check",
    'requires python3;\n\nasync fn main() -> i64 {\n  output: string = await python3.run_module("ruff", "format --check src/");\n  println(output);\n  return 0;\n}'
))

examples.append(e(
    "Run a specific Python test class",
    'requires python3;\n\nasync fn main() -> i64 {\n  output: string = await python3.run_module("pytest", "tests/test_dispatcher.py::TestPlanStatus -v");\n  println(output);\n  return 0;\n}'
))

# === FS (Filesystem) ===

examples.append(e(
    "Write a file and read it back",
    'requires fs;\n\nfn main() -> i64 {\n  fs.write_file("/tmp/test.txt", "Hello from Mog!");\n  contents: string = fs.read_file("/tmp/test.txt");\n  println(f"Contents: {contents}");\n  fs.remove("/tmp/test.txt");\n  return 0;\n}'
))

examples.append(e(
    "Check if a file exists",
    'requires fs;\n\nfn main() -> i64 {\n  exists: bool = fs.exists("config.yaml");\n  if exists {\n    println("Config file found");\n  } else {\n    println("Config file not found");\n  }\n  return 0;\n}'
))

examples.append(e(
    "Get file size in bytes",
    'requires fs;\n\nfn main() -> i64 {\n  sz: int = fs.file_size("data/output.csv");\n  println(f"File size: {sz} bytes");\n  return 0;\n}'
))

examples.append(e(
    "Append text to a log file",
    'requires fs;\n\nfn main() -> i64 {\n  fs.append_file("/tmp/app.log", "Application started\\n");\n  println("Log entry added");\n  return 0;\n}'
))

examples.append(e(
    "Read a configuration file and display its contents",
    'requires fs;\n\nfn main() -> i64 {\n  contents: string = fs.read_file("config.yaml");\n  println(contents);\n  return 0;\n}'
))

examples.append(e(
    "Delete a temporary file",
    'requires fs;\n\nfn main() -> i64 {\n  fs.remove("/tmp/generator_raw_output.txt");\n  println("File deleted");\n  return 0;\n}'
))

examples.append(e(
    "Create a file with structured content",
    'requires fs;\n\nfn main() -> i64 {\n  content: string = "name: test\\nversion: 1.0\\ndescription: A test project\\n";\n  fs.write_file("project.yaml", content);\n  println("Project file created");\n  return 0;\n}'
))

examples.append(e(
    "Copy file contents from one location to another",
    'requires fs;\n\nfn main() -> i64 {\n  contents: string = fs.read_file("src/template.txt");\n  fs.write_file("/tmp/template-copy.txt", contents);\n  println("File copied");\n  return 0;\n}'
))

# === PROCESS ===

examples.append(e(
    "Get current working directory",
    'requires process;\n\nfn main() -> i64 {\n  cwd: string = process.cwd();\n  println(f"CWD: {cwd}");\n  return 0;\n}'
))

examples.append(e(
    "Read an environment variable",
    'requires process;\n\nfn main() -> i64 {\n  home: string = process.getenv("HOME");\n  println(f"HOME: {home}");\n  return 0;\n}'
))

examples.append(e(
    "Get current timestamp",
    'requires process;\n\nfn main() -> i64 {\n  ts: int = process.timestamp();\n  println(f"Timestamp: {ts} ms");\n  return 0;\n}'
))

examples.append(e(
    "Sleep for a specified duration",
    'requires process;\n\nasync fn main() -> i64 {\n  println("Waiting 5 seconds...");\n  await process.sleep(5000);\n  println("Done waiting");\n  return 0;\n}'
))

examples.append(e(
    "Measure execution time of an operation",
    'requires process;\nrequires fs;\n\nasync fn main() -> i64 {\n  t1: int = process.timestamp();\n  contents: string = fs.read_file("large-data.txt");\n  t2: int = process.timestamp();\n  elapsed: int = t2 - t1;\n  println(f"Read took {elapsed}ms");\n  return 0;\n}'
))

examples.append(e(
    "Check if PATH environment variable is set",
    'requires process;\n\nfn main() -> i64 {\n  path: string = process.getenv("PATH");\n  println(f"PATH: {path}");\n  return 0;\n}'
))

# === JQ (JSON Processing) ===

examples.append(e(
    "Extract a field from a JSON string",
    'requires jq;\n\nfn main() -> i64 {\n  json: string = "{\\\"name\\\":\\\"test\\\",\\\"version\\\":2}";\n  result: string = jq.query(".name", json);\n  println(f"Name: {result}");\n  return 0;\n}'
))

examples.append(e(
    "Filter a JSON array by a condition",
    'requires jq;\n\nfn main() -> i64 {\n  json: string = "[{\\\"status\\\":\\\"active\\\"},{\\\"status\\\":\\\"done\\\"},{\\\"status\\\":\\\"active\\\"}]";\n  result: string = jq.filter("select(.status == \\\"active\\\")", json);\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "Extract all keys from a JSON object",
    'requires jq;\n\nfn main() -> i64 {\n  json: string = "{\\\"name\\\":\\\"test\\\",\\\"version\\\":1,\\\"author\\\":\\\"dev\\\"}";\n  keys: string = jq.keys(json);\n  println(f"Keys: {keys}");\n  return 0;\n}'
))

examples.append(e(
    "Transform JSON using a mapping expression",
    'requires jq;\n\nfn main() -> i64 {\n  json: string = "[{\\\"id\\\":1,\\\"name\\\":\\\"alice\\\"},{\\\"id\\\":2,\\\"name\\\":\\\"bob\\\"}]";\n  result: string = jq.transform(".[] | {user: .name, uid: .id}", json);\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "Extract values from a JSON object",
    'requires jq;\n\nfn main() -> i64 {\n  json: string = "{\\\"a\\\":1,\\\"b\\\":2,\\\"c\\\":3}";\n  vals: string = jq.values(json);\n  println(f"Values: {vals}");\n  return 0;\n}'
))

examples.append(e(
    "Parse JSON from a file and extract data",
    'requires jq;\nrequires fs;\n\nfn main() -> i64 {\n  json: string = fs.read_file("data.json");\n  result: string = jq.query(".results[0].name", json);\n  println(f"First result: {result}");\n  return 0;\n}'
))

# === YQ (YAML Processing) ===

examples.append(e(
    "Extract a value from YAML by path",
    'requires yq;\nrequires fs;\n\nfn main() -> i64 {\n  yaml: string = fs.read_file("config.yaml");\n  val: string = yq.get(yaml, ".database.host");\n  println(f"DB host: {val}");\n  return 0;\n}'
))

examples.append(e(
    "Convert YAML to JSON",
    'requires yq;\nrequires fs;\n\nfn main() -> i64 {\n  yaml: string = fs.read_file("config.yaml");\n  json: string = yq.to_json(yaml);\n  println(json);\n  return 0;\n}'
))

examples.append(e(
    "Convert JSON to YAML",
    'requires yq;\n\nfn main() -> i64 {\n  json: string = "{\\\"name\\\":\\\"test\\\",\\\"version\\\":1}";\n  yaml: string = yq.from_json(json);\n  println(yaml);\n  return 0;\n}'
))

examples.append(e(
    "Set a value in a YAML document",
    'requires yq;\nrequires fs;\n\nfn main() -> i64 {\n  yaml: string = fs.read_file("config.yaml");\n  updated: string = yq.set(yaml, ".database.port", "5433");\n  fs.write_file("config.yaml", updated);\n  println("Port updated");\n  return 0;\n}'
))

examples.append(e(
    "Delete a key from a YAML document",
    'requires yq;\nrequires fs;\n\nfn main() -> i64 {\n  yaml: string = fs.read_file("config.yaml");\n  updated: string = yq.delete_key(yaml, ".deprecated_field");\n  fs.write_file("config.yaml", updated);\n  println("Key deleted");\n  return 0;\n}'
))

examples.append(e(
    "Query a YAML document with a yq expression",
    'requires yq;\nrequires fs;\n\nfn main() -> i64 {\n  yaml: string = fs.read_file("deployment.yaml");\n  result: string = yq.query(yaml, ".spec.template.spec.containers[0].image");\n  println(f"Image: {result}");\n  return 0;\n}'
))

# === SED (Text Transformation) ===

examples.append(e(
    "Replace a pattern in a string",
    'requires sed;\n\nfn main() -> i64 {\n  text: string = "hello world";\n  result: string = sed.substitute("world", "mog", text);\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "Replace all occurrences of a pattern in a string",
    'requires sed;\n\nfn main() -> i64 {\n  text: string = "foo bar foo baz foo";\n  result: string = sed.substitute_all("foo", "qux", text);\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "Delete lines matching a pattern from text",
    'requires sed;\nrequires fs;\n\nfn main() -> i64 {\n  text: string = fs.read_file("config.txt");\n  cleaned: string = sed.delete_matching("^#", text);\n  println(cleaned);\n  return 0;\n}'
))

examples.append(e(
    "Replace a pattern in a file",
    'requires sed;\n\nfn main() -> i64 {\n  result: string = sed.substitute_in_file("old_name", "new_name", "src/config.py");\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "Insert a line before a matching pattern",
    'requires sed;\nrequires fs;\n\nfn main() -> i64 {\n  text: string = fs.read_file("Makefile");\n  updated: string = sed.insert_before("^build:", "# Build target", text);\n  println(updated);\n  return 0;\n}'
))

examples.append(e(
    "Extract lines between two patterns",
    'requires sed;\nrequires fs;\n\nfn main() -> i64 {\n  text: string = fs.read_file("log.txt");\n  section: string = sed.extract_range("BEGIN SECTION", "END SECTION", text);\n  println(section);\n  return 0;\n}'
))

examples.append(e(
    "Replace all occurrences in a file",
    'requires sed;\n\nfn main() -> i64 {\n  result: string = sed.substitute_all_in_file("localhost", "production.host.com", "config/database.yml");\n  println(result);\n  return 0;\n}'
))

# === AWK (Text Processing) ===

examples.append(e(
    "Extract a specific column from delimited text",
    'requires awk;\nrequires fs;\n\nfn main() -> i64 {\n  text: string = fs.read_file("data.csv");\n  names: string = awk.field(1, ",", text);\n  println(names);\n  return 0;\n}'
))

examples.append(e(
    "Sum values in a column of CSV data",
    'requires awk;\nrequires fs;\n\nfn main() -> i64 {\n  text: string = fs.read_file("sales.csv");\n  total: float = awk.sum_field(3, ",", text);\n  print_string("Total: ");\n  print_f64(total);\n  println("");\n  return 0;\n}'
))

examples.append(e(
    "Count lines matching a pattern in text",
    'requires awk;\nrequires fs;\n\nfn main() -> i64 {\n  text: string = fs.read_file("access.log");\n  n: int = awk.count_matching("ERROR", text);\n  println(f"Error count: {n}");\n  return 0;\n}'
))

examples.append(e(
    "Get unique values from a field",
    'requires awk;\nrequires fs;\n\nfn main() -> i64 {\n  text: string = fs.read_file("users.csv");\n  roles: string = awk.unique_field(3, ",", text);\n  println(f"Unique roles: {roles}");\n  return 0;\n}'
))

examples.append(e(
    "Filter lines matching a pattern",
    'requires awk;\nrequires fs;\n\nfn main() -> i64 {\n  text: string = fs.read_file("access.log");\n  errors: string = awk.filter("500", text);\n  println(errors);\n  return 0;\n}'
))

examples.append(e(
    "Count the number of fields in a line",
    'requires awk;\n\nfn main() -> i64 {\n  text: string = "name,age,email,role";\n  n: int = awk.field_count(",", text);\n  println(f"Fields: {n}");\n  return 0;\n}'
))

examples.append(e(
    "Extract multiple columns from TSV data",
    'requires awk;\nrequires fs;\n\nfn main() -> i64 {\n  text: string = fs.read_file("data.tsv");\n  selected: string = awk.fields("1,3,5", "\\t", text);\n  println(selected);\n  return 0;\n}'
))

# === LOG CAPABILITY ===

examples.append(e(
    "Log messages at different severity levels",
    'requires log;\n\nfn main() -> i64 {\n  log.info("Application starting");\n  log.debug("Loading configuration");\n  log.warn("Deprecated API version detected");\n  log.error("Failed to connect to database");\n  return 0;\n}'
))

examples.append(e(
    "Log progress during a file processing task",
    'requires log;\nrequires find;\n\nasync fn main() -> i64 {\n  log.info("Scanning for Python files...");\n  files: string = await find.by_name("*.py", "src/");\n  log.info(f"Found files: {files}");\n  log.info("Scan complete");\n  return 0;\n}'
))

# === MATH CAPABILITY ===

examples.append(e(
    "Perform basic arithmetic operations",
    'requires math;\n\nfn main() -> i64 {\n  sum: int = math.add(42, 13);\n  println(f"42 + 13 = {sum}");\n  prod: int = math.multiply(6, 7);\n  println(f"6 * 7 = {prod}");\n  diff: int = math.subtract(100, 37);\n  println(f"100 - 37 = {diff}");\n  quot: int = math.divide(144, 12);\n  println(f"144 / 12 = {quot}");\n  return 0;\n}'
))

examples.append(e(
    "Find min and max of two values",
    'requires math;\n\nfn main() -> i64 {\n  mx: int = math.max(42, 99);\n  mn: int = math.min(42, 99);\n  println(f"max(42, 99) = {mx}");\n  println(f"min(42, 99) = {mn}");\n  return 0;\n}'
))

examples.append(e(
    "Compute absolute value",
    'requires math;\n\nfn main() -> i64 {\n  a: int = math.abs(-42);\n  println(f"abs(-42) = {a}");\n  b: int = math.abs(42);\n  println(f"abs(42) = {b}");\n  return 0;\n}'
))

# === TIMER CAPABILITY ===

examples.append(e(
    "Set a timeout and wait",
    'requires timer;\n\nasync fn main() -> i64 {\n  println("Starting timer...");\n  result: int = await timer.setTimeout(1000);\n  println(f"Timer completed: {result}");\n  return 0;\n}'
))

# === ENV CAPABILITY ===

examples.append(e(
    "Get host environment information",
    'requires env;\n\nasync fn main() -> i64 {\n  name: ptr = await env.get_name();\n  println(f"Host: {name}");\n  ver: int = await env.get_version();\n  println(f"Version: {ver}");\n  ts: int = await env.timestamp();\n  println(f"Timestamp: {ts}");\n  return 0;\n}'
))

examples.append(e(
    "Generate a random number in a range",
    'requires env;\n\nasync fn main() -> i64 {\n  rnd: int = await env.random(1, 100);\n  println(f"Random: {rnd}");\n  return 0;\n}'
))

# === HTTP CAPABILITY ===

examples.append(e(
    "Make an HTTP GET request",
    'requires http;\n\nasync fn main() -> i64 {\n  body: string = await http.get("https://httpbin.org/get");\n  println(body);\n  return 0;\n}'
))

examples.append(e(
    "Make an HTTP POST request with JSON body",
    'requires http;\n\nasync fn main() -> i64 {\n  body: string = await http.post("https://httpbin.org/post", "{\\\"key\\\":\\\"value\\\"}");\n  println(body);\n  return 0;\n}'
))

# === MULTI-CAPABILITY COMBINATIONS ===

examples.append(e(
    "Find Python files and search for a pattern in them",
    'requires find;\nrequires grep;\n\nasync fn main() -> i64 {\n  files: string = await find.by_name_and_type("*.py", "f", "src/");\n  println("Python files:");\n  println(files);\n  println("---");\n  matches: string = await grep.search_recursive("def main", "src/");\n  println("Files with main:");\n  println(matches);\n  return 0;\n}'
))

examples.append(e(
    "Read a config file and validate it has required keys",
    'requires fs;\nrequires grep;\n\nfn main() -> i64 {\n  exists: bool = fs.exists("config.yaml");\n  if exists {\n    contents: string = fs.read_file("config.yaml");\n    result: string = grep.search("database:", "config.yaml");\n    println(f"Database config: {result}");\n  } else {\n    println("Config file not found!");\n  }\n  return 0;\n}'
))

examples.append(e(
    "Download a file and verify it was saved",
    'requires curl;\nrequires fs;\n\nasync fn main() -> i64 {\n  bytes: int = await curl.download("https://example.com/data.json", "/tmp/data.json");\n  println(f"Downloaded {bytes} bytes");\n  exists: bool = fs.exists("/tmp/data.json");\n  if exists {\n    sz: int = fs.file_size("/tmp/data.json");\n    println(f"Verified: {sz} bytes on disk");\n  }\n  return 0;\n}'
))

examples.append(e(
    "Run cargo tests and log the result",
    'requires cargo;\nrequires log;\n\nasync fn main() -> i64 {\n  log.info("Starting test suite...");\n  code: int = await cargo.test(".");\n  if code == 0 {\n    log.info("All tests passed!");\n  } else {\n    log.error("Tests failed!");\n  }\n  return code;\n}'
))

examples.append(e(
    "Check git status and run tests if clean",
    'requires git;\nrequires python3;\n\nasync fn main() -> i64 {\n  status: string = git.status();\n  println(f"Git status: {status}");\n  output: string = await python3.run_module("pytest", "tests/ -q");\n  println(output);\n  return 0;\n}'
))

examples.append(e(
    "Read a JSON file, transform it, and write the result",
    'requires fs;\nrequires jq;\n\nfn main() -> i64 {\n  json: string = fs.read_file("input.json");\n  result: string = jq.transform(".[] | {name, score}", json);\n  fs.write_file("output.json", result);\n  println("Transform complete");\n  return 0;\n}'
))

examples.append(e(
    "Search for errors in logs and count them",
    'requires grep;\nrequires log;\n\nfn main() -> i64 {\n  n: int = grep.count("ERROR", "/var/log/app.log");\n  log.info(f"Found {n} errors");\n  if n > 0 {\n    errors: string = grep.search("ERROR", "/var/log/app.log");\n    log.warn(f"Error details:\\n{errors}");\n  }\n  return 0;\n}'
))

examples.append(e(
    "Measure API response time",
    'requires curl;\nrequires process;\n\nasync fn main() -> i64 {\n  t1: int = process.timestamp();\n  body: string = await curl.get("https://api.example.com/health");\n  t2: int = process.timestamp();\n  elapsed: int = t2 - t1;\n  println(f"Response time: {elapsed}ms");\n  println(f"Response: {body}");\n  return 0;\n}'
))

examples.append(e(
    "Read YAML config and extract database settings",
    'requires yq;\nrequires fs;\nrequires log;\n\nfn main() -> i64 {\n  yaml: string = fs.read_file("config.yaml");\n  host: string = yq.get(yaml, ".database.host");\n  port: string = yq.get(yaml, ".database.port");\n  db: string = yq.get(yaml, ".database.name");\n  log.info(f"DB: {host}:{port}/{db}");\n  return 0;\n}'
))

examples.append(e(
    "Create a PR after running tests",
    'requires cargo;\nrequires git;\nrequires gh;\n\nasync fn main() -> i64 {\n  test_code: int = await cargo.test(".");\n  if test_code != 0 {\n    println("Tests failed, not creating PR");\n    return 1;\n  }\n  result: string = await gh.pr_create("Implement feature X", "All tests pass. Ready for review.");\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "Process CSV data: extract column and compute sum",
    'requires fs;\nrequires awk;\n\nfn main() -> i64 {\n  data: string = fs.read_file("sales.csv");\n  amounts: string = awk.field(3, ",", data);\n  println(f"Amounts:\\n{amounts}");\n  total: float = awk.sum_field(3, ",", data);\n  print_string("Total: ");\n  print_f64(total);\n  println("");\n  return 0;\n}'
))

examples.append(e(
    "Replace all occurrences of a host in config files",
    'requires sed;\nrequires log;\n\nfn main() -> i64 {\n  log.info("Updating host references...");\n  r1: string = sed.substitute_all_in_file("localhost", "prod.example.com", "config/app.yaml");\n  r2: string = sed.substitute_all_in_file("localhost", "prod.example.com", "config/database.yaml");\n  log.info("Host references updated");\n  return 0;\n}'
))

examples.append(e(
    "Find large files and report their sizes",
    'requires find;\nrequires fs;\nrequires log;\n\nasync fn main() -> i64 {\n  files: string = await find.by_min_size(10485760, ".");\n  log.info(f"Files over 10MB:\\n{files}");\n  return 0;\n}'
))

examples.append(e(
    "Build a Docker image and check its listing",
    'requires docker;\nrequires log;\n\nasync fn main() -> i64 {\n  log.info("Building Docker image...");\n  result: string = await docker.build(".", "myapp:latest");\n  println(result);\n  images: string = docker.images("myapp");\n  println(images);\n  return 0;\n}'
))

examples.append(e(
    "Check GitHub CI status and view failing run",
    'requires gh;\nrequires log;\n\nasync fn main() -> i64 {\n  runs: string = await gh.run_list("ci.yml");\n  log.info(f"CI runs:\\n{runs}");\n  details: string = await gh.run_view(1234);\n  println(details);\n  return 0;\n}'
))

examples.append(e(
    "Read environment variables and write them to a file",
    'requires process;\nrequires fs;\n\nfn main() -> i64 {\n  home: string = process.getenv("HOME");\n  user: string = process.getenv("USER");\n  path: string = process.getenv("PATH");\n  content: string = f"HOME={home}\\nUSER={user}\\nPATH={path}\\n";\n  fs.write_file("/tmp/env-snapshot.txt", content);\n  println("Environment snapshot saved");\n  return 0;\n}'
))

examples.append(e(
    "Clone a repo, find source files, and count lines",
    'requires gh;\nrequires find;\nrequires grep;\n\nasync fn main() -> i64 {\n  code: int = await gh.repo_clone("org/tool", "/tmp/tool");\n  println(f"Clone: {code}");\n  files: string = await find.by_name_and_type("*.py", "f", "/tmp/tool/src/");\n  println(f"Source files:\\n{files}");\n  return 0;\n}'
))

examples.append(e(
    "Fetch JSON API data and extract a value",
    'requires curl;\nrequires jq;\n\nasync fn main() -> i64 {\n  body: string = await curl.get("https://api.github.com/repos/rust-lang/rust");\n  stars: string = jq.query(".stargazers_count", body);\n  name: string = jq.query(".full_name", body);\n  println(f"{name}: {stars} stars");\n  return 0;\n}'
))

examples.append(e(
    "Read a YAML spec file and convert to JSON",
    'requires fs;\nrequires yq;\nrequires log;\n\nfn main() -> i64 {\n  exists: bool = fs.exists("spec.yml");\n  if exists {\n    yaml: string = fs.read_file("spec.yml");\n    json: string = yq.to_json(yaml);\n    fs.write_file("spec.json", json);\n    log.info("Converted spec.yml to spec.json");\n  } else {\n    log.error("spec.yml not found");\n  }\n  return 0;\n}'
))

examples.append(e(
    "Timed file write and read benchmark",
    'requires fs;\nrequires process;\n\nasync fn main() -> i64 {\n  data: string = "benchmark data line\\n";\n  t1: int = process.timestamp();\n  i: i64 = 0;\n  while (i < 100) {\n    fs.append_file("/tmp/bench.txt", data);\n    i := i + 1;\n  }\n  t2: int = process.timestamp();\n  elapsed: int = t2 - t1;\n  println(f"100 writes took {elapsed}ms");\n  sz: int = fs.file_size("/tmp/bench.txt");\n  println(f"Final size: {sz} bytes");\n  fs.remove("/tmp/bench.txt");\n  return 0;\n}'
))

examples.append(e(
    "Full project validation: lint, test, and check for TODOs",
    'requires python3;\nrequires grep;\nrequires log;\n\nasync fn main() -> i64 {\n  log.info("Running linter...");\n  lint: string = await python3.run_module("ruff", "check src/");\n  println(lint);\n  log.info("Running tests...");\n  test: string = await python3.run_module("pytest", "tests/ -q");\n  println(test);\n  log.info("Checking for TODOs...");\n  todos: string = await grep.search_recursive("TODO|FIXME", "src/");\n  println(f"TODOs found:\\n{todos}");\n  return 0;\n}'
))

examples.append(e(
    "Parse Docker container logs and search for errors",
    'requires docker;\nrequires grep;\nrequires log;\n\nfn main() -> i64 {\n  logs: string = docker.logs("my-app-1");\n  n: int = grep.count("ERROR", "/tmp/app.log");\n  log.info(f"Container errors: {n}");\n  return 0;\n}'
))

examples.append(e(
    "Check git branch, commit, and push to remote",
    'requires git;\nrequires log;\n\nasync fn main() -> i64 {\n  branch: string = git.branch();\n  log.info(f"On branch: {branch}");\n  git.add("src/feature.py");\n  result: string = git.commit("Add feature implementation");\n  log.info(f"Committed: {result}");\n  push_result: string = await git.push("origin", "feature-branch");\n  log.info(f"Pushed: {push_result}");\n  return 0;\n}'
))

examples.append(e(
    "Delete matching lines from a config and write back",
    'requires sed;\nrequires fs;\n\nfn main() -> i64 {\n  text: string = fs.read_file("config.ini");\n  cleaned: string = sed.delete_matching("^;.*$", text);\n  cleaned2: string = sed.delete_matching("^$", cleaned);\n  fs.write_file("config-clean.ini", cleaned2);\n  println("Comments and blank lines removed");\n  return 0;\n}'
))

examples.append(e(
    "Collect project statistics: files, lines, test count",
    'requires find;\nrequires grep;\n\nasync fn main() -> i64 {\n  py_count: int = await find.count("*.py", "src/");\n  println(f"Python files: {py_count}");\n  test_count: int = await find.count("test_*.py", "tests/");\n  println(f"Test files: {test_count}");\n  todo_files: string = grep.files_matching("TODO", "src/");\n  println(f"Files with TODOs:\\n{todo_files}");\n  return 0;\n}'
))

examples.append(e(
    "Insert a header comment before each function in a file",
    'requires sed;\nrequires fs;\n\nfn main() -> i64 {\n  text: string = fs.read_file("main.py");\n  updated: string = sed.insert_before("^def ", "# ---", text);\n  fs.write_file("main.py", updated);\n  println("Headers inserted");\n  return 0;\n}'
))

examples.append(e(
    "Poll an API endpoint with delay between requests",
    'requires curl;\nrequires process;\nrequires log;\n\nasync fn main() -> i64 {\n  i: i64 = 0;\n  while (i < 3) {\n    body: string = await curl.get("https://api.example.com/status");\n    log.info(f"Check {i}: {body}");\n    await process.sleep(2000);\n    i := i + 1;\n  }\n  return 0;\n}'
))

# === MORE DERIVED VARIATIONS ===

examples.append(e(
    "Search for all struct definitions in Rust source files",
    'requires grep;\n\nasync fn main() -> i64 {\n  results: string = await grep.search_recursive("^pub struct |^struct ", "src/");\n  println(results);\n  return 0;\n}'
))

examples.append(e(
    "Find all .env files in a project",
    'requires find;\n\nasync fn main() -> i64 {\n  files: string = await find.by_name(".env*", ".");\n  println(files);\n  return 0;\n}'
))

examples.append(e(
    "Search for async function signatures in a codebase",
    'requires grep;\n\nasync fn main() -> i64 {\n  results: string = await grep.search_recursive("async fn |async def ", "src/");\n  println(results);\n  return 0;\n}'
))

examples.append(e(
    "Find all lock files in a project",
    'requires find;\n\nasync fn main() -> i64 {\n  files: string = await find.by_name("*.lock", ".");\n  println(files);\n  return 0;\n}'
))

examples.append(e(
    "Check if a Rust workspace member compiles",
    'requires cargo;\nrequires log;\n\nasync fn main() -> i64 {\n  log.info("Checking workspace member...");\n  code: int = await cargo.check("crates/parser");\n  if code == 0 {\n    log.info("Parser crate compiles");\n  } else {\n    log.error("Parser crate has errors");\n  }\n  return code;\n}'
))

examples.append(e(
    "Search for panic calls in Rust source",
    'requires grep;\n\nasync fn main() -> i64 {\n  results: string = await grep.search_recursive("panic!|unwrap\\\\(\\\\)|expect\\\\(", "src/");\n  println(results);\n  return 0;\n}'
))

examples.append(e(
    "Find recently modified source files",
    'requires find;\n\nasync fn main() -> i64 {\n  files: string = await find.modified_within(86400, "src/");\n  println("Files modified in last 24h:");\n  println(files);\n  return 0;\n}'
))

examples.append(e(
    "Search for TODO comments and count them per file",
    'requires grep;\nrequires log;\n\nfn main() -> i64 {\n  files: string = grep.files_matching("TODO", "src/");\n  println(f"Files with TODOs:\\n{files}");\n  n: int = grep.count("TODO", "src/main.py");\n  log.info(f"TODOs in main.py: {n}");\n  return 0;\n}'
))

examples.append(e(
    "Write a JSON report file",
    'requires fs;\n\nfn main() -> i64 {\n  report: string = "{\\\"status\\\": \\\"complete\\\", \\\"tests_passed\\\": 42, \\\"errors\\\": 0}";\n  fs.write_file("/tmp/report.json", report);\n  println("Report written");\n  return 0;\n}'
))

examples.append(e(
    "Check multiple environment variables",
    'requires process;\nrequires log;\n\nfn main() -> i64 {\n  home: string = process.getenv("HOME");\n  user: string = process.getenv("USER");\n  shell: string = process.getenv("SHELL");\n  log.info(f"HOME={home}");\n  log.info(f"USER={user}");\n  log.info(f"SHELL={shell}");\n  return 0;\n}'
))

examples.append(e(
    "Send multiple HTTP requests and compare responses",
    'requires http;\nrequires log;\n\nasync fn main() -> i64 {\n  r1: string = await http.get("https://api.example.com/v1/status");\n  r2: string = await http.get("https://api.example.com/v2/status");\n  log.info(f"V1: {r1}");\n  log.info(f"V2: {r2}");\n  return 0;\n}'
))

examples.append(e(
    "Create a test file, verify it exists, then clean up",
    'requires fs;\nrequires log;\n\nfn main() -> i64 {\n  fs.write_file("/tmp/mog-test-cleanup.txt", "test data");\n  exists: bool = fs.exists("/tmp/mog-test-cleanup.txt");\n  if exists {\n    log.info("File created successfully");\n    sz: int = fs.file_size("/tmp/mog-test-cleanup.txt");\n    log.info(f"Size: {sz} bytes");\n    fs.remove("/tmp/mog-test-cleanup.txt");\n    log.info("Cleaned up");\n  } else {\n    log.error("File creation failed");\n  }\n  return 0;\n}'
))

examples.append(e(
    "Run a Python script with arguments",
    'requires python3;\n\nasync fn main() -> i64 {\n  output: string = await python3.run_script_args("scripts/migrate.py", "--dry-run --verbose");\n  println(output);\n  return 0;\n}'
))

examples.append(e(
    "List all git tags",
    'requires git;\n\nfn main() -> i64 {\n  output: string = git.log("--tags --oneline --decorate");\n  println(output);\n  return 0;\n}'
))

examples.append(e(
    "Stage all changes and commit",
    'requires git;\n\nfn main() -> i64 {\n  git.add(".");\n  result: string = git.commit("Update configuration");\n  println(result);\n  return 0;\n}'
))

examples.append(e(
    "Pop a stash and verify status",
    'requires git;\n\nfn main() -> i64 {\n  stash: string = git.stash("pop");\n  println(stash);\n  status: string = git.status();\n  println(status);\n  return 0;\n}'
))

examples.append(e(
    "Read a YAML deployment file and check image version",
    'requires yq;\nrequires fs;\nrequires log;\n\nfn main() -> i64 {\n  yaml: string = fs.read_file("deployment.yaml");\n  image: string = yq.get(yaml, ".spec.template.spec.containers[0].image");\n  log.info(f"Current image: {image}");\n  replicas: string = yq.get(yaml, ".spec.replicas");\n  log.info(f"Replicas: {replicas}");\n  return 0;\n}'
))

examples.append(e(
    "Transform CSV to a custom format using awk",
    'requires awk;\nrequires fs;\n\nfn main() -> i64 {\n  data: string = fs.read_file("users.csv");\n  formatted: string = awk.format_fields("{name}: {email}", ",", data);\n  println(formatted);\n  return 0;\n}'
))

examples.append(e(
    "Insert a line after a matching pattern",
    'requires sed;\nrequires fs;\n\nfn main() -> i64 {\n  text: string = fs.read_file("config.ini");\n  updated: string = sed.insert_after("\\\\[database\\\\]", "timeout=30", text);\n  fs.write_file("config.ini", updated);\n  println("Timeout setting added");\n  return 0;\n}'
))

examples.append(e(
    "Use the math capability for factorial computation",
    'requires math;\n\nfn factorial(n: int) -> int {\n  if n <= 1 {\n    return 1;\n  }\n  return math.multiply(n, factorial(math.subtract(n, 1)));\n}\n\nfn main() -> i64 {\n  result: int = factorial(5);\n  println(f"5! = {result}");\n  return 0;\n}'
))

examples.append(e(
    "Read file, substitute text, and write back",
    'requires fs;\nrequires sed;\n\nfn main() -> i64 {\n  text: string = fs.read_file("README.md");\n  updated: string = sed.substitute_all("v1.0", "v2.0", text);\n  fs.write_file("README.md", updated);\n  println("Version references updated");\n  return 0;\n}'
))

examples.append(e(
    "Async file I/O with timing",
    'requires fs;\nrequires process;\nrequires log;\n\nasync fn main() -> i64 {\n  t1: int = process.timestamp();\n  fs.write_file("/tmp/async-test.txt", "hello async world");\n  contents: string = fs.read_file("/tmp/async-test.txt");\n  t2: int = process.timestamp();\n  log.info(f"I/O took {t2 - t1}ms");\n  log.info(f"Read back: {contents}");\n  fs.remove("/tmp/async-test.txt");\n  return 0;\n}'
))

examples.append(e(
    "Search grep results and filter with awk",
    'requires grep;\nrequires awk;\n\nfn main() -> i64 {\n  lines: string = grep.search("ERROR", "/var/log/app.log");\n  timestamps: string = awk.field(1, " ", lines);\n  println(f"Error timestamps:\\n{timestamps}");\n  return 0;\n}'
))

examples.append(e(
    "Find empty directories in a project",
    'requires find;\n\nasync fn main() -> i64 {\n  dirs: string = await find.by_type("d", ".");\n  println(f"Directories:\\n{dirs}");\n  return 0;\n}'
))

examples.append(e(
    "Search for deprecated API usage",
    'requires grep;\nrequires log;\n\nasync fn main() -> i64 {\n  results: string = await grep.search_recursive("@deprecated|DEPRECATED|deprecated_function", "src/");\n  log.warn(f"Deprecated usage found:\\n{results}");\n  return 0;\n}'
))

examples.append(e(
    "Multiple git operations: branch, status, log",
    'requires git;\n\nfn main() -> i64 {\n  branch: string = git.branch();\n  println(f"Branch: {branch}");\n  status: string = git.status();\n  println(f"Status:\\n{status}");\n  log_out: string = git.log("--oneline -5");\n  println(f"Recent commits:\\n{log_out}");\n  return 0;\n}'
))

examples.append(e(
    "Docker health check: list containers and get logs from unhealthy ones",
    'requires docker;\nrequires log;\n\nfn main() -> i64 {\n  ps: string = docker.ps("-a");\n  log.info(f"Containers:\\n{ps}");\n  logs: string = docker.logs("unhealthy-service");\n  log.warn(f"Unhealthy service logs:\\n{logs}");\n  return 0;\n}'
))

examples.append(e(
    "Create a GitHub issue and list all open issues",
    'requires gh;\nrequires log;\n\nasync fn main() -> i64 {\n  result: string = await gh.issue_create("Performance regression in search", "Search endpoint P95 latency increased 3x after commit abc123");\n  log.info(f"Created: {result}");\n  issues: string = await gh.issue_list("open");\n  println(issues);\n  return 0;\n}'
))

examples.append(e(
    "Download and parse a JSON API response",
    'requires curl;\nrequires jq;\nrequires log;\n\nasync fn main() -> i64 {\n  body: string = await curl.get("https://api.github.com/repos/rust-lang/rust/releases/latest");\n  tag: string = jq.query(".tag_name", body);\n  name: string = jq.query(".name", body);\n  log.info(f"Latest release: {name} ({tag})");\n  return 0;\n}'
))

examples.append(e(
    "Convert between YAML and JSON formats",
    'requires yq;\nrequires fs;\nrequires log;\n\nfn main() -> i64 {\n  yaml: string = fs.read_file("config.yaml");\n  json: string = yq.to_json(yaml);\n  fs.write_file("config.json", json);\n  log.info("YAML -> JSON done");\n  roundtrip: string = yq.from_json(json);\n  fs.write_file("config-roundtrip.yaml", roundtrip);\n  log.info("JSON -> YAML roundtrip done");\n  return 0;\n}'
))

# Write output
with open(OUT, "w") as f:
    for ex in examples:
        f.write(json.dumps(ex) + "\n")

print(f"Wrote {len(examples)} examples to {OUT}")
