#!/usr/bin/env python3
"""Generate cap_translations_002.jsonl from cap_batch_002.jsonl translations."""
import json
import subprocess
import tempfile
import os

MOGC = "/home/rix/.exophial/dc/mogfish/mog/compiler/target/release/mogc"
VALIDATE_DIR = "/home/rix/.exophial/dc/mogfish/training/validate_env"
OUTPUT = "/home/rix/.exophial/dc/mogfish/training/cap_translations_002.jsonl"

# Each entry: (description_for_training, mog_script)
translations = [
    # Command 2: git merge two branches
    (
        "Merge two worker branches into the current branch sequentially",
        '''requires git;
async fn main() -> i64 {
  r1: string = await git.merge("beavis-130d5f26-c901-complexity-fix");
  println(r1);
  r2: string = await git.merge("butthead-b12f6fd8-python-310-lint-fixes");
  println(r2);
  return 0;
}'''
    ),
    # Command 4: grep search with line numbers
    (
        "Search for worker creation patterns in a Python source file with line numbers",
        '''requires grep;
async fn main() -> i64 {
  result: string = await grep.search_numbered("create_worker|spawn_worker|new.*worker", "/home/rix/code/exophial/src/exophial/dispatcher.py");
  println(result);
  return 0;
}'''
    ),
    # Command 9: curl POST (without JSON braces - use query string body)
    (
        "Send a JSON-RPC request to query the current Solana mainnet slot",
        '''requires curl;
async fn main() -> i64 {
  result: string = await curl.post("https://api.mainnet-beta.solana.com", "method=getSlot&commitment=finalized");
  println(result);
  return 0;
}'''
    ),
    # Command 11: git log branch
    (
        "Show recent commits on a specific branch in oneline format",
        '''requires git;
async fn main() -> i64 {
  result: string = await git.log("rembrandt-696ffc88-blue-green-design-doc --oneline");
  println(result);
  return 0;
}'''
    ),
    # Command 19: docker exec solana command
    (
        "Verify a USDC mint account exists on a local Solana test validator via Docker",
        '''requires docker;
async fn main() -> i64 {
  result: string = await docker.exec("compose-solana-test-validator-1", "solana account 4r2d1Qj65nDqsQZcFG14dsNb41ooa2BXddmrrEKfw8NR --output json");
  println(result);
  return 0;
}'''
    ),
    # Command 21: check if worktree exists
    (
        "Check if a worktree directory exists on the filesystem",
        '''requires fs;
async fn main() -> i64 {
  exists: bool = await fs.exists("/home/rix/.exophial/worktrees/plan-task-lEbITVK");
  if exists {
    println("exists");
  } else {
    println("not found");
  }
  return 0;
}'''
    ),
    # Command 32: gh run view
    (
        "View details of a GitHub Actions CI run to check for failures",
        '''requires gh;
async fn main() -> i64 {
  result: string = await gh.run_view(23277897599);
  println(result);
  return 0;
}'''
    ),
    # Command 37: curl GET to test URL
    (
        "Test accessibility of a media gateway URL by fetching content",
        '''requires curl;
async fn main() -> i64 {
  result: string = await curl.get("https://media.dumpster.cash/ipfs/QmeryEZNKWjLmmc3THYbiZncZX4gu6wQ1ErEY3wcRgqLfX");
  println(result);
  return 0;
}'''
    ),
    # Command 38: git log for specific files
    (
        "Track commit history for cryovial-related files across all branches",
        '''requires git;
async fn main() -> i64 {
  result: string = await git.log("--all --oneline -- stacks/cryovial/ .github/workflows/build-cryovial.yml ansible/roles/cryovial/");
  println(result);
  return 0;
}'''
    ),
    # Command 42: find files by pattern
    (
        "Search for test-plan and exophial-spec files in a repository",
        '''requires find;
async fn main() -> i64 {
  results: string = await find.by_name("*test-plan*", "/home/rix/code/repos/exophial");
  println(results);
  specs: string = await find.by_name("*exophial-spec*", "/home/rix/code/repos/exophial");
  println(specs);
  return 0;
}'''
    ),
    # Command 45: find Rust source files
    (
        "List all Rust source files in the shredtop project",
        '''requires find;
async fn main() -> i64 {
  results: string = await find.by_name("*.rs", "/home/rix/code/repos/shredtop/src");
  println(results);
  return 0;
}'''
    ),
    # Command 47: grep in config file
    (
        "Search for PBR IP feature configuration in a network switch config file",
        '''requires grep;
async fn main() -> i64 {
  result: string = await grep.search("feature pbr ip", "docs/switch-configs/mia-sw01-running.cfg");
  println(result);
  return 0;
}'''
    ),
    # Command 52: python3 syntax check
    (
        "Syntax-check a Python entrypoint script using py_compile",
        '''requires python3;
async fn main() -> i64 {
  result: string = await python3.run_module("py_compile", "scripts/agave-container/entrypoint.py");
  println("OK");
  return 0;
}'''
    ),
    # Command 53: grep ERROR lines
    (
        "Extract ERROR lines from a command output log file",
        '''requires grep;
async fn main() -> i64 {
  result: string = await grep.search("ERROR:.*", "/tmp/tool-results/output.txt");
  println(result);
  return 0;
}'''
    ),
    # Command 54: grep recursive for class names
    (
        "Recursively search for PipelineDefinition or PlanTemplate in Python source code",
        '''requires grep;
async fn main() -> i64 {
  result: string = await grep.search_recursive("PipelineDefinition|PlanTemplate", "/home/rix/code/repos/exophial/src/exophial");
  println(result);
  return 0;
}'''
    ),
    # Command 55: remove stale file
    (
        "Remove a stale done.yaml marker file from a worktree",
        '''requires fs;
async fn main() -> i64 {
  code: int = await fs.remove("/home/rix/.exophial/worktrees/plan-test-plan-001/done.yaml");
  println("Removed stale done.yaml");
  return 0;
}'''
    ),
    # Command 56: docker logs
    (
        "View container logs for a web content management deployment",
        '''requires docker;
async fn main() -> i64 {
  result: string = await docker.logs("compose-hitone-wcm-deploy-1");
  println(result);
  return 0;
}'''
    ),
    # Command 59: find config files
    (
        "Find YAML configuration files in a project directory tree",
        '''requires find;
async fn main() -> i64 {
  results: string = await find.by_name("*.yml", "/home/rix/code/git_puller");
  println(results);
  return 0;
}'''
    ),
    # Command 63: git branch grep
    (
        "Find a specific task branch by searching all branch names",
        '''requires git;
requires awk;
async fn main() -> i64 {
  branches: string = await git.branch();
  filtered: string = await awk.filter("k59ov", branches);
  println(filtered);
  return 0;
}'''
    ),
    # Command 64: pip list + filter
    (
        "Check if the exophial package is installed in the current Python environment",
        '''requires python3;
requires awk;
async fn main() -> i64 {
  packages: string = await python3.pip_list();
  filtered: string = await awk.filter("exophial", packages);
  println(filtered);
  return 0;
}'''
    ),
    # Command 67: git checkout + check file
    (
        "Switch to a PR branch and verify a SQL migration script exists",
        '''requires git;
requires fs;
async fn main() -> i64 {
  code: int = await git.checkout("fix/schema-migration-and-logging");
  exists: bool = await fs.exists("scripts/create-mainnet-schema.sql");
  if exists {
    println("scripts/create-mainnet-schema.sql exists");
  } else {
    println("scripts/create-mainnet-schema.sql not found");
  }
  return 0;
}'''
    ),
    # Command 71: find test files
    (
        "Find TypeScript test files in a mobile project directory",
        '''requires find;
async fn main() -> i64 {
  results: string = await find.by_name("*.test.ts", "/home/rix/code/repos/mtm/mobile");
  println(results);
  return 0;
}'''
    ),
    # Command 72: python3 exec introspection code
    (
        "List all registered MCP tools by introspecting the Python server module",
        '''requires python3;
async fn main() -> i64 {
  code: string = "import sys; sys.path.insert(0, 'src'); from exophial import mcp_server; tools = list(mcp_server.mcp._tool_manager.list_tools()); print(len(tools))";
  result: string = await python3.exec(code);
  println(result);
  return 0;
}'''
    ),
    # Command 83: copy file with fallback
    (
        "Copy a bug fix spec from the coordination store to the current directory",
        '''requires fs;
async fn main() -> i64 {
  src: string = "/home/rix/.exophial/coord/projects/self-dev/plan_specs/pending/fix-bug-jYrqktE.md";
  exists: bool = await fs.exists(src);
  if exists {
    content: string = await fs.read_file(src);
    code: int = await fs.write_file("fix-bug-jYrqktE.md", content);
    println("Copied spec file");
  } else {
    println("File not found in coord");
  }
  return 0;
}'''
    ),
    # Command 86: grep dispatcher log
    (
        "Search dispatcher log for task assignment and error activity",
        '''requires grep;
async fn main() -> i64 {
  result: string = await grep.search("Assigning|assign|completed|failed|error|Error", "/home/rix/.exophial/dispatcher.log");
  println(result);
  return 0;
}'''
    ),
    # Command 89: python3 pytest
    (
        "Run the Python test suite excluding e2e tests with a 60-second timeout",
        '''requires python3;
async fn main() -> i64 {
  result: string = await python3.run_module("pytest", "tests/ --timeout=60 --ignore=tests/e2e -q");
  println(result);
  return 0;
}'''
    ),
    # Command 90: git log all refs
    (
        "Search all git refs and remotes for commits in oneline format",
        '''requires git;
async fn main() -> i64 {
  result: string = await git.log("--all --oneline --source --remotes");
  println(result);
  return 0;
}'''
    ),
    # Command 92: find config files in /etc
    (
        "Find runner, gitea, and act configuration files in the system config directory",
        '''requires find;
async fn main() -> i64 {
  runners: string = await find.by_name("*runner*", "/etc");
  println(runners);
  gitea: string = await find.by_name("*gitea*", "/etc");
  println(gitea);
  acts: string = await find.by_name("*act*", "/etc");
  println(acts);
  return 0;
}'''
    ),
    # Command 93: git branch -a
    (
        "List all local and remote branches in a bare git repository",
        '''requires git;
async fn main() -> i64 {
  result: string = await git.branch();
  println(result);
  return 0;
}'''
    ),
    # Command 97: grep pebbles events
    (
        "Find snapshot-related bug entries in the pebbles issue tracker",
        '''requires grep;
async fn main() -> i64 {
  result: string = await grep.search("snapshot|download", ".pebbles/events.jsonl");
  println(result);
  return 0;
}'''
    ),
    # Additional derived translations from patterns in the batch:

    # git status check
    (
        "Show the current git working tree status",
        '''requires git;
async fn main() -> i64 {
  result: string = await git.status();
  println(result);
  return 0;
}'''
    ),
    # git diff
    (
        "Show unstaged changes in the current working tree",
        '''requires git;
async fn main() -> i64 {
  result: string = await git.diff();
  println(result);
  return 0;
}'''
    ),
    # git add and commit
    (
        "Stage all changes and create a commit with a descriptive message",
        '''requires git;
async fn main() -> i64 {
  code: int = await git.add(".");
  result: string = await git.commit("Fix schema migration and improve logging");
  println(result);
  return 0;
}'''
    ),
    # git stash
    (
        "Stash current working directory changes for later use",
        '''requires git;
async fn main() -> i64 {
  result: string = await git.stash("push");
  println(result);
  return 0;
}'''
    ),
    # git stash pop
    (
        "Restore previously stashed changes to the working directory",
        '''requires git;
async fn main() -> i64 {
  result: string = await git.stash("pop");
  println(result);
  return 0;
}'''
    ),
    # git checkout branch
    (
        "Switch to the main branch",
        '''requires git;
async fn main() -> i64 {
  code: int = await git.checkout("main");
  println("Switched to main");
  return 0;
}'''
    ),
    # git rebase
    (
        "Rebase the current branch onto the main branch",
        '''requires git;
async fn main() -> i64 {
  result: string = await git.rebase("main");
  println(result);
  return 0;
}'''
    ),
    # git push
    (
        "Push the current branch to the origin remote",
        '''requires git;
async fn main() -> i64 {
  result: string = await git.push("origin", "feature-branch");
  println(result);
  return 0;
}'''
    ),
    # git pull
    (
        "Pull latest changes from the origin remote for the main branch",
        '''requires git;
async fn main() -> i64 {
  result: string = await git.pull("origin", "main");
  println(result);
  return 0;
}'''
    ),
    # grep count occurrences
    (
        "Count the number of TODO comments in a source file",
        '''requires grep;
async fn main() -> i64 {
  count: int = await grep.count("TODO", "src/main.rs");
  println(f"TODO count: {count}");
  return 0;
}'''
    ),
    # grep files matching
    (
        "Find all files containing the pattern 'async fn' in a Rust source directory",
        '''requires grep;
async fn main() -> i64 {
  files: string = await grep.files_matching("async fn", "src/");
  println(files);
  return 0;
}'''
    ),
    # grep invert match
    (
        "Show all lines in a config file that do not match comment patterns",
        '''requires grep;
async fn main() -> i64 {
  result: string = await grep.invert_match("^#|^$", "/etc/ssh/sshd_config");
  println(result);
  return 0;
}'''
    ),
    # grep fixed string
    (
        "Search for an exact function name in a Python file without regex interpretation",
        '''requires grep;
async fn main() -> i64 {
  result: string = await grep.search_fixed("def process_event(", "src/exophial/dispatcher.py");
  println(result);
  return 0;
}'''
    ),
    # find by type (directories)
    (
        "List all directories in the project source tree",
        '''requires find;
async fn main() -> i64 {
  dirs: string = await find.by_type("d", "src/");
  println(dirs);
  return 0;
}'''
    ),
    # find by size
    (
        "Find files larger than 1MB in the project directory",
        '''requires find;
async fn main() -> i64 {
  large_files: string = await find.by_min_size(1048576, "/home/rix/project");
  println(large_files);
  return 0;
}'''
    ),
    # find recently modified
    (
        "Find files modified within the last hour in the source directory",
        '''requires find;
async fn main() -> i64 {
  recent: string = await find.modified_within(3600, "src/");
  println(recent);
  return 0;
}'''
    ),
    # find count
    (
        "Count the number of Python files in a project directory",
        '''requires find;
async fn main() -> i64 {
  count: int = await find.count("*.py", "/home/rix/project/src");
  println(f"Python files: {count}");
  return 0;
}'''
    ),
    # find by name and type
    (
        "Find all Python files (not directories) matching a test pattern",
        '''requires find;
async fn main() -> i64 {
  tests: string = await find.by_name_and_type("test_*.py", "f", "tests/");
  println(tests);
  return 0;
}'''
    ),
    # sed substitute
    (
        "Replace the first occurrence of an old function name with a new one in text",
        '''requires sed;
requires fs;
async fn main() -> i64 {
  content: string = await fs.read_file("config.yaml");
  updated: string = await sed.substitute("old_name", "new_name", content);
  println(updated);
  return 0;
}'''
    ),
    # sed substitute all
    (
        "Replace all occurrences of localhost with a production hostname in a config",
        '''requires sed;
requires fs;
async fn main() -> i64 {
  content: string = await fs.read_file("config.yaml");
  updated: string = await sed.substitute_all("localhost", "prod.example.com", content);
  code: int = await fs.write_file("config.yaml", updated);
  println("Updated config");
  return 0;
}'''
    ),
    # sed delete matching
    (
        "Remove all comment lines from a configuration file",
        '''requires sed;
requires fs;
async fn main() -> i64 {
  content: string = await fs.read_file("/etc/hosts");
  cleaned: string = await sed.delete_matching("^#", content);
  println(cleaned);
  return 0;
}'''
    ),
    # sed substitute in file
    (
        "Replace a version string directly in a TOML file",
        '''requires sed;
async fn main() -> i64 {
  result: string = await sed.substitute_in_file("0.1.0", "0.2.0", "Cargo.toml");
  println(result);
  return 0;
}'''
    ),
    # awk field extraction
    (
        "Extract the second column from a colon-delimited passwd file",
        '''requires awk;
requires fs;
async fn main() -> i64 {
  content: string = await fs.read_file("/etc/passwd");
  usernames: string = await awk.field(1, ":", content);
  println(usernames);
  return 0;
}'''
    ),
    # awk sum field
    (
        "Sum the values in the third column of a CSV data file",
        '''requires awk;
requires fs;
async fn main() -> i64 {
  content: string = await fs.read_file("data.csv");
  total: float = await awk.sum_field(3, ",", content);
  print_f64(total);
  println("");
  return 0;
}'''
    ),
    # awk unique field
    (
        "Extract unique values from the first column of a tab-separated log",
        '''requires awk;
requires fs;
async fn main() -> i64 {
  content: string = await fs.read_file("access.log");
  unique_ips: string = await awk.unique_field(1, " ", content);
  println(unique_ips);
  return 0;
}'''
    ),
    # awk count matching
    (
        "Count the number of error lines in a log file using awk pattern matching",
        '''requires awk;
requires fs;
async fn main() -> i64 {
  content: string = await fs.read_file("app.log");
  errors: int = await awk.count_matching("ERROR", content);
  println(f"Error count: {errors}");
  return 0;
}'''
    ),
    # jq query
    (
        "Extract a specific field from a JSON string using jq",
        '''requires jq;
async fn main() -> i64 {
  json: string = "[1, 2, 3, 4, 5]";
  result: string = await jq.query(".[2]", json);
  println(result);
  return 0;
}'''
    ),
    # jq keys
    (
        "List all keys from a JSON configuration read from a file",
        '''requires jq;
requires fs;
async fn main() -> i64 {
  json: string = await fs.read_file("config.json");
  keys: string = await jq.keys(json);
  println(keys);
  return 0;
}'''
    ),
    # curl GET
    (
        "Fetch the contents of a remote URL using HTTP GET",
        '''requires curl;
async fn main() -> i64 {
  result: string = await curl.get("https://api.example.com/health");
  println(result);
  return 0;
}'''
    ),
    # curl download
    (
        "Download a binary release to a local file path",
        '''requires curl;
async fn main() -> i64 {
  bytes: int = await curl.download("https://releases.example.com/v1.0/tool", "/usr/local/bin/tool");
  println(f"Downloaded {bytes} bytes");
  return 0;
}'''
    ),
    # curl GET with header
    (
        "Fetch data from an API endpoint using a custom authorization header",
        '''requires curl;
async fn main() -> i64 {
  result: string = await curl.get_with_header("https://api.example.com/data", "Authorization: Bearer mytoken123");
  println(result);
  return 0;
}'''
    ),
    # docker ps
    (
        "List all running Docker containers",
        '''requires docker;
async fn main() -> i64 {
  result: string = await docker.ps("-a");
  println(result);
  return 0;
}'''
    ),
    # docker images
    (
        "List all local Docker images with their sizes",
        '''requires docker;
async fn main() -> i64 {
  result: string = await docker.images("--format table");
  println(result);
  return 0;
}'''
    ),
    # docker stop and rm
    (
        "Stop and remove a Docker container by name",
        '''requires docker;
async fn main() -> i64 {
  code: int = await docker.stop("my-app-container");
  rm_code: int = await docker.rm("my-app-container");
  println("Container stopped and removed");
  return 0;
}'''
    ),
    # docker build
    (
        "Build a Docker image from the current directory with a specific tag",
        '''requires docker;
async fn main() -> i64 {
  result: string = await docker.build(".", "myapp:latest");
  println(result);
  return 0;
}'''
    ),
    # docker run
    (
        "Run a one-off command in a new Docker container",
        '''requires docker;
async fn main() -> i64 {
  result: string = await docker.run("ubuntu:22.04", "cat /etc/os-release");
  println(result);
  return 0;
}'''
    ),
    # gh pr create
    (
        "Create a new pull request with a title and description",
        '''requires gh;
async fn main() -> i64 {
  result: string = await gh.pr_create("Fix database migration ordering", "Ensures migrations run in dependency order to prevent foreign key violations");
  println(result);
  return 0;
}'''
    ),
    # gh pr list
    (
        "List all open pull requests in the current repository",
        '''requires gh;
async fn main() -> i64 {
  result: string = await gh.pr_list("open");
  println(result);
  return 0;
}'''
    ),
    # gh issue create
    (
        "File a new GitHub issue for a discovered bug",
        '''requires gh;
async fn main() -> i64 {
  result: string = await gh.issue_create("Gateway sends wrong GQL variable format", "KeyValueInput needs ValueInput wrapper for correct serialization");
  println(result);
  return 0;
}'''
    ),
    # gh issue list
    (
        "List all open issues in the current GitHub repository",
        '''requires gh;
async fn main() -> i64 {
  result: string = await gh.issue_list("open");
  println(result);
  return 0;
}'''
    ),
    # gh repo clone
    (
        "Clone a GitHub repository to a local directory",
        '''requires gh;
async fn main() -> i64 {
  code: int = await gh.repo_clone("anthropics/claude-code", "/home/rix/repos/claude-code");
  println("Repository cloned");
  return 0;
}'''
    ),
    # cargo build
    (
        "Build a Rust project at the specified path",
        '''requires cargo;
async fn main() -> i64 {
  code: int = await cargo.build(".");
  if code == 0 {
    println("Build succeeded");
  } else {
    println("Build failed");
  }
  return 0;
}'''
    ),
    # cargo test
    (
        "Run the Rust test suite for a project",
        '''requires cargo;
async fn main() -> i64 {
  code: int = await cargo.test(".");
  if code == 0 {
    println("All tests passed");
  } else {
    println("Some tests failed");
  }
  return 0;
}'''
    ),
    # cargo clippy
    (
        "Run Clippy lints on a Rust project and print warnings",
        '''requires cargo;
async fn main() -> i64 {
  output: string = await cargo.clippy(".");
  println(output);
  return 0;
}'''
    ),
    # cargo fmt
    (
        "Format all Rust source code in a project",
        '''requires cargo;
async fn main() -> i64 {
  code: int = await cargo.fmt(".");
  if code == 0 {
    println("Code formatted");
  } else {
    println("Formatting failed");
  }
  return 0;
}'''
    ),
    # cargo check
    (
        "Type-check a Rust project without producing binaries",
        '''requires cargo;
async fn main() -> i64 {
  code: int = await cargo.check(".");
  if code == 0 {
    println("Type check passed");
  } else {
    println("Type errors found");
  }
  return 0;
}'''
    ),
    # python3 run script
    (
        "Run a Python script file and print its output",
        '''requires python3;
async fn main() -> i64 {
  result: string = await python3.run_script("scripts/analyze.py");
  println(result);
  return 0;
}'''
    ),
    # python3 version
    (
        "Check the installed Python version",
        '''requires python3;
async fn main() -> i64 {
  ver: string = await python3.version();
  println(f"Python version: {ver}");
  return 0;
}'''
    ),
    # python3 eval
    (
        "Evaluate a Python math expression and print the result",
        '''requires python3;
async fn main() -> i64 {
  result: string = await python3.eval("2 ** 32");
  println(result);
  return 0;
}'''
    ),
    # python3 pip install
    (
        "Install a Python package using pip",
        '''requires python3;
async fn main() -> i64 {
  result: string = await python3.pip_install("requests");
  println(result);
  return 0;
}'''
    ),
    # fs read + write (file copy)
    (
        "Read a source file and write its contents to a destination path",
        '''requires fs;
async fn main() -> i64 {
  content: string = await fs.read_file("/home/rix/source.txt");
  code: int = await fs.write_file("/home/rix/backup.txt", content);
  println("File copied");
  return 0;
}'''
    ),
    # fs append
    (
        "Append a log entry to an existing log file",
        '''requires fs;
async fn main() -> i64 {
  code: int = await fs.append_file("/var/log/app.log", "Service restarted successfully\n");
  println("Log entry appended");
  return 0;
}'''
    ),
    # fs file size
    (
        "Check the size of a database file in bytes",
        '''requires fs;
async fn main() -> i64 {
  sz: int = await fs.file_size("/home/rix/data/app.db");
  println(f"File size: {sz} bytes");
  return 0;
}'''
    ),
    # process getenv
    (
        "Read the HOME and PATH environment variables",
        '''requires process;
async fn main() -> i64 {
  home: string = await process.getenv("HOME");
  println(f"HOME: {home}");
  path: string = await process.getenv("PATH");
  println(f"PATH: {path}");
  return 0;
}'''
    ),
    # process cwd + timestamp
    (
        "Print the current working directory and timestamp",
        '''requires process;
async fn main() -> i64 {
  cwd: string = await process.cwd();
  println(f"Working directory: {cwd}");
  ts: int = await process.timestamp();
  println(f"Timestamp: {ts}ms");
  return 0;
}'''
    ),
    # log messages at different levels
    (
        "Log messages at different severity levels for monitoring",
        '''requires log;
async fn main() -> i64 {
  await log.info("Application started successfully");
  await log.warn("Cache miss rate above threshold");
  await log.error("Database connection pool exhausted");
  await log.debug("Processing batch item 42");
  return 0;
}'''
    ),
    # math operations
    (
        "Perform basic arithmetic operations and find min/max values",
        '''requires math;
async fn main() -> i64 {
  sum: int = await math.add(42, 58);
  println(f"42 + 58 = {sum}");
  product: int = await math.multiply(7, 8);
  println(f"7 * 8 = {product}");
  bigger: int = await math.max(100, 200);
  println(f"max(100, 200) = {bigger}");
  abs_val: int = await math.abs(-42);
  println(f"abs(-42) = {abs_val}");
  return 0;
}'''
    ),
    # http GET
    (
        "Fetch data from an HTTP API endpoint",
        '''requires http;
async fn main() -> i64 {
  result: string = await http.get("https://api.example.com/status");
  println(result);
  return 0;
}'''
    ),
    # yq convert YAML to JSON
    (
        "Convert YAML configuration to JSON format for processing",
        '''requires yq;
requires fs;
async fn main() -> i64 {
  yaml: string = await fs.read_file("config.yaml");
  json: string = await yq.to_json(yaml);
  println(json);
  return 0;
}'''
    ),
    # yq query
    (
        "Extract a specific value from a YAML configuration by path",
        '''requires yq;
requires fs;
async fn main() -> i64 {
  yaml: string = await fs.read_file("config.yaml");
  value: string = await yq.get(yaml, ".server.port");
  println(f"Server port: {value}");
  return 0;
}'''
    ),
    # Combined: grep + fs for log analysis
    (
        "Read a log file and count error occurrences for monitoring",
        '''requires grep;
async fn main() -> i64 {
  errors: int = await grep.count("ERROR", "/var/log/app.log");
  warnings: int = await grep.count("WARN", "/var/log/app.log");
  println(f"Errors: {errors}");
  println(f"Warnings: {warnings}");
  return 0;
}'''
    ),
    # Combined: find + grep for codebase analysis
    (
        "Find all Rust files and search for unsafe blocks in source code",
        '''requires find;
requires grep;
async fn main() -> i64 {
  files: string = await find.by_name("*.rs", "src/");
  println("Rust source files:");
  println(files);
  unsafe_files: string = await grep.files_matching("unsafe", "src/");
  println("Files containing unsafe:");
  println(unsafe_files);
  return 0;
}'''
    ),
    # Combined: docker exec + grep for container debugging
    (
        "Check running processes inside a Docker container and search for a specific service",
        '''requires docker;
requires awk;
async fn main() -> i64 {
  output: string = await docker.exec("app-container", "ps aux");
  filtered: string = await awk.filter("nginx", output);
  println(filtered);
  return 0;
}'''
    ),
    # Combined: git status + diff for pre-commit check
    (
        "Show git status and diff to review changes before committing",
        '''requires git;
async fn main() -> i64 {
  status: string = await git.status();
  println("=== Status ===");
  println(status);
  diff: string = await git.diff();
  println("=== Diff ===");
  println(diff);
  return 0;
}'''
    ),
    # Combined: fs exists + read for safe file reading
    (
        "Safely read a configuration file only if it exists",
        '''requires fs;
async fn main() -> i64 {
  path: string = "/home/rix/.config/app/settings.toml";
  exists: bool = await fs.exists(path);
  if exists {
    content: string = await fs.read_file(path);
    println(content);
  } else {
    println("Config file not found, using defaults");
  }
  return 0;
}'''
    ),
    # Combined: cargo build + test pipeline
    (
        "Build a Rust project and run tests only if the build succeeds",
        '''requires cargo;
async fn main() -> i64 {
  build_code: int = await cargo.build(".");
  if build_code == 0 {
    println("Build OK, running tests...");
    test_code: int = await cargo.test(".");
    if test_code == 0 {
      println("All tests passed");
    } else {
      println("Tests failed");
    }
  } else {
    println("Build failed, skipping tests");
  }
  return 0;
}'''
    ),
    # Combined: sed + fs for config templating
    (
        "Template a configuration file by replacing placeholder values",
        '''requires sed;
requires fs;
requires process;
async fn main() -> i64 {
  template: string = await fs.read_file("config.template");
  home: string = await process.getenv("HOME");
  result: string = await sed.substitute_all("PLACEHOLDER_HOME", home, template);
  code: int = await fs.write_file("config.final", result);
  println("Config templated");
  return 0;
}'''
    ),
    # Combined: find + awk for file statistics
    (
        "Count files by type in a project and report statistics",
        '''requires find;
async fn main() -> i64 {
  py_count: int = await find.count("*.py", "src/");
  rs_count: int = await find.count("*.rs", "src/");
  ts_count: int = await find.count("*.ts", "src/");
  println(f"Python files: {py_count}");
  println(f"Rust files: {rs_count}");
  println(f"TypeScript files: {ts_count}");
  return 0;
}'''
    ),
    # Combined: curl + jq for API data extraction
    (
        "Fetch JSON data from an API and extract specific fields",
        '''requires curl;
requires jq;
async fn main() -> i64 {
  response: string = await curl.get("https://api.example.com/users");
  keys: string = await jq.keys(response);
  println(keys);
  return 0;
}'''
    ),
    # Combined: gh + grep for PR review
    (
        "List open pull requests and filter for those with a specific label pattern",
        '''requires gh;
requires awk;
async fn main() -> i64 {
  prs: string = await gh.pr_list("open");
  filtered: string = await awk.filter("bug", prs);
  println("Bug-related PRs:");
  println(filtered);
  return 0;
}'''
    ),
    # timer-based operation
    (
        "Set a timer and measure elapsed time for benchmarking",
        '''requires timer;
requires process;
async fn main() -> i64 {
  start: int = await process.timestamp();
  code: int = await timer.setTimeout(100);
  end: int = await process.timestamp();
  elapsed: i64 = end - start;
  println(f"Timer elapsed: {elapsed}ms");
  return 0;
}'''
    ),
    # env operations
    (
        "Get host environment information including name, version, and a random number",
        '''requires env;
async fn main() -> i64 {
  name: string = await env.get_name();
  println(f"Host: {name}");
  ver: int = await env.get_version();
  println(f"Version: {ver}");
  rnd: int = await env.random(1, 100);
  println(f"Random: {rnd}");
  return 0;
}'''
    ),
    # sed extract range
    (
        "Extract a section of text between two marker patterns from a file",
        '''requires sed;
requires fs;
async fn main() -> i64 {
  content: string = await fs.read_file("README.md");
  section: string = await sed.extract_range("## Installation", "## Usage", content);
  println(section);
  return 0;
}'''
    ),
    # sed insert after
    (
        "Insert a new dependency line after the dependencies section header in a file",
        '''requires sed;
requires fs;
async fn main() -> i64 {
  content: string = await fs.read_file("Cargo.toml");
  updated: string = await sed.insert_after("dependencies", "serde = *", content);
  code: int = await fs.write_file("Cargo.toml", updated);
  println("Dependency added");
  return 0;
}'''
    ),
    # awk field count
    (
        "Determine the number of columns in a CSV file",
        '''requires awk;
requires fs;
async fn main() -> i64 {
  content: string = await fs.read_file("data.csv");
  cols: int = await awk.field_count(",", content);
  println(f"Number of columns: {cols}");
  return 0;
}'''
    ),
    # awk format fields
    (
        "Reformat log entries by extracting and rearranging fields",
        '''requires awk;
requires fs;
async fn main() -> i64 {
  content: string = await fs.read_file("access.log");
  formatted: string = await awk.format_fields("%s -> %s", " ", content);
  println(formatted);
  return 0;
}'''
    ),
    # jq filter
    (
        "Filter a JSON array to find entries matching a condition",
        '''requires jq;
requires fs;
async fn main() -> i64 {
  json: string = await fs.read_file("events.json");
  filtered: string = await jq.filter("select(.status == 'error')", json);
  println(filtered);
  return 0;
}'''
    ),
    # jq transform
    (
        "Transform JSON data by restructuring fields",
        '''requires jq;
async fn main() -> i64 {
  input: string = "[1, 2, 3, 4, 5]";
  result: string = await jq.transform("map(. * 2)", input);
  println(result);
  return 0;
}'''
    ),
    # jq values
    (
        "Extract all values from a JSON object",
        '''requires jq;
requires fs;
async fn main() -> i64 {
  json: string = await fs.read_file("settings.json");
  vals: string = await jq.values(json);
  println(vals);
  return 0;
}'''
    ),
    # yq set value
    (
        "Update a specific value in a YAML configuration file",
        '''requires yq;
requires fs;
async fn main() -> i64 {
  yaml: string = await fs.read_file("config.yaml");
  updated: string = await yq.set(yaml, ".server.port", "8080");
  code: int = await fs.write_file("config.yaml", updated);
  println("Port updated to 8080");
  return 0;
}'''
    ),
    # yq delete key
    (
        "Remove a deprecated configuration key from a YAML file",
        '''requires yq;
requires fs;
async fn main() -> i64 {
  yaml: string = await fs.read_file("config.yaml");
  updated: string = await yq.delete_key(yaml, ".deprecated_setting");
  code: int = await fs.write_file("config.yaml", updated);
  println("Deprecated setting removed");
  return 0;
}'''
    ),
    # Combined: multi-capability deployment check
    (
        "Run a deployment readiness check: verify build, run tests, and check Docker status",
        '''requires cargo;
requires docker;
async fn main() -> i64 {
  println("=== Deployment Readiness Check ===");
  build: int = await cargo.check(".");
  if build == 0 {
    println("Type check: PASS");
  } else {
    println("Type check: FAIL");
    return 1;
  }
  test: int = await cargo.test(".");
  if test == 0 {
    println("Tests: PASS");
  } else {
    println("Tests: FAIL");
    return 1;
  }
  containers: string = await docker.ps("-a");
  println("Running containers:");
  println(containers);
  println("=== Ready for deployment ===");
  return 0;
}'''
    ),
]


