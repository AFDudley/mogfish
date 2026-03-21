#!/usr/bin/env python3
"""Generate 400+ additional Mog training examples focusing on multi-capability compositions."""

import json
import subprocess
import os

MOGC = "/home/rix/.exophial/dc/mogfish/mog/compiler/target/release/mogc"
VALIDATE_DIR = "/tmp/mog_validate"
OUTPUT = "/home/rix/.exophial/dc/mogfish/training/cap_translations_011.jsonl"


def validate_mog(code: str) -> bool:
    path = os.path.join(VALIDATE_DIR, "check.mog")
    with open(path, "w") as f:
        f.write(code)
    try:
        result = subprocess.run(
            [MOGC, path, "--emit-ir"],
            capture_output=True, text=True, timeout=5
        )
        combined = result.stdout + result.stderr
        if "error:" in combined.lower():
            return False
        return "function " in result.stdout or "data " in result.stdout
    except Exception:
        return False


def entry(desc: str, code: str) -> dict:
    return {
        "instruction": "Generate a Mog script for this task",
        "input": desc,
        "output": code
    }


def generate_all():
    examples = []

    # ============================================================
    # SECTION 1: Multi-capability compositions (2-3 caps)
    # ============================================================

    # --- git + grep ---
    examples.append(("Find TODO comments and check git status", """requires git;
requires grep;
async fn main() -> i64 {
  todos: string = await grep.search_recursive("TODO", "src/");
  println("TODO items found:");
  println(todos);
  status: string = git.status();
  println("Git status:");
  println(status);
  return 0;
}"""))

    examples.append(("Search for merge conflict markers in repo", """requires git;
requires grep;
async fn main() -> i64 {
  status: string = git.status();
  println(status);
  conflicts: string = await grep.search_recursive("<<<<<<<", ".");
  if conflicts.len > 0 {
    println("Merge conflicts found:");
    println(conflicts);
  } else {
    println("No merge conflicts");
  }
  return 0;
}"""))

    examples.append(("Find FIXME comments and show recent commits", """requires git;
requires grep;
async fn main() -> i64 {
  fixmes: string = await grep.search_recursive("FIXME", "src/");
  println("FIXME items:");
  println(fixmes);
  log_out: string = git.log("--oneline -5");
  println("Recent commits:");
  println(log_out);
  return 0;
}"""))

    examples.append(("Search for unsafe code and show diff", """requires git;
requires grep;
async fn main() -> i64 {
  unsafe_code: string = await grep.search_recursive("unsafe", "src/");
  println("Unsafe blocks:");
  println(unsafe_code);
  diff: string = git.diff();
  println("Current diff:");
  println(diff);
  return 0;
}"""))

    examples.append(("Count test files and check branch", """requires git;
requires grep;
async fn main() -> i64 {
  branches: string = git.branch();
  println("Branches:");
  println(branches);
  test_files: string = grep.files_matching("fn test", "src/");
  println("Files with tests:");
  println(test_files);
  return 0;
}"""))

    # --- git + fs ---
    examples.append(("Save git status to a file", """requires git;
requires fs;
async fn main() -> i64 {
  status: string = git.status();
  fs.write_file("/tmp/git_status.txt", status);
  println("Status saved to /tmp/git_status.txt");
  return 0;
}"""))

    examples.append(("Export git log to file", """requires git;
requires fs;
async fn main() -> i64 {
  log_out: string = git.log("--oneline -50");
  fs.write_file("/tmp/git_log.txt", log_out);
  println("Log exported");
  return 0;
}"""))

    examples.append(("Save git diff for code review", """requires git;
requires fs;
async fn main() -> i64 {
  diff: string = git.diff();
  fs.write_file("/tmp/review.diff", diff);
  sz: int = fs.file_size("/tmp/review.diff");
  println(f"Diff saved: {sz} bytes");
  return 0;
}"""))

    examples.append(("Read commit message template and commit", """requires git;
requires fs;
async fn main() -> i64 {
  exists_val: bool = fs.exists(".commit_template");
  if exists_val {
    msg: string = fs.read_file(".commit_template");
    result: string = git.commit(msg);
    println(result);
  } else {
    println("No commit template found");
  }
  return 0;
}"""))

    examples.append(("Check if gitignore exists and show status", """requires git;
requires fs;
async fn main() -> i64 {
  has_ignore: bool = fs.exists(".gitignore");
  if has_ignore {
    println("Gitignore contents:");
    contents: string = fs.read_file(".gitignore");
    println(contents);
  }
  status: string = git.status();
  println(status);
  return 0;
}"""))

    # --- git + cargo ---
    examples.append(("Run tests before committing", """requires git;
requires cargo;
async fn main() -> i64 {
  test_result: int = await cargo.test(".");
  if test_result == 0 {
    result: int = git.add(".");
    msg: string = git.commit("All tests pass");
    println(msg);
  } else {
    println("Tests failed, aborting commit");
  }
  return 0;
}"""))

    examples.append(("Check, lint, and show status", """requires git;
requires cargo;
async fn main() -> i64 {
  check_result: int = await cargo.check(".");
  println(f"Check: {check_result}");
  clippy_out: string = await cargo.clippy(".");
  println(clippy_out);
  status: string = git.status();
  println(status);
  return 0;
}"""))

    examples.append(("Build project and commit on success", """requires git;
requires cargo;
async fn main() -> i64 {
  build_result: int = await cargo.build(".");
  if build_result == 0 {
    println("Build succeeded");
    result: int = git.add(".");
    msg: string = git.commit("Successful build");
    println(msg);
  } else {
    println("Build failed");
  }
  return 0;
}"""))

    examples.append(("Format code and stage changes", """requires git;
requires cargo;
async fn main() -> i64 {
  fmt_result: int = await cargo.fmt(".");
  println(f"Format: {fmt_result}");
  diff: string = git.diff();
  if diff.len > 0 {
    result: int = git.add(".");
    println("Formatted changes staged");
  } else {
    println("No formatting changes needed");
  }
  return 0;
}"""))

    examples.append(("Full CI pipeline: check, test, clippy", """requires cargo;
requires git;
async fn main() -> i64 {
  println("Running CI pipeline...");
  check_r: int = await cargo.check(".");
  println(f"Check: {check_r}");
  test_r: int = await cargo.test(".");
  println(f"Test: {test_r}");
  clippy_out: string = await cargo.clippy(".");
  println(f"Clippy: {clippy_out}");
  status: string = git.status();
  println(status);
  return 0;
}"""))

    # --- git + log ---
    examples.append(("Log git operations", """requires git;
requires log;
async fn main() -> i64 {
  log.info("Checking repository state");
  status: string = git.status();
  log.info(status);
  branches: string = git.branch();
  log.info(f"Branches: {branches}");
  return 0;
}"""))

    examples.append(("Pull with logging", """requires git;
requires log;
async fn main() -> i64 {
  log.info("Pulling latest changes...");
  result: string = await git.pull("origin", "main");
  log.info(f"Pull result: {result}");
  status: string = git.status();
  log.info(status);
  return 0;
}"""))

    # --- grep + find ---
    examples.append(("Find Python files and search for imports", """requires grep;
requires find;
async fn main() -> i64 {
  py_files: string = await find.by_name("*.py", "src/");
  println("Python files:");
  println(py_files);
  imports: string = await grep.search_recursive("^import\\|^from", "src/");
  println("Import statements:");
  println(imports);
  return 0;
}"""))

    examples.append(("Find config files and search for secrets", """requires grep;
requires find;
async fn main() -> i64 {
  configs: string = await find.by_name("*.yaml", ".");
  println("Config files:");
  println(configs);
  secrets: string = await grep.search_recursive("password\\|secret\\|api_key", ".");
  if secrets.len > 0 {
    println("WARNING: Potential secrets found:");
    println(secrets);
  } else {
    println("No secrets detected");
  }
  return 0;
}"""))

    examples.append(("Count source files and search for errors", """requires grep;
requires find;
async fn main() -> i64 {
  rs_count: int = await find.count("*.rs", "src/");
  println(f"Rust files: {rs_count}");
  py_count: int = await find.count("*.py", "src/");
  println(f"Python files: {py_count}");
  panics: string = await grep.search_recursive("panic!", "src/");
  println("Panic calls:");
  println(panics);
  return 0;
}"""))

    examples.append(("Find large files and search for debug prints", """requires find;
requires grep;
async fn main() -> i64 {
  large: string = await find.by_min_size(1048576, ".");
  println("Files over 1MB:");
  println(large);
  debug_prints: string = await grep.search_recursive("println!\\|dbg!", "src/");
  println("Debug prints:");
  println(debug_prints);
  return 0;
}"""))

    examples.append(("Find test files and count assertions", """requires find;
requires grep;
async fn main() -> i64 {
  test_files: string = await find.by_name("*test*", "src/");
  println("Test files:");
  println(test_files);
  asserts: string = await grep.search_recursive("assert", "src/");
  println("Assertions:");
  println(asserts);
  return 0;
}"""))

    # --- grep + fs ---
    examples.append(("Search log file and save matches", """requires grep;
requires fs;
async fn main() -> i64 {
  errors: string = grep.search("ERROR", "/var/log/app.log");
  fs.write_file("/tmp/errors.log", errors);
  println("Errors extracted and saved");
  return 0;
}"""))

    examples.append(("Read config and search for patterns", """requires grep;
requires fs;
async fn main() -> i64 {
  config: string = fs.read_file("config.toml");
  println("Config contents:");
  println(config);
  matches: string = grep.search("port", "config.toml");
  println("Port settings:");
  println(matches);
  return 0;
}"""))

    examples.append(("Count errors in multiple log files", """requires grep;
requires fs;
async fn main() -> i64 {
  err_count: int = grep.count("ERROR", "app.log");
  warn_count: int = grep.count("WARN", "app.log");
  println(f"Errors: {err_count}");
  println(f"Warnings: {warn_count}");
  report: string = f"Error count: {err_count}, Warning count: {warn_count}";
  fs.write_file("/tmp/log_report.txt", report);
  return 0;
}"""))

    # --- curl + jq ---
    examples.append(("Fetch API and extract specific fields", """requires curl;
requires jq;
async fn main() -> i64 {
  response: string = await curl.get("https://api.example.com/users");
  names: string = jq.query(".[].name", response);
  println("User names:");
  println(names);
  return 0;
}"""))

    examples.append(("POST to API and parse response", """requires curl;
requires jq;
async fn main() -> i64 {
  response: string = await curl.post("https://api.example.com/items", "{\\\"name\\\": \\\"widget\\\"}");
  id_val: string = jq.query(".id", response);
  println(f"Created item ID: {id_val}");
  return 0;
}"""))

    examples.append(("Fetch config API and extract keys", """requires curl;
requires jq;
async fn main() -> i64 {
  config: string = await curl.get("https://api.example.com/config");
  keys: string = jq.keys(config);
  println("Config keys:");
  println(keys);
  values: string = jq.values(config);
  println("Config values:");
  println(values);
  return 0;
}"""))

    examples.append(("Filter API response by criteria", """requires curl;
requires jq;
async fn main() -> i64 {
  data: string = await curl.get("https://api.example.com/products");
  expensive: string = jq.filter("select(.price > 100)", data);
  println("Expensive items:");
  println(expensive);
  return 0;
}"""))

    examples.append(("Transform API data", """requires curl;
requires jq;
async fn main() -> i64 {
  raw: string = await curl.get("https://api.example.com/data");
  transformed: string = jq.transform("{name: .title, count: .total}", raw);
  println(transformed);
  return 0;
}"""))

    # --- curl + fs ---
    examples.append(("Download API response and save to file", """requires curl;
requires fs;
async fn main() -> i64 {
  data: string = await curl.get("https://api.example.com/export");
  fs.write_file("/tmp/export.json", data);
  sz: int = fs.file_size("/tmp/export.json");
  println(f"Saved {sz} bytes");
  return 0;
}"""))

    examples.append(("Read auth token from file and make API call", """requires curl;
requires fs;
async fn main() -> i64 {
  token: string = fs.read_file("/tmp/api_token.txt");
  header: string = f"Authorization: Bearer {token}";
  response: string = await curl.get_with_header("https://api.example.com/me", header);
  println(response);
  return 0;
}"""))

    examples.append(("Download file and verify it exists", """requires curl;
requires fs;
async fn main() -> i64 {
  bytes: int = await curl.download("https://example.com/data.csv", "/tmp/data.csv");
  println(f"Downloaded {bytes} bytes");
  exists_val: bool = fs.exists("/tmp/data.csv");
  if exists_val {
    sz: int = fs.file_size("/tmp/data.csv");
    println(f"File size on disk: {sz}");
  }
  return 0;
}"""))

    examples.append(("Fetch two APIs and combine results", """requires curl;
requires fs;
async fn main() -> i64 {
  users: string = await curl.get("https://api.example.com/users");
  posts: string = await curl.get("https://api.example.com/posts");
  combined: string = f"Users:\\n{users}\\nPosts:\\n{posts}";
  fs.write_file("/tmp/combined.txt", combined);
  println("Combined data saved");
  return 0;
}"""))

    # --- curl + jq + fs (3-cap) ---
    examples.append(("Fetch API, filter data, save results", """requires curl;
requires jq;
requires fs;
async fn main() -> i64 {
  raw: string = await curl.get("https://api.example.com/items");
  filtered: string = jq.filter("select(.active == true)", raw);
  fs.write_file("/tmp/active_items.json", filtered);
  println("Active items saved");
  return 0;
}"""))

    examples.append(("Fetch API, extract names, write report", """requires curl;
requires jq;
requires fs;
async fn main() -> i64 {
  response: string = await curl.get("https://api.example.com/team");
  names: string = jq.query(".[].name", response);
  report: string = f"Team Members:\\n{names}";
  fs.write_file("/tmp/team_report.txt", report);
  println("Report generated");
  return 0;
}"""))

    examples.append(("Download config, parse, and validate", """requires curl;
requires jq;
requires fs;
async fn main() -> i64 {
  config: string = await curl.get("https://config.example.com/v1");
  version: string = jq.query(".version", config);
  println(f"Config version: {version}");
  fs.write_file("/tmp/remote_config.json", config);
  println("Config cached locally");
  return 0;
}"""))

    # --- fs + jq ---
    examples.append(("Read JSON file and query it", """requires fs;
requires jq;
async fn main() -> i64 {
  data: string = fs.read_file("package.json");
  name: string = jq.query(".name", data);
  version: string = jq.query(".version", data);
  println(f"Package: {name} v{version}");
  return 0;
}"""))

    examples.append(("Read JSON config and extract nested value", """requires fs;
requires jq;
async fn main() -> i64 {
  config: string = fs.read_file("config.json");
  db_host: string = jq.query(".database.host", config);
  db_port: string = jq.query(".database.port", config);
  println(f"Database: {db_host}:{db_port}");
  return 0;
}"""))

    examples.append(("Read JSON, transform, and save", """requires fs;
requires jq;
async fn main() -> i64 {
  input: string = fs.read_file("data.json");
  transformed: string = jq.transform("{ summary: .title, count: .items | length }", input);
  fs.write_file("summary.json", transformed);
  println("Summary saved");
  return 0;
}"""))

    examples.append(("Extract all keys from config file", """requires fs;
requires jq;
async fn main() -> i64 {
  config: string = fs.read_file("settings.json");
  keys: string = jq.keys(config);
  println("Available settings:");
  println(keys);
  return 0;
}"""))

    # --- fs + yq ---
    examples.append(("Read YAML config and extract values", """requires fs;
requires yq;
async fn main() -> i64 {
  yaml: string = fs.read_file("docker-compose.yml");
  services: string = yq.query(yaml, ".services");
  println(services);
  return 0;
}"""))

    examples.append(("Convert YAML config to JSON format", """requires fs;
requires yq;
async fn main() -> i64 {
  yaml: string = fs.read_file("config.yaml");
  json: string = yq.to_json(yaml);
  fs.write_file("config.json", json);
  println("Converted YAML to JSON");
  return 0;
}"""))

    examples.append(("Update YAML config value and save", """requires fs;
requires yq;
async fn main() -> i64 {
  yaml: string = fs.read_file("app.yaml");
  updated: string = yq.set(yaml, ".app.replicas", "3");
  fs.write_file("app.yaml", updated);
  println("Updated replicas to 3");
  return 0;
}"""))

    examples.append(("Remove debug setting from YAML config", """requires fs;
requires yq;
async fn main() -> i64 {
  yaml: string = fs.read_file("settings.yaml");
  cleaned: string = yq.delete_key(yaml, ".debug");
  fs.write_file("settings.yaml", cleaned);
  println("Debug setting removed");
  return 0;
}"""))

    # --- fs + sed ---
    examples.append(("Read file, replace pattern, write back", """requires fs;
requires sed;
async fn main() -> i64 {
  original: string = fs.read_file("config.txt");
  updated: string = sed.substitute_all("localhost", "production.db.internal", original);
  fs.write_file("config.txt", updated);
  println("Config updated for production");
  return 0;
}"""))

    examples.append(("Backup file before sed replacement", """requires fs;
requires sed;
async fn main() -> i64 {
  original: string = fs.read_file("app.conf");
  fs.write_file("app.conf.bak", original);
  result: string = sed.substitute_all_in_file("debug=true", "debug=false", "app.conf");
  println("Debug disabled, backup saved");
  return 0;
}"""))

    examples.append(("Remove comment lines from config", """requires fs;
requires sed;
async fn main() -> i64 {
  contents: string = fs.read_file("settings.conf");
  cleaned: string = sed.delete_matching("^#", contents);
  fs.write_file("settings_clean.conf", cleaned);
  println("Comments stripped");
  return 0;
}"""))

    # --- fs + awk ---
    examples.append(("Read CSV and extract column", """requires fs;
requires awk;
async fn main() -> i64 {
  data: string = fs.read_file("data.csv");
  names: string = awk.field(1, ",", data);
  println("Names column:");
  println(names);
  return 0;
}"""))

    examples.append(("Read data file and sum values", """requires fs;
requires awk;
async fn main() -> i64 {
  data: string = fs.read_file("sales.csv");
  total: float = awk.sum_field(3, ",", data);
  print_string("Total sales: ");
  print_f64(total);
  println("");
  return 0;
}"""))

    examples.append(("Read TSV and get unique values", """requires fs;
requires awk;
async fn main() -> i64 {
  data: string = fs.read_file("report.tsv");
  categories: string = awk.unique_field(2, "\\t", data);
  println("Unique categories:");
  println(categories);
  return 0;
}"""))

    # --- docker + log ---
    examples.append(("Monitor containers with logging", """requires docker;
requires log;
async fn main() -> i64 {
  log.info("Checking container status...");
  containers: string = docker.ps("");
  log.info(containers);
  images: string = docker.images("");
  log.info(f"Images: {images}");
  return 0;
}"""))

    examples.append(("Stop container with logging", """requires docker;
requires log;
async fn main() -> i64 {
  log.info("Stopping container myapp...");
  result: int = docker.stop("myapp");
  if result == 0 {
    log.info("Container stopped successfully");
  } else {
    log.error("Failed to stop container");
  }
  return 0;
}"""))

    # --- docker + fs ---
    examples.append(("Save container logs to file", """requires docker;
requires fs;
async fn main() -> i64 {
  logs: string = docker.logs("webapp");
  fs.write_file("/tmp/container_logs.txt", logs);
  sz: int = fs.file_size("/tmp/container_logs.txt");
  println(f"Saved {sz} bytes of logs");
  return 0;
}"""))

    examples.append(("List containers and save report", """requires docker;
requires fs;
async fn main() -> i64 {
  running: string = docker.ps("");
  all_containers: string = docker.ps("-a");
  report: string = f"Running:\\n{running}\\n\\nAll:\\n{all_containers}";
  fs.write_file("/tmp/docker_report.txt", report);
  println("Docker report saved");
  return 0;
}"""))

    # --- docker + grep ---
    examples.append(("Search container logs for errors", """requires docker;
requires grep;
async fn main() -> i64 {
  logs: string = docker.logs("webapp");
  errors: string = grep.search("ERROR", "/tmp/container.log");
  println("Errors in container:");
  println(errors);
  return 0;
}"""))

    # --- gh + git ---
    examples.append(("Create PR from current branch", """requires gh;
requires git;
async fn main() -> i64 {
  branches: string = git.branch();
  println(f"Current branch: {branches}");
  status: string = git.status();
  println(status);
  pr: string = await gh.pr_create("Feature update", "Implements new feature");
  println(pr);
  return 0;
}"""))

    examples.append(("View PR and check git log", """requires gh;
requires git;
async fn main() -> i64 {
  pr: string = await gh.pr_view(42);
  println("PR details:");
  println(pr);
  log_out: string = git.log("--oneline -10");
  println("Recent commits:");
  println(log_out);
  return 0;
}"""))

    examples.append(("List PRs and show branch info", """requires gh;
requires git;
async fn main() -> i64 {
  prs: string = await gh.pr_list("open");
  println("Open PRs:");
  println(prs);
  branches: string = git.branch();
  println("Local branches:");
  println(branches);
  return 0;
}"""))

    # --- gh + cargo ---
    examples.append(("Run CI checks before creating PR", """requires gh;
requires cargo;
async fn main() -> i64 {
  test_r: int = await cargo.test(".");
  clippy_out: string = await cargo.clippy(".");
  println(clippy_out);
  if test_r == 0 {
    pr: string = await gh.pr_create("Feature ready", "All checks pass");
    println(pr);
  } else {
    println("Tests failed, cannot create PR");
  }
  return 0;
}"""))

    # --- process + fs ---
    examples.append(("Write timestamped log entry", """requires process;
requires fs;
async fn main() -> i64 {
  ts: int = process.timestamp();
  entry_text: string = f"[{ts}] Application started\\n";
  fs.append_file("/tmp/app.log", entry_text);
  println("Log entry written");
  return 0;
}"""))

    examples.append(("Create file in home directory", """requires process;
requires fs;
async fn main() -> i64 {
  home: string = process.getenv("HOME");
  path: string = f"{home}/.myapp_config";
  fs.write_file(path, "initialized=true\\n");
  println(f"Config created at {path}");
  return 0;
}"""))

    examples.append(("Measure file read performance", """requires process;
requires fs;
async fn main() -> i64 {
  start: int = process.timestamp();
  contents: string = fs.read_file("/etc/hosts");
  end: int = process.timestamp();
  elapsed: int = end - start;
  println(f"Read /etc/hosts in {elapsed}ms");
  println(f"Content length: {contents.len}");
  return 0;
}"""))

    examples.append(("Environment-aware file operations", """requires process;
requires fs;
async fn main() -> i64 {
  env: string = process.getenv("APP_ENV");
  config_path: string = f"config/{env}.toml";
  exists_val: bool = fs.exists(config_path);
  if exists_val {
    config: string = fs.read_file(config_path);
    println(config);
  } else {
    println(f"No config for environment: {env}");
  }
  return 0;
}"""))

    # --- process + log ---
    examples.append(("Diagnostic logging with timestamps", """requires process;
requires log;
async fn main() -> i64 {
  ts: int = process.timestamp();
  log.info(f"Diagnostic started at {ts}");
  cwd_val: string = process.cwd();
  log.info(f"Working directory: {cwd_val}");
  home: string = process.getenv("HOME");
  log.info(f"Home: {home}");
  path: string = process.getenv("PATH");
  log.debug(f"PATH: {path}");
  return 0;
}"""))

    examples.append(("Timed operation with logging", """requires process;
requires log;
async fn main() -> i64 {
  log.info("Starting timed operation");
  start: int = process.timestamp();
  await process.sleep(100);
  end: int = process.timestamp();
  elapsed: int = end - start;
  log.info(f"Operation took {elapsed}ms");
  return 0;
}"""))

    # --- process + cargo ---
    examples.append(("Timed build and test", """requires process;
requires cargo;
async fn main() -> i64 {
  start: int = process.timestamp();
  build_r: int = await cargo.build(".");
  mid: int = process.timestamp();
  test_r: int = await cargo.test(".");
  end: int = process.timestamp();
  build_time: int = mid - start;
  test_time: int = end - mid;
  println(f"Build: {build_time}ms (exit {build_r})");
  println(f"Test: {test_time}ms (exit {test_r})");
  return 0;
}"""))

    # --- find + fs ---
    examples.append(("Find and read recently modified files", """requires find;
requires fs;
async fn main() -> i64 {
  recent: string = await find.modified_within(3600, "src/");
  println("Recently modified:");
  println(recent);
  return 0;
}"""))

    examples.append(("Count files by type in project", """requires find;
requires fs;
async fn main() -> i64 {
  rs_count: int = await find.count("*.rs", ".");
  py_count: int = await find.count("*.py", ".");
  ts_count: int = await find.count("*.ts", ".");
  toml_count: int = await find.count("*.toml", ".");
  println(f"Rust: {rs_count}");
  println(f"Python: {py_count}");
  println(f"TypeScript: {ts_count}");
  println(f"TOML: {toml_count}");
  return 0;
}"""))

    examples.append(("Find old temp files for cleanup", """requires find;
requires fs;
async fn main() -> i64 {
  old_files: string = await find.modified_before(604800, "/tmp");
  println("Files older than 7 days:");
  println(old_files);
  return 0;
}"""))

    # --- find + grep + fs (3-cap) ---
    examples.append(("Find source files, grep TODOs, save report", """requires find;
requires grep;
requires fs;
async fn main() -> i64 {
  file_count: int = await find.count("*.rs", "src/");
  todos: string = await grep.search_recursive("TODO\\|FIXME\\|HACK", "src/");
  report: string = f"Project has {file_count} Rust files\\n\\nTODOs:\\n{todos}";
  fs.write_file("/tmp/code_report.txt", report);
  println("Code report saved");
  return 0;
}"""))

    examples.append(("Audit project for common issues", """requires find;
requires grep;
requires fs;
async fn main() -> i64 {
  large: string = await find.by_min_size(5242880, ".");
  println("Large files (>5MB):");
  println(large);
  secrets: string = await grep.search_recursive("password\\|secret\\|token", ".");
  println("Potential secrets:");
  println(secrets);
  unwrap: string = await grep.search_recursive("unwrap()", "src/");
  println("Unwrap calls:");
  println(unwrap);
  return 0;
}"""))

    # --- curl + log ---
    examples.append(("API health check with logging", """requires curl;
requires log;
async fn main() -> i64 {
  log.info("Checking API health...");
  response: string = await curl.get("https://api.example.com/health");
  log.info(f"Response: {response}");
  return 0;
}"""))

    examples.append(("Logged API POST request", """requires curl;
requires log;
async fn main() -> i64 {
  log.info("Sending data to API...");
  response: string = await curl.post("https://api.example.com/events", "{\\\"event\\\": \\\"deploy\\\"}");
  log.info(f"API response: {response}");
  return 0;
}"""))

    # --- curl + process ---
    examples.append(("Timed API request", """requires curl;
requires process;
async fn main() -> i64 {
  start: int = process.timestamp();
  response: string = await curl.get("https://api.example.com/data");
  end: int = process.timestamp();
  latency: int = end - start;
  println(f"API latency: {latency}ms");
  println(response);
  return 0;
}"""))

    examples.append(("API call with retry delay", """requires curl;
requires process;
async fn main() -> i64 {
  response: string = await curl.get("https://api.example.com/status");
  println(f"First check: {response}");
  await process.sleep(5000);
  response2: string = await curl.get("https://api.example.com/status");
  println(f"Second check: {response2}");
  return 0;
}"""))

    # --- curl + process + log (3-cap) ---
    examples.append(("Monitored API polling", """requires curl;
requires process;
requires log;
async fn main() -> i64 {
  log.info("Starting API polling");
  start: int = process.timestamp();
  response: string = await curl.get("https://api.example.com/job/123");
  end: int = process.timestamp();
  latency: int = end - start;
  log.info(f"Response received in {latency}ms");
  println(response);
  return 0;
}"""))

    # --- cargo + fs ---
    examples.append(("Build and save output log", """requires cargo;
requires fs;
async fn main() -> i64 {
  clippy_out: string = await cargo.clippy(".");
  fs.write_file("/tmp/clippy_output.txt", clippy_out);
  println("Clippy output saved");
  return 0;
}"""))

    examples.append(("Run tests and save results", """requires cargo;
requires fs;
async fn main() -> i64 {
  test_r: int = await cargo.test(".");
  result_text: string = f"Test exit code: {test_r}";
  fs.write_file("/tmp/test_results.txt", result_text);
  println(result_text);
  return 0;
}"""))

    # --- cargo + log ---
    examples.append(("Logged build pipeline", """requires cargo;
requires log;
async fn main() -> i64 {
  log.info("Starting build pipeline");
  fmt_r: int = await cargo.fmt(".");
  log.info(f"Format: {fmt_r}");
  check_r: int = await cargo.check(".");
  log.info(f"Check: {check_r}");
  test_r: int = await cargo.test(".");
  log.info(f"Test: {test_r}");
  if test_r == 0 {
    log.info("All checks passed");
  } else {
    log.error("Build pipeline failed");
  }
  return 0;
}"""))

    # --- python3 + fs ---
    examples.append(("Run Python script and save output", """requires python3;
requires fs;
async fn main() -> i64 {
  output: string = await python3.run_script("analyze.py");
  fs.write_file("/tmp/analysis_output.txt", output);
  println("Analysis saved");
  return 0;
}"""))

    examples.append(("Evaluate Python expression and log result", """requires python3;
requires fs;
async fn main() -> i64 {
  result: string = python3.eval("sum(range(1, 101))");
  fs.write_file("/tmp/calc_result.txt", result);
  println(f"Sum 1-100 = {result}");
  return 0;
}"""))

    # --- python3 + log ---
    examples.append(("Run Python with logging", """requires python3;
requires log;
async fn main() -> i64 {
  log.info("Running Python analysis...");
  output: string = await python3.run_script("train.py");
  log.info(f"Output: {output}");
  return 0;
}"""))

    # --- math + log ---
    examples.append(("Calculate and log results", """requires math;
requires log;
async fn main() -> i64 {
  sum: int = math.add(100, 200);
  product: int = math.multiply(sum, 3);
  log.info(f"Sum: {sum}");
  log.info(f"Product: {product}");
  max_val: int = math.max(sum, product);
  log.info(f"Max: {max_val}");
  return 0;
}"""))

    # --- math + fs ---
    examples.append(("Perform calculations and save report", """requires math;
requires fs;
async fn main() -> i64 {
  a: int = math.add(50, 75);
  b: int = math.multiply(a, 2);
  c: int = math.subtract(b, 10);
  d: int = math.divide(c, 5);
  report: string = f"50+75={a}, *2={b}, -10={c}, /5={d}";
  fs.write_file("/tmp/calc.txt", report);
  println(report);
  return 0;
}"""))

    # --- sed + grep ---
    examples.append(("Find and replace pattern across files", """requires sed;
requires grep;
async fn main() -> i64 {
  files: string = grep.files_matching("old_function", "src/");
  println("Files to update:");
  println(files);
  result: string = sed.substitute_all_in_file("old_function", "new_function", "src/main.rs");
  println("Replacement done");
  return 0;
}"""))

    examples.append(("Search for deprecated API and replace", """requires sed;
requires grep;
async fn main() -> i64 {
  deprecated: string = await grep.search_recursive("v1/api", "src/");
  println("Deprecated API calls:");
  println(deprecated);
  return 0;
}"""))

    # --- awk + grep ---
    examples.append(("Filter log lines and extract fields", """requires awk;
requires grep;
async fn main() -> i64 {
  errors: string = grep.search("ERROR", "app.log");
  timestamps: string = awk.field(1, " ", errors);
  println("Error timestamps:");
  println(timestamps);
  return 0;
}"""))

    examples.append(("Search and aggregate data", """requires awk;
requires grep;
async fn main() -> i64 {
  matches: string = grep.search("sale", "transactions.csv");
  total: float = awk.sum_field(3, ",", matches);
  print_string("Total sales: ");
  print_f64(total);
  println("");
  return 0;
}"""))

    # --- jq + yq ---
    examples.append(("Convert between JSON and YAML formats", """requires jq;
requires yq;
async fn main() -> i64 {
  json_str: string = "{\\\"name\\\": \\\"app\\\", \\\"port\\\": 8080}";
  yaml: string = yq.from_json(json_str);
  println("YAML:");
  println(yaml);
  back_to_json: string = yq.to_json(yaml);
  println("Back to JSON:");
  println(back_to_json);
  return 0;
}"""))

    # --- timer + log ---
    examples.append(("Timed operation with timer capability", """requires timer;
requires log;
async fn main() -> i64 {
  log.info("Starting delayed operation");
  result: int = await timer.setTimeout(500);
  log.info(f"Timer completed: {result}");
  return 0;
}"""))

    examples.append(("Sequential timer operations", """requires timer;
requires log;
async fn main() -> i64 {
  log.info("Phase 1 starting");
  await timer.setTimeout(100);
  log.info("Phase 1 complete");
  log.info("Phase 2 starting");
  await timer.setTimeout(200);
  log.info("Phase 2 complete");
  return 0;
}"""))

    # --- http + fs ---
    examples.append(("Fetch URL and cache response", """requires http;
requires fs;
async fn main() -> i64 {
  data: string = await http.get("https://api.example.com/config");
  fs.write_file("/tmp/cached_config.json", data);
  println("Config cached");
  return 0;
}"""))

    examples.append(("POST data and save response", """requires http;
requires fs;
async fn main() -> i64 {
  response: string = await http.post("https://api.example.com/submit", "{\\\"data\\\": \\\"test\\\"}");
  fs.write_file("/tmp/submit_response.json", response);
  println("Response saved");
  return 0;
}"""))

    # --- http + jq ---
    examples.append(("Fetch and parse JSON with http", """requires http;
requires jq;
async fn main() -> i64 {
  data: string = await http.get("https://api.example.com/users");
  names: string = jq.query(".[].name", data);
  println(names);
  return 0;
}"""))

    # ============================================================
    # SECTION 2: Real-world task patterns (single + multi cap)
    # ============================================================

    # --- DevOps patterns ---
    examples.append(("Pre-deploy checklist", """requires git;
requires cargo;
requires log;
async fn main() -> i64 {
  log.info("Running pre-deploy checklist");
  status: string = git.status();
  diff: string = git.diff();
  if diff.len > 0 {
    log.error("Uncommitted changes detected");
    println(status);
    return 1;
  }
  test_r: int = await cargo.test(".");
  if test_r != 0 {
    log.error("Tests failed");
    return 1;
  }
  log.info("All checks passed, ready to deploy");
  return 0;
}"""))

    examples.append(("Release preparation workflow", """requires git;
requires cargo;
requires log;
async fn main() -> i64 {
  log.info("Preparing release...");
  fmt_r: int = await cargo.fmt(".");
  clippy_out: string = await cargo.clippy(".");
  println(clippy_out);
  test_r: int = await cargo.test(".");
  if test_r == 0 {
    result: int = git.add(".");
    msg: string = git.commit("Release preparation: format and lint");
    println(msg);
    log.info("Release commit created");
  } else {
    log.error("Cannot release: tests failed");
  }
  return 0;
}"""))

    examples.append(("Container deployment check", """requires docker;
requires curl;
requires log;
async fn main() -> i64 {
  log.info("Checking deployment...");
  containers: string = docker.ps("");
  log.info(containers);
  response: string = await curl.get("http://localhost:8080/health");
  log.info(f"Health: {response}");
  return 0;
}"""))

    examples.append(("Docker build and push workflow", """requires docker;
requires git;
requires log;
async fn main() -> i64 {
  log.info("Building Docker image...");
  build_out: string = await docker.build(".", "myapp:latest");
  println(build_out);
  log_out: string = git.log("--oneline -1");
  log.info(f"Built from commit: {log_out}");
  return 0;
}"""))

    # --- Code quality patterns ---
    examples.append(("Code quality audit", """requires grep;
requires find;
requires log;
async fn main() -> i64 {
  log.info("Running code quality audit");
  todo_count: int = grep.count("TODO", "src/");
  fixme_count: int = grep.count("FIXME", "src/");
  log.info(f"TODOs: {todo_count}, FIXMEs: {fixme_count}");
  large_files: string = await find.by_min_size(102400, "src/");
  log.info(f"Large source files: {large_files}");
  return 0;
}"""))

    examples.append(("Security scan for hardcoded credentials", """requires grep;
requires log;
async fn main() -> i64 {
  log.info("Scanning for hardcoded credentials...");
  passwords: string = await grep.search_recursive("password.*=.*\\\"", "src/");
  tokens: string = await grep.search_recursive("token.*=.*\\\"", "src/");
  api_keys: string = await grep.search_recursive("api_key.*=.*\\\"", "src/");
  if passwords.len > 0 {
    log.warn("Potential hardcoded passwords found");
    println(passwords);
  }
  if tokens.len > 0 {
    log.warn("Potential hardcoded tokens found");
    println(tokens);
  }
  if api_keys.len > 0 {
    log.warn("Potential hardcoded API keys found");
    println(api_keys);
  }
  return 0;
}"""))

    examples.append(("Find dead code candidates", """requires grep;
requires find;
async fn main() -> i64 {
  files: string = await find.by_name("*.rs", "src/");
  println("Source files:");
  println(files);
  unused: string = await grep.search_recursive("allow.*dead_code", "src/");
  println("Dead code annotations:");
  println(unused);
  return 0;
}"""))

    # --- Data processing patterns ---
    examples.append(("ETL: extract, transform, load CSV data", """requires fs;
requires awk;
requires sed;
async fn main() -> i64 {
  raw: string = fs.read_file("input.csv");
  cleaned: string = sed.delete_matching("^#", raw);
  names: string = awk.field(1, ",", cleaned);
  values: string = awk.field(2, ",", cleaned);
  total: float = awk.sum_field(2, ",", cleaned);
  print_string("Total: ");
  print_f64(total);
  println("");
  fs.write_file("output.csv", cleaned);
  return 0;
}"""))

    examples.append(("Process JSON API data into CSV", """requires curl;
requires jq;
requires fs;
async fn main() -> i64 {
  raw: string = await curl.get("https://api.example.com/records");
  names: string = jq.query(".[].name", raw);
  values: string = jq.query(".[].value", raw);
  fs.write_file("/tmp/names.txt", names);
  fs.write_file("/tmp/values.txt", values);
  println("Data extracted and saved");
  return 0;
}"""))

    examples.append(("Aggregate data from file", """requires fs;
requires awk;
async fn main() -> i64 {
  data: string = fs.read_file("metrics.csv");
  total: float = awk.sum_field(2, ",", data);
  unique: string = awk.unique_field(1, ",", data);
  count: int = awk.count_matching("error", data);
  print_string("Total: ");
  print_f64(total);
  println("");
  println(f"Unique keys: {unique}");
  println(f"Errors: {count}");
  return 0;
}"""))

    # --- Project management patterns ---
    examples.append(("Daily standup report", """requires git;
requires gh;
requires log;
async fn main() -> i64 {
  log.info("Generating daily report...");
  log_out: string = git.log("--oneline --since=yesterday");
  println("Commits since yesterday:");
  println(log_out);
  prs: string = await gh.pr_list("open");
  println("Open PRs:");
  println(prs);
  issues: string = await gh.issue_list("open");
  println("Open issues:");
  println(issues);
  return 0;
}"""))

    examples.append(("PR review workflow", """requires gh;
requires git;
requires grep;
async fn main() -> i64 {
  pr: string = await gh.pr_view(42);
  println("PR Details:");
  println(pr);
  diff: string = git.diff();
  println("Changes:");
  println(diff);
  todos: string = await grep.search_recursive("TODO\\|HACK\\|FIXME", "src/");
  if todos.len > 0 {
    println("WARNING: Unresolved items:");
    println(todos);
  }
  return 0;
}"""))

    # --- System administration patterns ---
    examples.append(("System health check", """requires process;
requires fs;
requires log;
async fn main() -> i64 {
  log.info("System health check starting");
  cwd_val: string = process.cwd();
  log.info(f"CWD: {cwd_val}");
  home: string = process.getenv("HOME");
  log.info(f"HOME: {home}");
  ts: int = process.timestamp();
  log.info(f"Timestamp: {ts}");
  hosts_exists: bool = fs.exists("/etc/hosts");
  if hosts_exists {
    log.info("Hosts file exists");
  } else {
    log.error("Hosts file missing!");
  }
  return 0;
}"""))

    examples.append(("Disk usage report", """requires find;
requires fs;
requires log;
async fn main() -> i64 {
  log.info("Generating disk usage report");
  large: string = await find.by_min_size(10485760, "/tmp");
  println("Files over 10MB in /tmp:");
  println(large);
  old: string = await find.modified_before(2592000, "/tmp");
  println("Files older than 30 days:");
  println(old);
  return 0;
}"""))

    examples.append(("Environment variable audit", """requires process;
requires log;
async fn main() -> i64 {
  log.info("Auditing environment variables");
  home: string = process.getenv("HOME");
  println(f"HOME={home}");
  path: string = process.getenv("PATH");
  println(f"PATH={path}");
  shell: string = process.getenv("SHELL");
  println(f"SHELL={shell}");
  user: string = process.getenv("USER");
  println(f"USER={user}");
  editor: string = process.getenv("EDITOR");
  println(f"EDITOR={editor}");
  return 0;
}"""))

    # --- Configuration management ---
    examples.append(("Validate JSON config structure", """requires fs;
requires jq;
requires log;
async fn main() -> i64 {
  log.info("Validating config...");
  config: string = fs.read_file("config.json");
  keys: string = jq.keys(config);
  log.info(f"Config keys: {keys}");
  db: string = jq.query(".database", config);
  log.info(f"Database config: {db}");
  return 0;
}"""))

    examples.append(("Migrate YAML config to new format", """requires fs;
requires yq;
requires log;
async fn main() -> i64 {
  log.info("Migrating config...");
  yaml: string = fs.read_file("old_config.yaml");
  version: string = yq.get(yaml, ".version");
  println(f"Current version: {version}");
  updated: string = yq.set(yaml, ".version", "2.0");
  updated2: string = yq.delete_key(updated, ".deprecated_field");
  fs.write_file("new_config.yaml", updated2);
  log.info("Migration complete");
  return 0;
}"""))

    examples.append(("Sync config between JSON and YAML", """requires fs;
requires jq;
requires yq;
async fn main() -> i64 {
  json_config: string = fs.read_file("config.json");
  name: string = jq.query(".name", json_config);
  yaml_config: string = fs.read_file("config.yaml");
  yaml_name: string = yq.get(yaml_config, ".name");
  println(f"JSON name: {name}");
  println(f"YAML name: {yaml_name}");
  return 0;
}"""))

    # --- Testing patterns ---
    examples.append(("Run test suite with timing", """requires cargo;
requires process;
requires log;
async fn main() -> i64 {
  log.info("Running test suite");
  start: int = process.timestamp();
  test_r: int = await cargo.test(".");
  end: int = process.timestamp();
  elapsed: int = end - start;
  if test_r == 0 {
    log.info(f"All tests passed in {elapsed}ms");
  } else {
    log.error(f"Tests failed after {elapsed}ms");
  }
  return 0;
}"""))

    examples.append(("Test and coverage workflow", """requires cargo;
requires grep;
requires log;
async fn main() -> i64 {
  log.info("Running tests...");
  test_r: int = await cargo.test(".");
  println(f"Test result: {test_r}");
  test_fns: string = await grep.search_recursive("fn test_\\|#\\[test\\]", "src/");
  println("Test functions found:");
  println(test_fns);
  return 0;
}"""))

    # --- Monitoring patterns ---
    examples.append(("Service health dashboard", """requires curl;
requires docker;
requires log;
async fn main() -> i64 {
  log.info("Service health check");
  containers: string = docker.ps("");
  println("Running containers:");
  println(containers);
  health: string = await curl.get("http://localhost:8080/health");
  println(f"API health: {health}");
  metrics: string = await curl.get("http://localhost:9090/metrics");
  println(f"Metrics: {metrics}");
  return 0;
}"""))

    examples.append(("API latency benchmark", """requires curl;
requires process;
requires math;
async fn main() -> i64 {
  t1: int = process.timestamp();
  r1: string = await curl.get("https://api.example.com/ping");
  t2: int = process.timestamp();
  r2: string = await curl.get("https://api.example.com/ping");
  t3: int = process.timestamp();
  lat1: int = math.subtract(t2, t1);
  lat2: int = math.subtract(t3, t2);
  avg: int = math.divide(math.add(lat1, lat2), 2);
  println(f"Latency 1: {lat1}ms");
  println(f"Latency 2: {lat2}ms");
  println(f"Average: {avg}ms");
  return 0;
}"""))

    # ============================================================
    # SECTION 3: More single-capability variety
    # ============================================================

    # --- More git patterns ---
    examples.append(("Show git log with author filter", """requires git;
async fn main() -> i64 {
  log_out: string = git.log("--oneline --author=rix -10");
  println(log_out);
  return 0;
}"""))

    examples.append(("Show commits from last week", """requires git;
async fn main() -> i64 {
  log_out: string = git.log("--oneline --since='1 week ago'");
  println(log_out);
  return 0;
}"""))

    examples.append(("Rebase current branch onto main", """requires git;
async fn main() -> i64 {
  result: string = git.rebase("main");
  println(result);
  return 0;
}"""))

    examples.append(("Merge feature branch", """requires git;
async fn main() -> i64 {
  result: int = git.checkout("main");
  merge_result: string = git.merge("feature-branch");
  println(merge_result);
  return 0;
}"""))

    examples.append(("Stage specific files", """requires git;
async fn main() -> i64 {
  r1: int = git.add("src/main.rs");
  r2: int = git.add("Cargo.toml");
  status: string = git.status();
  println(status);
  return 0;
}"""))

    examples.append(("Git workflow: stash, pull, pop, push", """requires git;
async fn main() -> i64 {
  stash_r: string = git.stash("push");
  println(stash_r);
  pull_r: string = await git.pull("origin", "main");
  println(pull_r);
  pop_r: string = git.stash("pop");
  println(pop_r);
  push_r: string = await git.push("origin", "main");
  println(push_r);
  return 0;
}"""))

    # --- More grep patterns ---
    examples.append(("Search for function definitions", """requires grep;
async fn main() -> i64 {
  fns: string = await grep.search_recursive("^pub fn\\|^fn\\|^async fn", "src/");
  println(fns);
  return 0;
}"""))

    examples.append(("Find struct definitions", """requires grep;
async fn main() -> i64 {
  structs: string = await grep.search_recursive("^pub struct\\|^struct", "src/");
  println(structs);
  return 0;
}"""))

    examples.append(("Count lines matching multiple patterns", """requires grep;
async fn main() -> i64 {
  errors: int = grep.count("ERROR", "app.log");
  warnings: int = grep.count("WARN", "app.log");
  info_count: int = grep.count("INFO", "app.log");
  println(f"Errors: {errors}");
  println(f"Warnings: {warnings}");
  println(f"Info: {info_count}");
  return 0;
}"""))

    examples.append(("Search for imports in Python files", """requires grep;
async fn main() -> i64 {
  imports: string = await grep.search_recursive("^import\\|^from.*import", ".");
  println(imports);
  return 0;
}"""))

    examples.append(("Find all IP addresses in config", """requires grep;
async fn main() -> i64 {
  ips: string = await grep.search_recursive("[0-9]\\+\\.[0-9]\\+\\.[0-9]\\+\\.[0-9]\\+", "config/");
  println("IP addresses found:");
  println(ips);
  return 0;
}"""))

    # --- More find patterns ---
    examples.append(("Find executable files", """requires find;
async fn main() -> i64 {
  bins: string = await find.by_name_and_type("*", "f", "target/release/");
  println(bins);
  return 0;
}"""))

    examples.append(("Find empty directories", """requires find;
async fn main() -> i64 {
  dirs: string = await find.by_type("d", ".");
  println("Directories:");
  println(dirs);
  return 0;
}"""))

    examples.append(("Find TOML config files", """requires find;
async fn main() -> i64 {
  files: string = await find.by_name("*.toml", ".");
  println("TOML files:");
  println(files);
  return 0;
}"""))

    examples.append(("Find Dockerfiles", """requires find;
async fn main() -> i64 {
  files: string = await find.by_name("Dockerfile*", ".");
  println("Dockerfiles:");
  println(files);
  return 0;
}"""))

    examples.append(("Find shell scripts", """requires find;
async fn main() -> i64 {
  scripts: string = await find.by_name("*.sh", ".");
  println("Shell scripts:");
  println(scripts);
  return 0;
}"""))

    examples.append(("Find files modified in last 10 minutes", """requires find;
async fn main() -> i64 {
  recent: string = await find.modified_within(600, ".");
  println("Recently modified:");
  println(recent);
  return 0;
}"""))

    # --- More curl patterns ---
    examples.append(("DELETE API resource", """requires curl;
async fn main() -> i64 {
  response: string = await curl.delete("https://api.example.com/items/42");
  println(response);
  return 0;
}"""))

    examples.append(("PUT update to API", """requires curl;
async fn main() -> i64 {
  response: string = await curl.put("https://api.example.com/items/42", "{\\\"status\\\": \\\"updated\\\"}");
  println(response);
  return 0;
}"""))

    examples.append(("Download multiple files", """requires curl;
async fn main() -> i64 {
  b1: int = await curl.download("https://example.com/file1.txt", "/tmp/file1.txt");
  b2: int = await curl.download("https://example.com/file2.txt", "/tmp/file2.txt");
  println(f"File 1: {b1} bytes, File 2: {b2} bytes");
  return 0;
}"""))

    examples.append(("Authenticated API with Bearer token", """requires curl;
async fn main() -> i64 {
  response: string = await curl.get_with_header("https://api.example.com/protected", "Authorization: Bearer abc123");
  println(response);
  return 0;
}"""))

    examples.append(("JSON API with content type header", """requires curl;
async fn main() -> i64 {
  response: string = await curl.get_with_header("https://api.example.com/data", "Accept: application/json");
  println(response);
  return 0;
}"""))

    # --- More docker patterns ---
    examples.append(("Run command in container", """requires docker;
async fn main() -> i64 {
  output: string = docker.exec("mydb", "psql -c 'SELECT count(*) FROM users;'");
  println(output);
  return 0;
}"""))

    examples.append(("Docker container lifecycle", """requires docker;
async fn main() -> i64 {
  run_output: string = docker.run("nginx:latest", "-d --name web");
  println(f"Started: {run_output}");
  logs: string = docker.logs("web");
  println(f"Logs: {logs}");
  stop_r: int = docker.stop("web");
  rm_r: int = docker.rm("web");
  println("Container cleaned up");
  return 0;
}"""))

    examples.append(("List Docker images with filter", """requires docker;
async fn main() -> i64 {
  all: string = docker.images("");
  println("All images:");
  println(all);
  containers: string = docker.ps("-a --filter status=running");
  println("Running:");
  println(containers);
  return 0;
}"""))

    # --- More gh patterns ---
    examples.append(("List and view latest PR", """requires gh;
async fn main() -> i64 {
  prs: string = await gh.pr_list("open");
  println(prs);
  pr: string = await gh.pr_view(1);
  println(pr);
  return 0;
}"""))

    examples.append(("Create issue from template", """requires gh;
async fn main() -> i64 {
  result: string = await gh.issue_create("Performance regression", "API response times increased 3x after last deploy.\\n\\nSteps:\\n1. Hit /api/data endpoint\\n2. Measure response time");
  println(result);
  return 0;
}"""))

    examples.append(("Check CI status for workflow", """requires gh;
async fn main() -> i64 {
  runs: string = await gh.run_list("build.yml");
  println("Build runs:");
  println(runs);
  test_runs: string = await gh.run_list("test.yml");
  println("Test runs:");
  println(test_runs);
  return 0;
}"""))

    examples.append(("Clone and inspect repository", """requires gh;
async fn main() -> i64 {
  result: int = await gh.repo_clone("owner/repo", "/tmp/repo_clone");
  println(f"Clone result: {result}");
  return 0;
}"""))

    # --- More cargo patterns ---
    examples.append(("Run specific binary with args", """requires cargo;
async fn main() -> i64 {
  output: string = await cargo.run(".", "--release -- --config prod.toml");
  println(output);
  return 0;
}"""))

    examples.append(("Full quality check pipeline", """requires cargo;
async fn main() -> i64 {
  fmt_r: int = await cargo.fmt(".");
  check_r: int = await cargo.check(".");
  clippy_out: string = await cargo.clippy(".");
  test_r: int = await cargo.test(".");
  println(f"Format: {fmt_r}");
  println(f"Check: {check_r}");
  println(f"Clippy: {clippy_out}");
  println(f"Test: {test_r}");
  return 0;
}"""))

    # --- More python3 patterns ---
    examples.append(("Run Python script with arguments", """requires python3;
async fn main() -> i64 {
  output: string = await python3.run_script_args("process.py", "--input data.csv --output result.json");
  println(output);
  return 0;
}"""))

    examples.append(("Execute multi-line Python code", """requires python3;
async fn main() -> i64 {
  output: string = python3.exec("import math; print(f'Pi={math.pi:.6f}'); print(f'E={math.e:.6f}')");
  println(output);
  return 0;
}"""))

    examples.append(("Check Python version and install package", """requires python3;
async fn main() -> i64 {
  ver: string = python3.version();
  println(f"Python: {ver}");
  install_r: string = await python3.pip_install("pandas");
  println(install_r);
  return 0;
}"""))

    # --- More fs patterns ---
    examples.append(("Copy file contents", """requires fs;
async fn main() -> i64 {
  contents: string = fs.read_file("source.txt");
  fs.write_file("destination.txt", contents);
  println("File copied");
  return 0;
}"""))

    examples.append(("Create multiple files", """requires fs;
async fn main() -> i64 {
  fs.write_file("/tmp/file1.txt", "Content 1");
  fs.write_file("/tmp/file2.txt", "Content 2");
  fs.write_file("/tmp/file3.txt", "Content 3");
  println("Three files created");
  return 0;
}"""))

    examples.append(("Check multiple files exist", """requires fs;
async fn main() -> i64 {
  has_cargo: bool = fs.exists("Cargo.toml");
  has_lock: bool = fs.exists("Cargo.lock");
  has_src: bool = fs.exists("src/main.rs");
  println(f"Cargo.toml: {has_cargo}");
  println(f"Cargo.lock: {has_lock}");
  println(f"src/main.rs: {has_src}");
  return 0;
}"""))

    examples.append(("Append multiple entries to log", """requires fs;
async fn main() -> i64 {
  fs.append_file("activity.log", "Step 1: Started\\n");
  fs.append_file("activity.log", "Step 2: Processing\\n");
  fs.append_file("activity.log", "Step 3: Complete\\n");
  contents: string = fs.read_file("activity.log");
  println(contents);
  return 0;
}"""))

    # --- More sed patterns ---
    examples.append(("Multi-step text transformation", """requires sed;
async fn main() -> i64 {
  text: string = "Hello World, Hello Universe";
  step1: string = sed.substitute("Hello", "Hi", text);
  step2: string = sed.substitute("World", "Earth", step1);
  println(step2);
  return 0;
}"""))

    examples.append(("Clean up whitespace in file", """requires sed;
async fn main() -> i64 {
  result: string = sed.substitute_all_in_file("  ", " ", "messy.txt");
  println(result);
  return 0;
}"""))

    examples.append(("Add header to matching lines", """requires sed;
async fn main() -> i64 {
  text: string = "data1\\nIMPORTANT data2\\ndata3\\nIMPORTANT data4";
  result: string = sed.insert_before("IMPORTANT", ">>> ", text);
  println(result);
  return 0;
}"""))

    # --- More awk patterns ---
    examples.append(("Extract first and last fields", """requires awk;
async fn main() -> i64 {
  data: string = "Alice,25,NYC,Engineer\\nBob,30,LA,Designer";
  first: string = awk.field(1, ",", data);
  last: string = awk.field(4, ",", data);
  println(f"Names: {first}");
  println(f"Roles: {last}");
  return 0;
}"""))

    examples.append(("Filter and count matching lines", """requires awk;
async fn main() -> i64 {
  data: string = "200 OK\\n404 Not Found\\n200 OK\\n500 Error\\n200 OK";
  ok_count: int = awk.count_matching("200", data);
  err_count: int = awk.count_matching("500", data);
  println(f"200 OK count: {ok_count}");
  println(f"500 errors: {err_count}");
  return 0;
}"""))

    # --- More jq patterns ---
    examples.append(("Nested JSON query", """requires jq;
async fn main() -> i64 {
  json: string = "{\\\"user\\\": {\\\"name\\\": \\\"Alice\\\", \\\"age\\\": 30}}";
  name: string = jq.query(".user.name", json);
  age: string = jq.query(".user.age", json);
  println(f"Name: {name}, Age: {age}");
  return 0;
}"""))

    examples.append(("Filter and transform JSON", """requires jq;
async fn main() -> i64 {
  json: string = "[{\\\"id\\\": 1, \\\"active\\\": true}, {\\\"id\\\": 2, \\\"active\\\": false}]";
  active: string = jq.filter("select(.active)", json);
  println(f"Active items: {active}");
  return 0;
}"""))

    # --- More yq patterns ---
    examples.append(("Query nested YAML structure", """requires yq;
async fn main() -> i64 {
  yaml: string = "app:\\n  server:\\n    host: 0.0.0.0\\n    port: 8080";
  host: string = yq.get(yaml, ".app.server.host");
  port: string = yq.get(yaml, ".app.server.port");
  println(f"Server: {host}:{port}");
  return 0;
}"""))

    examples.append(("Multiple YAML operations", """requires yq;
async fn main() -> i64 {
  yaml: string = "name: myapp\\nversion: 1.0\\nenvironment: dev";
  updated: string = yq.set(yaml, ".version", "2.0");
  updated2: string = yq.set(updated, ".environment", "prod");
  println(updated2);
  return 0;
}"""))

    # --- More math patterns ---
    examples.append(("Arithmetic sequence", """requires math;
async fn main() -> i64 {
  a1: int = 5;
  d: int = 3;
  a2: int = math.add(a1, d);
  a3: int = math.add(a2, d);
  a4: int = math.add(a3, d);
  sum: int = math.add(math.add(a1, a2), math.add(a3, a4));
  println(f"Sequence: {a1}, {a2}, {a3}, {a4}");
  println(f"Sum: {sum}");
  return 0;
}"""))

    examples.append(("Min-max normalization bounds", """requires math;
async fn main() -> i64 {
  vals: i64[] = [15, 3, 42, 7, 28];
  current_min: int = math.min(vals[0], vals[1]);
  current_min2: int = math.min(current_min, vals[2]);
  current_min3: int = math.min(current_min2, vals[3]);
  final_min: int = math.min(current_min3, vals[4]);
  current_max: int = math.max(vals[0], vals[1]);
  current_max2: int = math.max(current_max, vals[2]);
  current_max3: int = math.max(current_max2, vals[3]);
  final_max: int = math.max(current_max3, vals[4]);
  range: int = math.subtract(final_max, final_min);
  println(f"Min: {final_min}, Max: {final_max}, Range: {range}");
  return 0;
}"""))

    # --- More log patterns ---
    examples.append(("Application lifecycle logging", """requires log;
async fn main() -> i64 {
  log.info("Application starting");
  log.debug("Loading configuration");
  log.info("Configuration loaded");
  log.warn("Using default database port");
  log.info("Server listening on port 8080");
  log.info("Application ready");
  return 0;
}"""))

    examples.append(("Error handling with logging", """requires log;
async fn main() -> i64 {
  log.info("Processing batch job");
  log.debug("Reading input data");
  log.info("Processed 100 records");
  log.warn("5 records had missing fields");
  log.error("2 records failed validation");
  log.info("Batch job complete");
  return 0;
}"""))

    # --- More process patterns ---
    examples.append(("Environment setup validation", """requires process;
async fn main() -> i64 {
  home: string = process.getenv("HOME");
  user: string = process.getenv("USER");
  shell: string = process.getenv("SHELL");
  lang: string = process.getenv("LANG");
  println(f"User: {user}");
  println(f"Home: {home}");
  println(f"Shell: {shell}");
  println(f"Lang: {lang}");
  return 0;
}"""))

    examples.append(("Delayed sequential operations", """requires process;
async fn main() -> i64 {
  println("Step 1: Initializing");
  await process.sleep(100);
  println("Step 2: Processing");
  await process.sleep(200);
  println("Step 3: Finalizing");
  await process.sleep(50);
  println("Done");
  return 0;
}"""))

    # --- More timer patterns ---
    examples.append(("Cascading timers", """requires timer;
async fn main() -> i64 {
  r1: int = await timer.setTimeout(50);
  println(f"Timer 1: {r1}");
  r2: int = await timer.setTimeout(100);
  println(f"Timer 2: {r2}");
  r3: int = await timer.setTimeout(25);
  println(f"Timer 3: {r3}");
  return 0;
}"""))

    # --- More http patterns ---
    examples.append(("GET and POST with http capability", """requires http;
async fn main() -> i64 {
  config: string = await http.get("https://api.example.com/config");
  println(f"Config: {config}");
  result: string = await http.post("https://api.example.com/ack", "{\\\"received\\\": true}");
  println(f"Ack: {result}");
  return 0;
}"""))

    examples.append(("Fetch multiple endpoints", """requires http;
async fn main() -> i64 {
  users: string = await http.get("https://api.example.com/users");
  products: string = await http.get("https://api.example.com/products");
  orders: string = await http.get("https://api.example.com/orders");
  println(f"Users: {users}");
  println(f"Products: {products}");
  println(f"Orders: {orders}");
  return 0;
}"""))

    # ============================================================
    # SECTION 4: More complex 3-capability compositions
    # ============================================================

    examples.append(("Full project report with git, find, grep", """requires git;
requires find;
requires grep;
async fn main() -> i64 {
  status: string = git.status();
  println("Repository Status:");
  println(status);
  log_out: string = git.log("--oneline -5");
  println("Recent commits:");
  println(log_out);
  file_count: int = await find.count("*.rs", "src/");
  println(f"Source files: {file_count}");
  todos: string = await grep.search_recursive("TODO", "src/");
  println("TODO items:");
  println(todos);
  return 0;
}"""))

    examples.append(("API data pipeline: fetch, parse, store", """requires curl;
requires jq;
requires fs;
async fn main() -> i64 {
  raw: string = await curl.get("https://api.example.com/orders");
  total: string = jq.query(".total", raw);
  items: string = jq.query(".items", raw);
  println(f"Total orders: {total}");
  fs.write_file("/tmp/orders.json", items);
  sz: int = fs.file_size("/tmp/orders.json");
  println(f"Saved {sz} bytes");
  return 0;
}"""))

    examples.append(("Build, test, and deploy pipeline", """requires cargo;
requires git;
requires docker;
async fn main() -> i64 {
  test_r: int = await cargo.test(".");
  println(f"Tests: {test_r}");
  if test_r == 0 {
    build_out: string = await docker.build(".", "myapp:latest");
    println(build_out);
    result: int = git.add(".");
    msg: string = git.commit("Build and deploy");
    println(msg);
  }
  return 0;
}"""))

    examples.append(("Config migration: read, transform, write", """requires fs;
requires yq;
requires log;
async fn main() -> i64 {
  log.info("Starting config migration");
  old: string = fs.read_file("config.v1.yaml");
  json: string = yq.to_json(old);
  log.info(f"Converted to JSON: {json}");
  new_yaml: string = yq.set(old, ".version", "2");
  fs.write_file("config.v2.yaml", new_yaml);
  log.info("Migration complete");
  return 0;
}"""))

    examples.append(("Data analysis: read CSV, process, report", """requires fs;
requires awk;
requires log;
async fn main() -> i64 {
  log.info("Processing sales data");
  data: string = fs.read_file("sales.csv");
  total: float = awk.sum_field(3, ",", data);
  regions: string = awk.unique_field(1, ",", data);
  row_count: int = awk.field_count(",", data);
  log.info(f"Columns: {row_count}");
  print_string("Total revenue: ");
  print_f64(total);
  println("");
  println(f"Regions: {regions}");
  return 0;
}"""))

    examples.append(("Search codebase and generate report", """requires grep;
requires find;
requires fs;
async fn main() -> i64 {
  rs_files: int = await find.count("*.rs", "src/");
  py_files: int = await find.count("*.py", ".");
  todos: string = await grep.search_recursive("TODO", ".");
  panics: string = await grep.search_recursive("panic!", "src/");
  report: string = f"Code Report\\n===========\\nRust files: {rs_files}\\nPython files: {py_files}\\n\\nTODOs:\\n{todos}\\n\\nPanics:\\n{panics}";
  fs.write_file("/tmp/code_audit.txt", report);
  println("Audit report saved");
  return 0;
}"""))

    examples.append(("Dependency check workflow", """requires cargo;
requires fs;
requires grep;
async fn main() -> i64 {
  check_r: int = await cargo.check(".");
  println(f"Cargo check: {check_r}");
  cargo_toml: string = fs.read_file("Cargo.toml");
  println("Cargo.toml:");
  println(cargo_toml);
  deps: string = grep.search("\\[dependencies\\]", "Cargo.toml");
  println(f"Dependencies section: {deps}");
  return 0;
}"""))

    examples.append(("Git bisect helper: test each commit", """requires git;
requires cargo;
requires log;
async fn main() -> i64 {
  log.info("Testing current commit...");
  log_out: string = git.log("--oneline -1");
  log.info(f"Commit: {log_out}");
  test_r: int = await cargo.test(".");
  if test_r == 0 {
    log.info("Test PASSED");
  } else {
    log.error("Test FAILED");
  }
  return 0;
}"""))

    examples.append(("Infrastructure snapshot", """requires docker;
requires process;
requires fs;
async fn main() -> i64 {
  containers: string = docker.ps("-a");
  images: string = docker.images("");
  cwd_val: string = process.cwd();
  ts: int = process.timestamp();
  snapshot: string = f"Timestamp: {ts}\\nCWD: {cwd_val}\\n\\nContainers:\\n{containers}\\n\\nImages:\\n{images}";
  fs.write_file("/tmp/infra_snapshot.txt", snapshot);
  println("Snapshot saved");
  return 0;
}"""))

    examples.append(("JSON to YAML migration", """requires fs;
requires jq;
requires yq;
async fn main() -> i64 {
  json_str: string = fs.read_file("settings.json");
  keys: string = jq.keys(json_str);
  println(f"Settings keys: {keys}");
  yaml_str: string = yq.from_json(json_str);
  fs.write_file("settings.yaml", yaml_str);
  println("Migrated to YAML");
  return 0;
}"""))

    examples.append(("Text processing pipeline", """requires fs;
requires sed;
requires awk;
async fn main() -> i64 {
  raw: string = fs.read_file("raw_data.txt");
  cleaned: string = sed.delete_matching("^#", raw);
  cleaned2: string = sed.substitute_all("  ", " ", cleaned);
  names: string = awk.field(1, ",", cleaned2);
  fs.write_file("processed.txt", names);
  println("Processing complete");
  return 0;
}"""))

    examples.append(("Webhook handler: receive and process", """requires http;
requires jq;
requires log;
async fn main() -> i64 {
  log.info("Fetching webhook events");
  events: string = await http.get("https://hooks.example.com/events");
  event_type: string = jq.query(".[0].type", events);
  log.info(f"Latest event type: {event_type}");
  payload: string = jq.query(".[0].payload", events);
  println(payload);
  return 0;
}"""))

    examples.append(("Codebase statistics generator", """requires find;
requires grep;
requires math;
async fn main() -> i64 {
  rs: int = await find.count("*.rs", ".");
  py: int = await find.count("*.py", ".");
  ts: int = await find.count("*.ts", ".");
  total: int = math.add(math.add(rs, py), ts);
  println(f"Rust: {rs}");
  println(f"Python: {py}");
  println(f"TypeScript: {ts}");
  println(f"Total source files: {total}");
  todo_count: int = grep.count("TODO", "src/");
  println(f"TODOs: {todo_count}");
  return 0;
}"""))

    examples.append(("Multi-format config reader", """requires fs;
requires jq;
requires yq;
async fn main() -> i64 {
  json_exists: bool = fs.exists("config.json");
  yaml_exists: bool = fs.exists("config.yaml");
  if json_exists {
    config: string = fs.read_file("config.json");
    name: string = jq.query(".name", config);
    println(f"JSON config name: {name}");
  }
  if yaml_exists {
    config: string = fs.read_file("config.yaml");
    name: string = yq.get(config, ".name");
    println(f"YAML config name: {name}");
  }
  return 0;
}"""))

    examples.append(("End-to-end test helper", """requires cargo;
requires curl;
requires process;
async fn main() -> i64 {
  build_r: int = await cargo.build(".");
  println(f"Build: {build_r}");
  await process.sleep(2000);
  health: string = await curl.get("http://localhost:8080/health");
  println(f"Health: {health}");
  test_r: int = await cargo.test(".");
  println(f"Tests: {test_r}");
  return 0;
}"""))

    examples.append(("Scheduled data fetch and store", """requires curl;
requires fs;
requires process;
async fn main() -> i64 {
  ts: int = process.timestamp();
  data: string = await curl.get("https://api.example.com/metrics");
  filename: string = f"/tmp/metrics_{ts}.json";
  fs.write_file(filename, data);
  println(f"Metrics saved to {filename}");
  return 0;
}"""))

    examples.append(("Log file analysis pipeline", """requires fs;
requires grep;
requires awk;
async fn main() -> i64 {
  error_lines: string = grep.search("ERROR", "server.log");
  timestamps: string = awk.field(1, " ", error_lines);
  println("Error timestamps:");
  println(timestamps);
  error_count: int = grep.count("ERROR", "server.log");
  warn_count: int = grep.count("WARN", "server.log");
  println(f"Errors: {error_count}, Warnings: {warn_count}");
  return 0;
}"""))

    examples.append(("Release notes generator", """requires git;
requires gh;
requires fs;
async fn main() -> i64 {
  log_out: string = git.log("--oneline --since='2 weeks ago'");
  prs: string = await gh.pr_list("closed");
  notes: string = f"Release Notes\\n=============\\n\\nCommits:\\n{log_out}\\n\\nMerged PRs:\\n{prs}";
  fs.write_file("/tmp/release_notes.md", notes);
  println("Release notes generated");
  return 0;
}"""))

    examples.append(("Docker monitoring with alerts", """requires docker;
requires curl;
requires log;
async fn main() -> i64 {
  containers: string = docker.ps("");
  log.info(f"Containers: {containers}");
  health: string = await curl.get("http://localhost:8080/health");
  log.info(f"App health: {health}");
  db_logs: string = docker.logs("postgres");
  log.debug(f"DB logs: {db_logs}");
  return 0;
}"""))

    examples.append(("Python test runner with reporting", """requires python3;
requires fs;
requires log;
async fn main() -> i64 {
  log.info("Running Python tests");
  output: string = await python3.run_module("pytest", "tests/ -v");
  fs.write_file("/tmp/test_output.txt", output);
  log.info("Test output saved");
  println(output);
  return 0;
}"""))

    examples.append(("Search and patch workflow", """requires grep;
requires sed;
requires git;
async fn main() -> i64 {
  files: string = grep.files_matching("deprecated_fn", "src/");
  println("Files to patch:");
  println(files);
  result: string = sed.substitute_all_in_file("deprecated_fn", "new_fn", "src/lib.rs");
  status: string = git.status();
  println(status);
  return 0;
}"""))

    examples.append(("Multi-project build check", """requires cargo;
requires find;
requires log;
async fn main() -> i64 {
  tomls: string = await find.by_name("Cargo.toml", ".");
  println("Cargo projects found:");
  println(tomls);
  log.info("Checking main project...");
  check_r: int = await cargo.check(".");
  log.info(f"Check result: {check_r}");
  return 0;
}"""))

    examples.append(("Environment-aware API call", """requires process;
requires curl;
requires log;
async fn main() -> i64 {
  api_url: string = process.getenv("API_BASE_URL");
  log.info(f"Using API: {api_url}");
  health_url: string = f"{api_url}/health";
  response: string = await curl.get(health_url);
  log.info(f"Health: {response}");
  return 0;
}"""))

    examples.append(("File integrity checker", """requires fs;
requires process;
requires log;
async fn main() -> i64 {
  log.info("Checking file integrity");
  files: string[] = ["/etc/hosts", "/etc/hostname", "/etc/resolv.conf"];
  for i in 0..3 {
    exists_val: bool = fs.exists(files[i]);
    if exists_val {
      sz: int = fs.file_size(files[i]);
      log.info(f"{files[i]}: {sz} bytes");
    } else {
      log.warn(f"{files[i]}: MISSING");
    }
  }
  return 0;
}"""))

    examples.append(("Git tag and release workflow", """requires git;
requires gh;
requires log;
async fn main() -> i64 {
  log.info("Preparing release");
  status: string = git.status();
  println(status);
  log_out: string = git.log("--oneline -10");
  println("Recent changes:");
  println(log_out);
  pr: string = await gh.pr_create("Release v2.0", "Release candidate with all changes");
  println(pr);
  return 0;
}"""))

    examples.append(("Cross-reference search: find files then grep", """requires find;
requires grep;
async fn main() -> i64 {
  yaml_files: string = await find.by_name("*.yaml", "config/");
  println("YAML configs:");
  println(yaml_files);
  port_refs: string = await grep.search_recursive("port:", "config/");
  println("Port configurations:");
  println(port_refs);
  host_refs: string = await grep.search_recursive("host:", "config/");
  println("Host configurations:");
  println(host_refs);
  return 0;
}"""))

    examples.append(("Data validation pipeline", """requires fs;
requires jq;
requires log;
async fn main() -> i64 {
  log.info("Validating data files");
  data: string = fs.read_file("input.json");
  keys: string = jq.keys(data);
  log.info(f"Fields present: {keys}");
  values: string = jq.values(data);
  log.info(f"Values: {values}");
  filtered: string = jq.filter("select(.valid == true)", data);
  fs.write_file("validated.json", filtered);
  log.info("Validation complete");
  return 0;
}"""))

    return examples


def main():
    examples = generate_all()
    print(f"Generated {len(examples)} examples")

    valid = []
    invalid = 0
    invalid_samples = []

    for desc, code in examples:
        if validate_mog(code):
            valid.append(entry(desc, code))
        else:
            invalid += 1
            if len(invalid_samples) < 5:
                path = os.path.join(VALIDATE_DIR, "check.mog")
                with open(path, "w") as f:
                    f.write(code)
                result = subprocess.run(
                    [MOGC, path, "--emit-ir"],
                    capture_output=True, text=True, timeout=5
                )
                err = [l for l in (result.stdout + result.stderr).split('\n') if 'error' in l.lower()]
                invalid_samples.append((desc[:60], err[:2]))

    for desc, errs in invalid_samples:
        print(f"  INVALID: {desc}")
        for e in errs:
            print(f"    {e}")

    print(f"Valid: {len(valid)}, Invalid: {invalid}")

    with open(OUTPUT, 'w') as f:
        for item in valid:
            f.write(json.dumps(item) + '\n')

    print(f"Wrote {len(valid)} translations to {OUTPUT}")

    # Check uniqueness
    unique = set(item['output'] for item in valid)
    print(f"Unique outputs: {len(unique)}")


if __name__ == '__main__':
    main()