def validate(mog_source: str) -> bool:
    """Write mog source to test.mog and compile it."""
    test_path = os.path.join(VALIDATE_DIR, "test.mog")
    with open(test_path, "w") as f:
        f.write(mog_source)
    result = subprocess.run(
        [MOGC, test_path, "--emit-ir"],
        capture_output=True,
        cwd=VALIDATE_DIR,
    )
    return result.returncode == 0


def main():
    valid = []
    failed = []
    for i, (desc, mog) in enumerate(translations):
        if validate(mog):
            valid.append((desc, mog))
        else:
            failed.append((i, desc))
            print(f"FAIL [{i}]: {desc}")

    print(f"\nValid: {len(valid)}/{len(translations)}")
    if failed:
        print(f"Failed: {len(failed)}")
        for idx, desc in failed:
            print(f"  [{idx}] {desc}")

    # Write output
    with open(OUTPUT, "w") as f:
        for desc, mog in valid:
            # Normalize whitespace for single-line JSON
            mog_oneline = mog.replace("\n", "\\n")
            entry = {
                "instruction": "Generate a Mog script for this task",
                "input": desc,
                "output": mog,
            }
            f.write(json.dumps(entry) + "\n")

    print(f"\nWrote {len(valid)} entries to {OUTPUT}")


if __name__ == "__main__":
    main()
