#!/usr/bin/env python3
"""Translate bash commands from cap_batch_007.jsonl to Mog scripts."""

import json
import subprocess
import tempfile
import os
import re
import sys

MOGC = "/home/rix/.exophial/dc/mogfish/mog/compiler/target/release/mogc"
VALIDATE_DIR = "/tmp/mog_validate"
CAP_SRC = "/home/rix/.exophial/dc/mogfish/training/validate_env/capabilities"
INPUT = "/home/rix/.exophial/dc/mogfish/training/cap_batch_007.jsonl"
OUTPUT = "/home/rix/.exophial/dc/mogfish/training/cap_translations_007.jsonl"

# Ensure capabilities are set up
os.makedirs(f"{VALIDATE_DIR}/capabilities", exist_ok=True)
for f in os.listdir(CAP_SRC):
    if f.endswith(".mogdecl"):
        src = os.path.join(CAP_SRC, f)
        dst = os.path.join(VALIDATE_DIR, "capabilities", f)
        if not os.path.exists(dst):
            import shutil
            shutil.copy2(src, dst)


def validate_mog(code: str) -> bool:
    """Write code to temp file and validate with mogc --emit-ir."""
    path = os.path.join(VALIDATE_DIR, "check.mog")
    with open(path, "w") as f:
        f.write(code)
    try:
        result = subprocess.run(
            [MOGC, path, "--emit-ir"],
            capture_output=True, text=True, timeout=5
        )
        # Check for errors in stderr
        stderr = result.stderr.strip()
        if stderr and "error:" in stderr.lower():
            return False
        # Check stdout for error indicators
        stdout = result.stdout.strip()
        if "error:" in stdout.lower() and not stdout.startswith("data "):
            return False
        # If we got IR output, it's valid
        return "function " in stdout or "data " in stdout
    except (subprocess.TimeoutExpired, Exception):
        return False


def entry(description: str, mog_code: str) -> dict:
    return {
        "instruction": "Generate a Mog script for this task",
        "input": description,
        "output": mog_code
    }


# ============================================================
# Translation templates by command category
# ============================================================

def translate_git(cmd: str, desc: str):
    """Translate git commands to Mog."""
    results = []

    # git status
    if re.search(r'\bgit\s+status\b', cmd):
        code = """requires git;
async fn main() -> i64 {
  status: string = git.status();
  println(status);
  return 0;
}"""
        results.append((desc, code))
        results.append(("Show git working tree status", code))
        results.append(("Check for uncommitted changes in git", """requires git;
async fn main() -> i64 {
  status: string = git.status();
  println("Current repository status:");
  println(status);
  return 0;
}"""))

    # git diff
    elif re.search(r'\bgit\s+diff\b', cmd) and 'stat' not in cmd:
        code = """requires git;
async fn main() -> i64 {
  diff: string = git.diff();
  println(diff);
  return 0;
}"""
        results.append((desc, code))
        results.append(("Show unstaged changes in git", code))
        results.append(("Display git diff output", """requires git;
async fn main() -> i64 {
  diff: string = git.diff();
  if diff.len > 0 {
    println("Changes found:");
    println(diff);
  } else {
    println("No unstaged changes.");
  }
  return 0;
}"""))

    # git diff --stat
    elif re.search(r'\bgit\s+diff\b.*--stat', cmd):
        code = """requires git;
async fn main() -> i64 {
  diff: string = git.diff();
  println(diff);
  return 0;
}"""
        results.append(("Show diff summary statistics", code))

    # git log
    elif re.search(r'\bgit\s+log\b', cmd):
        args_match = re.search(r'git\s+log\s+(.*?)(?:\s*\||$)', cmd)
        args = args_match.group(1).strip() if args_match else "--oneline -10"
        code = f"""requires git;
async fn main() -> i64 {{
  log_output: string = git.log("{args}");
  println(log_output);
  return 0;
}}"""
        results.append((desc, code))
        results.append(("Show recent git commits", """requires git;
async fn main() -> i64 {
  log_output: string = git.log("--oneline -10");
  println(log_output);
  return 0;
}"""))
        results.append(("Show git log with graph", """requires git;
async fn main() -> i64 {
  log_output: string = git.log("--oneline --graph -20");
  println(log_output);
  return 0;
}"""))

    # git branch
    elif re.search(r'\bgit\s+branch\b', cmd) and 'checkout' not in cmd:
        code = """requires git;
async fn main() -> i64 {
  branches: string = git.branch();
  println(branches);
  return 0;
}"""
        results.append((desc, code))
        results.append(("List git branches", code))
        results.append(("Show current git branch", code))

    # git checkout
    elif re.search(r'\bgit\s+checkout\b', cmd):
        ref_match = re.search(r'git\s+checkout\s+(\S+)', cmd)
        ref = ref_match.group(1) if ref_match else "main"
        # Skip flags like -b
        if ref.startswith('-'):
            ref = "main"
        code = f"""requires git;
async fn main() -> i64 {{
  result: int = git.checkout("{ref}");
  println(f"Checked out {{result}}");
  return 0;
}}"""
        results.append((desc, code))
        results.append((f"Switch to branch {ref}", code))
        results.append(("Switch to main branch", """requires git;
async fn main() -> i64 {
  result: int = git.checkout("main");
  return 0;
}"""))

    # git add
    elif re.search(r'\bgit\s+add\b', cmd):
        path_match = re.search(r'git\s+add\s+(.*?)(?:\s*&&|$)', cmd)
        path = path_match.group(1).strip() if path_match else "."
        code = f"""requires git;
async fn main() -> i64 {{
  result: int = git.add("{path}");
  return 0;
}}"""
        results.append((desc, code))
        results.append(("Stage all changes for commit", """requires git;
async fn main() -> i64 {
  result: int = git.add(".");
  return 0;
}"""))

    # git commit
    elif re.search(r'\bgit\s+commit\b', cmd):
        msg_match = re.search(r'-m\s+["\']([^"\']+)["\']', cmd)
        msg = msg_match.group(1) if msg_match else "Update"
        code = f"""requires git;
async fn main() -> i64 {{
  result: string = git.commit("{msg}");
  println(result);
  return 0;
}}"""
        results.append((desc, code))
        results.append(("Create a git commit with message", code))

    # git push
    elif re.search(r'\bgit\s+push\b', cmd):
        code = """requires git;
async fn main() -> i64 {
  result: string = await git.push("origin", "main");
  println(result);
  return 0;
}"""
        results.append((desc, code))
        results.append(("Push changes to remote origin", code))
        results.append(("Push current branch to origin", """requires git;
async fn main() -> i64 {
  branch: string = git.branch();
  result: string = await git.push("origin", branch);
  println(result);
  return 0;
}"""))

    # git pull
    elif re.search(r'\bgit\s+pull\b', cmd):
        code = """requires git;
async fn main() -> i64 {
  result: string = await git.pull("origin", "main");
  println(result);
  return 0;
}"""
        results.append((desc, code))
        results.append(("Pull latest changes from remote", code))

    # git stash
    elif re.search(r'\bgit\s+stash\b', cmd):
        action_match = re.search(r'git\s+stash\s+(\w+)', cmd)
        action = action_match.group(1) if action_match else "push"
        code = f"""requires git;
async fn main() -> i64 {{
  result: string = git.stash("{action}");
  println(result);
  return 0;
}}"""
        results.append((desc, code))
        results.append(("Stash current changes", """requires git;
async fn main() -> i64 {
  result: string = git.stash("push");
  println(result);
  return 0;
}"""))
        results.append(("Pop stashed changes", """requires git;
async fn main() -> i64 {
  result: string = git.stash("pop");
  println(result);
  return 0;
}"""))

    # git merge
    elif re.search(r'\bgit\s+merge\b', cmd):
        branch_match = re.search(r'git\s+merge\s+(\S+)', cmd)
        branch = branch_match.group(1) if branch_match else "main"
        code = f"""requires git;
async fn main() -> i64 {{
  result: string = git.merge("{branch}");
  println(result);
  return 0;
}}"""
        results.append((desc, code))
        results.append((f"Merge {branch} into current branch", code))

    # git rebase
    elif re.search(r'\bgit\s+rebase\b', cmd):
        upstream_match = re.search(r'git\s+rebase\s+(\S+)', cmd)
        upstream = upstream_match.group(1) if upstream_match else "main"
        code = f"""requires git;
async fn main() -> i64 {{
  result: string = git.rebase("{upstream}");
  println(result);
  return 0;
}}"""
        results.append((desc, code))
        results.append((f"Rebase onto {upstream}", code))

    # git show (use log as approximation)
    elif re.search(r'\bgit\s+show\b', cmd):
        ref_match = re.search(r'git\s+show\s+(\S+)', cmd)
        ref = ref_match.group(1) if ref_match else "HEAD"
        code = f"""requires git;
async fn main() -> i64 {{
  output: string = git.log("-1 {ref}");
  println(output);
  return 0;
}}"""
        results.append((desc, code))

    # git ls-remote / ls-files / other git subcommands via log
    elif re.search(r'\bgit\s+(ls-|rev-parse|describe|tag)', cmd):
        # These are read operations, approximate with log
        code = """requires git;
async fn main() -> i64 {
  output: string = git.log("--oneline -5");
  println(output);
  return 0;
}"""
        results.append(("Show recent git history", code))

    # Generic git command - add/commit/status workflow
    elif 'git' in cmd:
        code = """requires git;
async fn main() -> i64 {
  status: string = git.status();
  println(status);
  return 0;
}"""
        results.append(("Check git repository status", code))

    return results


def translate_grep(cmd: str, desc: str):
    """Translate grep commands to Mog."""
    results = []

    # Extract pattern and path
    # grep [-rn] "pattern" path
    pattern_match = re.search(r'grep\s+(?:-\w+\s+)*["\']([^"\']+)["\']?\s+(\S+)', cmd)
    if not pattern_match:
        pattern_match = re.search(r'grep\s+(?:-\w+\s+)*(\S+)\s+(\S+)', cmd)

    if not pattern_match:
        return results

    pattern = pattern_match.group(1)
    path = pattern_match.group(2)
    # Escape quotes in pattern
    pattern = pattern.replace('"', '\\"')
    path = path.replace('"', '\\"')

    is_recursive = bool(re.search(r'grep\s+-[a-zA-Z]*r', cmd))
    is_count = bool(re.search(r'grep\s+-[a-zA-Z]*c', cmd))
    is_invert = bool(re.search(r'grep\s+-[a-zA-Z]*v', cmd))
    is_files_only = bool(re.search(r'grep\s+-[a-zA-Z]*l', cmd))
    is_numbered = bool(re.search(r'grep\s+-[a-zA-Z]*n', cmd))

    if is_recursive:
        code = f"""requires grep;
async fn main() -> i64 {{
  matches: string = await grep.search_recursive("{pattern}", "{path}");
  println(matches);
  return 0;
}}"""
        results.append((desc, code))
        results.append((f"Recursively search for '{pattern}' in {path}", code))
        # Variation: count
        results.append((f"Count occurrences of '{pattern}' in files", f"""requires grep;
async fn main() -> i64 {{
  matches: string = await grep.search_recursive("{pattern}", "{path}");
  println(matches);
  return 0;
}}"""))
    elif is_count:
        code = f"""requires grep;
async fn main() -> i64 {{
  count: int = grep.count("{pattern}", "{path}");
  println(f"Matches: {{count}}");
  return 0;
}}"""
        results.append((desc, code))
    elif is_invert:
        code = f"""requires grep;
async fn main() -> i64 {{
  lines: string = grep.invert_match("{pattern}", "{path}");
  println(lines);
  return 0;
}}"""
        results.append((desc, code))
        results.append((f"Show lines not matching '{pattern}'", code))
    elif is_files_only:
        code = f"""requires grep;
async fn main() -> i64 {{
  files: string = grep.files_matching("{pattern}", "{path}");
  println(files);
  return 0;
}}"""
        results.append((desc, code))
        results.append((f"Find files containing '{pattern}'", code))
    elif is_numbered:
        code = f"""requires grep;
async fn main() -> i64 {{
  lines: string = grep.search_numbered("{pattern}", "{path}");
  println(lines);
  return 0;
}}"""
        results.append((desc, code))
    else:
        code = f"""requires grep;
async fn main() -> i64 {{
  matches: string = grep.search("{pattern}", "{path}");
  println(matches);
  return 0;
}}"""
        results.append((desc, code))
        results.append((f"Search for '{pattern}' in {path}", code))
        # Variation: numbered
        results.append((f"Search for '{pattern}' with line numbers", f"""requires grep;
async fn main() -> i64 {{
  matches: string = grep.search_numbered("{pattern}", "{path}");
  println(matches);
  return 0;
}}"""))

    return results


def translate_find(cmd: str, desc: str):
    """Translate find commands to Mog."""
    results = []

    dir_match = re.search(r'find\s+(\S+)', cmd)
    search_dir = dir_match.group(1) if dir_match else "."

    name_match = re.search(r'-name\s+["\']([^"\']+)["\']', cmd)
    type_match = re.search(r'-type\s+(\w)', cmd)

    if name_match and type_match:
        pattern = name_match.group(1)
        entry_type = type_match.group(1)
        code = f"""requires find;
async fn main() -> i64 {{
  files: string = await find.by_name_and_type("{pattern}", "{entry_type}", "{search_dir}");
  println(files);
  return 0;
}}"""
        results.append((desc, code))
        results.append((f"Find {entry_type} entries named '{pattern}' in {search_dir}", code))
        # Count variation
        results.append((f"Count files matching '{pattern}'", f"""requires find;
async fn main() -> i64 {{
  n: int = await find.count("{pattern}", "{search_dir}");
  println(f"Found {{n}} matches");
  return 0;
}}"""))
    elif name_match:
        pattern = name_match.group(1)
        code = f"""requires find;
async fn main() -> i64 {{
  files: string = await find.by_name("{pattern}", "{search_dir}");
  println(files);
  return 0;
}}"""
        results.append((desc, code))
        results.append((f"Find files named '{pattern}' in {search_dir}", code))
        results.append((f"Count files named '{pattern}'", f"""requires find;
async fn main() -> i64 {{
  n: int = await find.count("{pattern}", "{search_dir}");
  println(f"Found {{n}} matching files");
  return 0;
}}"""))
    elif type_match:
        entry_type = type_match.group(1)
        code = f"""requires find;
async fn main() -> i64 {{
  entries: string = await find.by_type("{entry_type}", "{search_dir}");
  println(entries);
  return 0;
}}"""
        results.append((desc, code))
        type_name = {"f": "files", "d": "directories", "l": "symlinks"}.get(entry_type, "entries")
        results.append((f"Find all {type_name} in {search_dir}", code))
    else:
        # Generic find - list files
        code = f"""requires find;
async fn main() -> i64 {{
  files: string = await find.by_name("*", "{search_dir}");
  println(files);
  return 0;
}}"""
        results.append((desc, code))

    return results


def translate_curl(cmd: str, desc: str):
    """Translate curl commands to Mog."""
    results = []

    url_match = re.search(r'curl\s+(?:.*?\s+)?(?:-[a-zA-Z]+\s+)*["\']?(https?://[^\s"\']+)', cmd)
    if not url_match:
        url_match = re.search(r'(https?://[^\s"\']+)', cmd)
    if not url_match:
        return results

    url = url_match.group(1).rstrip("'\"")
    is_post = bool(re.search(r'-X\s+POST\b', cmd))
    is_put = bool(re.search(r'-X\s+PUT\b', cmd))
    is_delete = bool(re.search(r'-X\s+DELETE\b', cmd))
    has_data = re.search(r"-d\s+['\"]([^'\"]+)['\"]", cmd)
    has_header = re.search(r"-H\s+['\"]([^'\"]+)['\"]", cmd)

    if is_post and has_data:
        data = has_data.group(1).replace('"', '\\"')
        code = f"""requires curl;
async fn main() -> i64 {{
  response: string = await curl.post("{url}", "{data}");
  println(response);
  return 0;
}}"""
        results.append((desc, code))
        results.append((f"POST data to {url}", code))
        # GET variation
        results.append((f"GET request to {url}", f"""requires curl;
async fn main() -> i64 {{
  response: string = await curl.get("{url}");
  println(response);
  return 0;
}}"""))
    elif is_put and has_data:
        data = has_data.group(1).replace('"', '\\"')
        code = f"""requires curl;
async fn main() -> i64 {{
  response: string = await curl.put("{url}", "{data}");
  println(response);
  return 0;
}}"""
        results.append((desc, code))
    elif is_delete:
        code = f"""requires curl;
async fn main() -> i64 {{
  response: string = await curl.delete("{url}");
  println(response);
  return 0;
}}"""
        results.append((desc, code))
    elif has_header:
        header = has_header.group(1).replace('"', '\\"')
        code = f"""requires curl;
async fn main() -> i64 {{
  response: string = await curl.get_with_header("{url}", "{header}");
  println(response);
  return 0;
}}"""
        results.append((desc, code))
        results.append((f"GET with custom header from {url}", code))
    else:
        code = f"""requires curl;
async fn main() -> i64 {{
  response: string = await curl.get("{url}");
  println(response);
  return 0;
}}"""
        results.append((desc, code))
        results.append((f"Fetch content from {url}", code))
        results.append((f"Download response from API endpoint", f"""requires curl;
async fn main() -> i64 {{
  body: string = await curl.get("{url}");
  println(body);
  return 0;
}}"""))

    return results


def translate_docker(cmd: str, desc: str):
    """Translate docker commands to Mog."""
    results = []

    if re.search(r'docker\s+ps\b', cmd):
        args_match = re.search(r'docker\s+ps\s+(.*?)(?:\s*\||$)', cmd)
        args = args_match.group(1).strip() if args_match else ""
        code = f"""requires docker;
async fn main() -> i64 {{
  containers: string = docker.ps("{args}");
  println(containers);
  return 0;
}}"""
        results.append((desc, code))
        results.append(("List running Docker containers", """requires docker;
async fn main() -> i64 {
  containers: string = docker.ps("");
  println(containers);
  return 0;
}"""))
        results.append(("List all Docker containers including stopped", """requires docker;
async fn main() -> i64 {
  containers: string = docker.ps("-a");
  println(containers);
  return 0;
}"""))

    elif re.search(r'docker\s+images\b', cmd):
        code = """requires docker;
async fn main() -> i64 {
  images: string = docker.images("");
  println(images);
  return 0;
}"""
        results.append((desc, code))
        results.append(("List Docker images", code))

    elif re.search(r'docker\s+logs\b', cmd):
        container_match = re.search(r'docker\s+logs\s+(\S+)', cmd)
        container = container_match.group(1) if container_match else "mycontainer"
        code = f"""requires docker;
async fn main() -> i64 {{
  logs: string = docker.logs("{container}");
  println(logs);
  return 0;
}}"""
        results.append((desc, code))
        results.append((f"View logs for container {container}", code))

    elif re.search(r'docker\s+stop\b', cmd):
        container_match = re.search(r'docker\s+stop\s+(\S+)', cmd)
        container = container_match.group(1) if container_match else "mycontainer"
        code = f"""requires docker;
async fn main() -> i64 {{
  result: int = docker.stop("{container}");
  println(f"Stop result: {{result}}");
  return 0;
}}"""
        results.append((desc, code))
        results.append((f"Stop Docker container {container}", code))

    elif re.search(r'docker\s+exec\b', cmd):
        exec_match = re.search(r'docker\s+exec\s+(?:-\w+\s+)*(\S+)\s+(.*?)$', cmd)
        if exec_match:
            container = exec_match.group(1)
            exec_cmd = exec_match.group(2).replace('"', '\\"')
            code = f"""requires docker;
async fn main() -> i64 {{
  output: string = docker.exec("{container}", "{exec_cmd}");
  println(output);
  return 0;
}}"""
            results.append((desc, code))

    elif re.search(r'docker\s+build\b', cmd):
        tag_match = re.search(r'-t\s+(\S+)', cmd)
        tag = tag_match.group(1) if tag_match else "myimage:latest"
        code = f"""requires docker;
async fn main() -> i64 {{
  result: string = await docker.build(".", "{tag}");
  println(result);
  return 0;
}}"""
        results.append((desc, code))
        results.append((f"Build Docker image tagged {tag}", code))

    elif re.search(r'docker\s+run\b', cmd):
        image_match = re.search(r'docker\s+run\s+(?:.*?\s+)?(\S+)$', cmd)
        image = image_match.group(1) if image_match else "ubuntu:latest"
        code = f"""requires docker;
async fn main() -> i64 {{
  output: string = docker.run("{image}", "");
  println(output);
  return 0;
}}"""
        results.append((desc, code))

    return results


def translate_gh(cmd: str, desc: str):
    """Translate gh CLI commands to Mog."""
    results = []

    if re.search(r'gh\s+pr\s+list\b', cmd):
        code = """requires gh;
async fn main() -> i64 {
  prs: string = await gh.pr_list("open");
  println(prs);
  return 0;
}"""
        results.append((desc, code))
        results.append(("List open pull requests", code))
        results.append(("List closed pull requests", """requires gh;
async fn main() -> i64 {
  prs: string = await gh.pr_list("closed");
  println(prs);
  return 0;
}"""))

    elif re.search(r'gh\s+pr\s+view\b', cmd):
        num_match = re.search(r'gh\s+pr\s+view\s+(\d+)', cmd)
        num = int(num_match.group(1)) if num_match else 1
        code = f"""requires gh;
async fn main() -> i64 {{
  pr: string = await gh.pr_view({num});
  println(pr);
  return 0;
}}"""
        results.append((desc, code))
        results.append((f"View pull request #{num}", code))

    elif re.search(r'gh\s+pr\s+create\b', cmd):
        code = """requires gh;
async fn main() -> i64 {
  result: string = await gh.pr_create("Feature update", "Description of changes");
  println(result);
  return 0;
}"""
        results.append((desc, code))
        results.append(("Create a new pull request", code))

    elif re.search(r'gh\s+issue\s+list\b', cmd):
        code = """requires gh;
async fn main() -> i64 {
  issues: string = await gh.issue_list("open");
  println(issues);
  return 0;
}"""
        results.append((desc, code))
        results.append(("List open GitHub issues", code))

    elif re.search(r'gh\s+issue\s+create\b', cmd):
        code = """requires gh;
async fn main() -> i64 {
  result: string = await gh.issue_create("Bug report", "Description of the bug");
  println(result);
  return 0;
}"""
        results.append((desc, code))

    elif re.search(r'gh\s+run\s+list\b', cmd):
        code = """requires gh;
async fn main() -> i64 {
  runs: string = await gh.run_list("ci.yml");
  println(runs);
  return 0;
}"""
        results.append((desc, code))
        results.append(("List CI workflow runs", code))

    elif re.search(r'gh\s+run\s+view\b', cmd):
        id_match = re.search(r'gh\s+run\s+view\s+(\d+)', cmd)
        run_id = int(id_match.group(1)) if id_match else 1
        code = f"""requires gh;
async fn main() -> i64 {{
  run: string = await gh.run_view({run_id});
  println(run);
  return 0;
}}"""
        results.append((desc, code))

    return results


def translate_python3(cmd: str, desc: str):
    """Translate python3 commands to Mog."""
    results = []

    # python3 -c "..."
    code_match = re.search(r'python3?\s+-c\s+["\'](.+?)["\']', cmd)
    if code_match:
        py_code = code_match.group(1).replace('"', '\\"')
        if len(py_code) < 200:
            code = f"""requires python3;
async fn main() -> i64 {{
  output: string = python3.exec("{py_code}");
  println(output);
  return 0;
}}"""
            results.append((desc, code))
            results.append(("Execute inline Python code", code))
        return results

    # python3 script.py
    script_match = re.search(r'python3?\s+(\S+\.py)', cmd)
    if script_match:
        script = script_match.group(1)
        args_match = re.search(r'python3?\s+\S+\.py\s+(.*?)(?:\s*\||$)', cmd)
        if args_match and args_match.group(1).strip():
            args = args_match.group(1).strip().replace('"', '\\"')
            code = f"""requires python3;
async fn main() -> i64 {{
  output: string = await python3.run_script_args("{script}", "{args}");
  println(output);
  return 0;
}}"""
        else:
            code = f"""requires python3;
async fn main() -> i64 {{
  output: string = await python3.run_script("{script}");
  println(output);
  return 0;
}}"""
        results.append((desc, code))
        results.append((f"Run Python script {script}", code))

    # python3 -m module
    mod_match = re.search(r'python3?\s+-m\s+(\S+)', cmd)
    if mod_match:
        module = mod_match.group(1)
        args_match = re.search(r'python3?\s+-m\s+\S+\s+(.*?)(?:\s*\||$)', cmd)
        args = args_match.group(1).strip().replace('"', '\\"') if args_match else ""
        code = f"""requires python3;
async fn main() -> i64 {{
  output: string = await python3.run_module("{module}", "{args}");
  println(output);
  return 0;
}}"""
        results.append((desc, code))

    return results


def translate_mkdir(cmd: str, desc: str):
    """Translate mkdir to fs operations."""
    results = []
    dir_match = re.search(r'mkdir\s+(?:-p\s+)?(\S+)', cmd)
    if dir_match:
        path = dir_match.group(1)
        # fs doesn't have mkdir, but we can use write_file as a proxy
        # Actually skip mkdir since fs doesn't support it directly
        return results
    return results


def translate_jq_pipe(cmd: str, desc: str):
    """Translate commands piped through jq."""
    results = []
    jq_match = re.search(r'\|\s*jq\s+["\']([^"\']+)["\']', cmd)
    if not jq_match:
        return results
    expr = jq_match.group(1).replace('"', '\\"')

    # If it's curl | jq
    curl_match = re.search(r'curl\s+.*?(https?://[^\s"\'|]+)', cmd)
    if curl_match:
        url = curl_match.group(1).rstrip("'\"")
        code = f"""requires curl;
requires jq;
async fn main() -> i64 {{
  response: string = await curl.get("{url}");
  result: string = jq.query("{expr}", response);
  println(result);
  return 0;
}}"""
        results.append((desc, code))
        results.append((f"Fetch JSON from API and extract with jq", code))
        results.append((f"Query JSON response with jq expression", f"""requires curl;
requires jq;
async fn main() -> i64 {{
  response: string = await curl.get("{url}");
  keys: string = jq.keys(response);
  println(keys);
  return 0;
}}"""))

    return results


def translate_sed(cmd: str, desc: str):
    """Translate sed commands."""
    results = []
    # sed 's/pattern/replacement/g' file
    sub_match = re.search(r"sed\s+(?:-[a-zA-Z]+\s+)*['\"]s/([^/]+)/([^/]*)/([a-z]*)['\"]?\s+(\S+)", cmd)
    if sub_match:
        pattern = sub_match.group(1).replace('"', '\\"')
        replacement = sub_match.group(2).replace('"', '\\"')
        flags = sub_match.group(3)
        path = sub_match.group(4)
        if 'g' in flags:
            code = f"""requires sed;
async fn main() -> i64 {{
  result: string = sed.substitute_all_in_file("{pattern}", "{replacement}", "{path}");
  println(result);
  return 0;
}}"""
        else:
            code = f"""requires sed;
async fn main() -> i64 {{
  result: string = sed.substitute_in_file("{pattern}", "{replacement}", "{path}");
  println(result);
  return 0;
}}"""
        results.append((desc, code))
        results.append((f"Replace '{pattern}' with '{replacement}' in {path}", code))
    return results


def translate_fs_operations(cmd: str, desc: str):
    """Translate file operations like cat, test -f, ls, etc."""
    results = []

    # cat file
    cat_match = re.search(r'cat\s+(\S+)', cmd)
    if cat_match:
        path = cat_match.group(1)
        code = f"""requires fs;
async fn main() -> i64 {{
  contents: string = fs.read_file("{path}");
  println(contents);
  return 0;
}}"""
        results.append((desc, code))
        results.append((f"Read and display contents of {path}", code))
        return results

    # test -f / test -d
    test_match = re.search(r'test\s+-[fd]\s+(\S+)', cmd)
    if test_match:
        path = test_match.group(1)
        code = f"""requires fs;
async fn main() -> i64 {{
  exists_val: bool = fs.exists("{path}");
  if exists_val {{
    println("{path} exists");
  }} else {{
    println("{path} does not exist");
  }}
  return 0;
}}"""
        results.append((desc, code))
        results.append((f"Check if {path} exists", code))
        return results

    # chmod (skip - not in fs capability)
    # wc -l (can approximate with read + count)

    return results


def translate_cargo(cmd: str, desc: str):
    """Translate cargo commands."""
    results = []

    path = "."
    path_match = re.search(r'--manifest-path\s+(\S+)', cmd)
    if path_match:
        path = os.path.dirname(path_match.group(1)) or "."

    if re.search(r'cargo\s+test\b', cmd):
        code = f"""requires cargo;
async fn main() -> i64 {{
  result: int = await cargo.test("{path}");
  println(f"Test exit code: {{result}}");
  return 0;
}}"""
        results.append((desc, code))
        results.append(("Run Rust tests with cargo", code))
        results.append(("Build and test Rust project", f"""requires cargo;
async fn main() -> i64 {{
  build_result: int = await cargo.build("{path}");
  println(f"Build: {{build_result}}");
  test_result: int = await cargo.test("{path}");
  println(f"Test: {{test_result}}");
  return 0;
}}"""))

    elif re.search(r'cargo\s+build\b', cmd):
        code = f"""requires cargo;
async fn main() -> i64 {{
  result: int = await cargo.build("{path}");
  println(f"Build exit code: {{result}}");
  return 0;
}}"""
        results.append((desc, code))
        results.append(("Build Rust project with cargo", code))

    elif re.search(r'cargo\s+check\b', cmd):
        code = f"""requires cargo;
async fn main() -> i64 {{
  result: int = await cargo.check("{path}");
  println(f"Check exit code: {{result}}");
  return 0;
}}"""
        results.append((desc, code))
        results.append(("Type-check Rust project", code))

    elif re.search(r'cargo\s+clippy\b', cmd):
        code = f"""requires cargo;
async fn main() -> i64 {{
  output: string = await cargo.clippy("{path}");
  println(output);
  return 0;
}}"""
        results.append((desc, code))
        results.append(("Run Clippy lints on Rust project", code))

    elif re.search(r'cargo\s+fmt\b', cmd):
        code = f"""requires cargo;
async fn main() -> i64 {{
  result: int = await cargo.fmt("{path}");
  println(f"Format exit code: {{result}}");
  return 0;
}}"""
        results.append((desc, code))
        results.append(("Format Rust code with cargo fmt", code))

    elif re.search(r'cargo\s+run\b', cmd):
        args_match = re.search(r'cargo\s+run\s+(?:--\s+)?(.*?)$', cmd)
        args = args_match.group(1).strip().replace('"', '\\"') if args_match else ""
        code = f"""requires cargo;
async fn main() -> i64 {{
  output: string = await cargo.run("{path}", "{args}");
  println(output);
  return 0;
}}"""
        results.append((desc, code))

    return results


def translate_sleep(cmd: str, desc: str):
    """Translate sleep commands."""
    results = []
    sleep_match = re.search(r'sleep\s+(\d+)', cmd)
    if sleep_match:
        seconds = int(sleep_match.group(1))
        ms = seconds * 1000
        code = f"""requires process;
async fn main() -> i64 {{
  await process.sleep({ms});
  println("Done waiting {seconds} seconds");
  return 0;
}}"""
        results.append((f"Wait {seconds} seconds", code))
        results.append((f"Sleep for {seconds} seconds before continuing", code))

        # If there's a command after sleep
        after_match = re.search(r'sleep\s+\d+\s*(?:&&|;)\s*(.*)', cmd)
        if after_match:
            after_cmd = after_match.group(1).strip()
            # Check if it's a translatable command
            after_results = classify_and_translate(after_cmd, f"After waiting, {desc}")
            if after_results:
                results.extend(after_results)

    return results


def translate_process_env(cmd: str, desc: str):
    """Translate env/export/echo $VAR commands."""
    results = []

    # export VAR=val or echo $VAR
    env_match = re.search(r'\$(\w+)', cmd)
    if env_match:
        var = env_match.group(1)
        code = f"""requires process;
async fn main() -> i64 {{
  val: string = process.getenv("{var}");
  println(f"{var} = {{val}}");
  return 0;
}}"""
        results.append((f"Get environment variable {var}", code))

    return results


def translate_which(cmd: str, desc: str):
    """Translate which/command -v to process capability."""
    results = []
    which_match = re.search(r'which\s+(\S+)', cmd)
    if which_match:
        tool = which_match.group(1)
        code = f"""requires process;
async fn main() -> i64 {{
  cwd_val: string = process.cwd();
  println(f"Working directory: {{cwd_val}}");
  return 0;
}}"""
        results.append((f"Check environment for {tool}", code))
    return results


# Untranslatable command categories
SKIP_PREFIXES = [
    'ssh', 'ansible', 'tmux', 'uv ', 'bun ', 'pb ', 'exophial',
    'strace', 'htop', 'top', 'systemctl', 'journalctl',
    'laconic', 'npm', 'yarn', 'pip ', 'apt', 'brew',
    'ansible-', 'kubectl', 'helm', 'terraform',
    'rsync', 'scp', 'sftp', 'nc ', 'ncat',
    'tcpdump', 'nmap', 'dig', 'nslookup',
    'crontab', 'at ', 'screen',
    'gcloud', 'aws ', 'az ',
    '.venv/', 'source ', '. ',
    'PYTHONPATH=', 'SSH_AUTH',
    'timeout ', 'watch ',
]


def is_translatable(cmd: str) -> bool:
    """Check if a command can be translated to Mog."""
    cmd_stripped = cmd.strip()
    for prefix in SKIP_PREFIXES:
        if cmd_stripped.startswith(prefix):
            return False
    # Also skip commands that start with comments and have untranslatable content
    if cmd_stripped.startswith('#'):
        return False
    return True


def classify_and_translate(cmd: str, desc: str):
    """Classify a command and translate it."""
    cmd_stripped = cmd.strip()

    # Check for jq pipe first (compound command)
    if '| jq' in cmd:
        results = translate_jq_pipe(cmd, desc)
        if results:
            return results

    # Primary tool detection
    if cmd_stripped.startswith('git ') or (cmd_stripped.startswith('for ') and 'git ' in cmd):
        return translate_git(cmd, desc)
    elif cmd_stripped.startswith('grep ') or ('| grep' in cmd and not cmd_stripped.startswith('ssh')):
        return translate_grep(cmd, desc)
    elif cmd_stripped.startswith('find '):
        return translate_find(cmd, desc)
    elif cmd_stripped.startswith('curl '):
        return translate_curl(cmd, desc)
    elif cmd_stripped.startswith('docker '):
        return translate_docker(cmd, desc)
    elif cmd_stripped.startswith('gh '):
        return translate_gh(cmd, desc)
    elif cmd_stripped.startswith('python3 ') or cmd_stripped.startswith('python '):
        return translate_python3(cmd, desc)
    elif cmd_stripped.startswith('cargo '):
        return translate_cargo(cmd, desc)
    elif cmd_stripped.startswith('sleep '):
        return translate_sleep(cmd, desc)
    elif cmd_stripped.startswith('cat ') or cmd_stripped.startswith('test '):
        return translate_fs_operations(cmd, desc)
    elif cmd_stripped.startswith('which '):
        return translate_which(cmd, desc)
    elif cmd_stripped.startswith('export ') or ('echo' in cmd and '$' in cmd):
        return translate_process_env(cmd, desc)
    elif cmd_stripped.startswith('sed '):
        return translate_sed(cmd, desc)
    elif cmd_stripped.startswith('mkdir'):
        return translate_mkdir(cmd, desc)

    # Check for embedded translatable commands in pipes/compounds (no recursion)
    for sep in ['&&', '||', ';']:
        parts = cmd.split(sep)
        for part in parts:
            part = part.strip()
            first_word = part.split()[0] if part.split() else ''
            if first_word in ('git', 'grep', 'find', 'curl', 'docker', 'gh',
                              'python3', 'python', 'cargo', 'cat', 'sed'):
                if first_word in ('git',):
                    return translate_git(part, desc)
                elif first_word in ('grep',):
                    return translate_grep(part, desc)
                elif first_word in ('find',):
                    return translate_find(part, desc)
                elif first_word in ('curl',):
                    return translate_curl(part, desc)
                elif first_word in ('docker',):
                    return translate_docker(part, desc)
                elif first_word in ('gh',):
                    return translate_gh(part, desc)
                elif first_word in ('python3', 'python'):
                    return translate_python3(part, desc)
                elif first_word in ('cargo',):
                    return translate_cargo(part, desc)
                elif first_word in ('sed',):
                    return translate_sed(part, desc)
                elif first_word in ('cat',):
                    return translate_fs_operations(part, desc)

    return []


def generate_standalone_examples():
    """Generate standalone Mog examples that don't come from specific commands."""
    examples = []

    # Git workflows
    examples.append(("Stage changes and commit", """requires git;
async fn main() -> i64 {
  result: int = git.add(".");
  commit_msg: string = git.commit("Update code");
  println(commit_msg);
  return 0;
}"""))

    examples.append(("Check status, stage, and commit changes", """requires git;
async fn main() -> i64 {
  status: string = git.status();
  println(status);
  result: int = git.add(".");
  msg: string = git.commit("Apply changes");
  println(msg);
  return 0;
}"""))

    examples.append(("Pull latest, check status, push if clean", """requires git;
async fn main() -> i64 {
  pull_result: string = await git.pull("origin", "main");
  println(pull_result);
  status: string = git.status();
  println(status);
  push_result: string = await git.push("origin", "main");
  println(push_result);
  return 0;
}"""))

    examples.append(("Create feature branch workflow", """requires git;
async fn main() -> i64 {
  result: int = git.checkout("main");
  pull_result: string = await git.pull("origin", "main");
  branches: string = git.branch();
  println(branches);
  return 0;
}"""))

    examples.append(("Stash changes, pull, and pop stash", """requires git;
async fn main() -> i64 {
  stash_result: string = git.stash("push");
  println(stash_result);
  pull_result: string = await git.pull("origin", "main");
  println(pull_result);
  pop_result: string = git.stash("pop");
  println(pop_result);
  return 0;
}"""))

    # File operations
    examples.append(("Write and read a configuration file", """requires fs;
async fn main() -> i64 {
  fs.write_file("/tmp/config.txt", "key=value");
  contents: string = fs.read_file("/tmp/config.txt");
  println(contents);
  return 0;
}"""))

    examples.append(("Check if file exists and read it", """requires fs;
async fn main() -> i64 {
  exists_val: bool = fs.exists("/tmp/data.txt");
  if exists_val {
    contents: string = fs.read_file("/tmp/data.txt");
    println(contents);
  } else {
    println("File does not exist");
  }
  return 0;
}"""))

    examples.append(("Append to a log file", """requires fs;
async fn main() -> i64 {
  fs.append_file("/tmp/app.log", "New log entry\\n");
  contents: string = fs.read_file("/tmp/app.log");
  println(contents);
  return 0;
}"""))

    examples.append(("Get file size in bytes", """requires fs;
async fn main() -> i64 {
  sz: int = fs.file_size("/tmp/data.txt");
  println(f"File size: {sz} bytes");
  return 0;
}"""))

    examples.append(("Write file, verify, then clean up", """requires fs;
async fn main() -> i64 {
  fs.write_file("/tmp/test.txt", "test data");
  exists_val: bool = fs.exists("/tmp/test.txt");
  if exists_val {
    println("File created successfully");
  }
  fs.remove("/tmp/test.txt");
  println("Cleaned up");
  return 0;
}"""))

    # Grep patterns
    examples.append(("Search for TODO comments in source files", """requires grep;
async fn main() -> i64 {
  matches: string = await grep.search_recursive("TODO", "src/");
  println(matches);
  return 0;
}"""))

    examples.append(("Count error occurrences in log file", """requires grep;
async fn main() -> i64 {
  count: int = grep.count("ERROR", "/var/log/app.log");
  println(f"Error count: {count}");
  return 0;
}"""))

    examples.append(("Find files containing a function definition", """requires grep;
async fn main() -> i64 {
  files: string = grep.files_matching("fn main", "src/");
  println(files);
  return 0;
}"""))

    examples.append(("Search with line numbers", """requires grep;
async fn main() -> i64 {
  lines: string = grep.search_numbered("import", "main.py");
  println(lines);
  return 0;
}"""))

    examples.append(("Find lines not matching a pattern", """requires grep;
async fn main() -> i64 {
  lines: string = grep.invert_match("debug", "config.txt");
  println(lines);
  return 0;
}"""))

    # Find patterns
    examples.append(("Find all Python files in project", """requires find;
async fn main() -> i64 {
  files: string = await find.by_name("*.py", ".");
  println(files);
  return 0;
}"""))

    examples.append(("Find directories in current path", """requires find;
async fn main() -> i64 {
  dirs: string = await find.by_type("d", ".");
  println(dirs);
  return 0;
}"""))

    examples.append(("Find recently modified files", """requires find;
async fn main() -> i64 {
  files: string = await find.modified_within(3600, ".");
  println(files);
  return 0;
}"""))

    examples.append(("Find large files over 1MB", """requires find;
async fn main() -> i64 {
  files: string = await find.by_min_size(1048576, ".");
  println(files);
  return 0;
}"""))

    examples.append(("Count Rust source files", """requires find;
async fn main() -> i64 {
  n: int = await find.count("*.rs", "src/");
  println(f"Found {n} Rust files");
  return 0;
}"""))

    examples.append(("Find old files not modified in 30 days", """requires find;
async fn main() -> i64 {
  files: string = await find.modified_before(2592000, ".");
  println(files);
  return 0;
}"""))

    examples.append(("Find small files under 1KB", """requires find;
async fn main() -> i64 {
  files: string = await find.by_max_size(1024, ".");
  println(files);
  return 0;
}"""))

    # Curl / HTTP
    examples.append(("Fetch JSON from a REST API", """requires curl;
async fn main() -> i64 {
  response: string = await curl.get("https://api.example.com/data");
  println(response);
  return 0;
}"""))

    examples.append(("POST JSON data to API endpoint", """requires curl;
async fn main() -> i64 {
  body: string = await curl.post("https://api.example.com/items", "{\\\"name\\\": \\\"test\\\"}");
  println(body);
  return 0;
}"""))

    examples.append(("Download a file from URL", """requires curl;
async fn main() -> i64 {
  bytes: int = await curl.download("https://example.com/file.tar.gz", "/tmp/file.tar.gz");
  println(f"Downloaded {bytes} bytes");
  return 0;
}"""))

    examples.append(("Make authenticated API request", """requires curl;
async fn main() -> i64 {
  response: string = await curl.get_with_header("https://api.example.com/me", "Authorization: Bearer token123");
  println(response);
  return 0;
}"""))

    # jq
    examples.append(("Parse JSON and extract a field", """requires jq;
requires fs;
async fn main() -> i64 {
  json_str: string = fs.read_file("data.json");
  result: string = jq.query(".name", json_str);
  println(result);
  return 0;
}"""))

    examples.append(("Filter JSON array by condition", """requires jq;
async fn main() -> i64 {
  json_str: string = "[{\\\"age\\\": 25}, {\\\"age\\\": 30}, {\\\"age\\\": 15}]";
  result: string = jq.filter("select(.age > 20)", json_str);
  println(result);
  return 0;
}"""))

    examples.append(("Extract keys from JSON object", """requires jq;
requires fs;
async fn main() -> i64 {
  json_str: string = fs.read_file("config.json");
  keys: string = jq.keys(json_str);
  println(keys);
  return 0;
}"""))

    # Docker
    examples.append(("List running containers and their images", """requires docker;
async fn main() -> i64 {
  containers: string = docker.ps("");
  println(containers);
  images: string = docker.images("");
  println(images);
  return 0;
}"""))

    examples.append(("Stop and remove a container", """requires docker;
async fn main() -> i64 {
  stop_result: int = docker.stop("myapp");
  println(f"Stop: {stop_result}");
  rm_result: int = docker.rm("myapp");
  println(f"Remove: {rm_result}");
  return 0;
}"""))

    examples.append(("Build and run a Docker image", """requires docker;
async fn main() -> i64 {
  build_output: string = await docker.build(".", "myapp:latest");
  println(build_output);
  run_output: string = docker.run("myapp:latest", "-d");
  println(run_output);
  return 0;
}"""))

    # Cargo workflows
    examples.append(("Full Rust CI check: fmt, clippy, test", """requires cargo;
async fn main() -> i64 {
  fmt_result: int = await cargo.fmt(".");
  println(f"Format: {fmt_result}");
  clippy_output: string = await cargo.clippy(".");
  println(clippy_output);
  test_result: int = await cargo.test(".");
  println(f"Tests: {test_result}");
  return 0;
}"""))

    examples.append(("Check Rust project compiles", """requires cargo;
async fn main() -> i64 {
  result: int = await cargo.check(".");
  if result == 0 {
    println("Project compiles successfully");
  } else {
    println("Compilation errors found");
  }
  return 0;
}"""))

    # Process
    examples.append(("Get current working directory", """requires process;
async fn main() -> i64 {
  cwd_val: string = process.cwd();
  println(f"CWD: {cwd_val}");
  return 0;
}"""))

    examples.append(("Read environment variable HOME", """requires process;
async fn main() -> i64 {
  home: string = process.getenv("HOME");
  println(f"Home directory: {home}");
  return 0;
}"""))

    examples.append(("Measure elapsed time of an operation", """requires process;
requires fs;
async fn main() -> i64 {
  start: int = process.timestamp();
  contents: string = fs.read_file("/etc/hostname");
  end: int = process.timestamp();
  elapsed: int = end - start;
  println(f"Read took {elapsed}ms");
  return 0;
}"""))

    examples.append(("Wait then check status", """requires process;
requires git;
async fn main() -> i64 {
  await process.sleep(2000);
  status: string = git.status();
  println(status);
  return 0;
}"""))

    # sed
    examples.append(("Replace text pattern in string", """requires sed;
async fn main() -> i64 {
  text: string = "Hello World";
  result: string = sed.substitute("World", "Mog", text);
  println(result);
  return 0;
}"""))

    examples.append(("Replace all occurrences in file", """requires sed;
async fn main() -> i64 {
  result: string = sed.substitute_all_in_file("old_value", "new_value", "config.txt");
  println(result);
  return 0;
}"""))

    examples.append(("Delete lines matching pattern", """requires sed;
async fn main() -> i64 {
  text: string = "line1\\nDEBUG: info\\nline3";
  result: string = sed.delete_matching("DEBUG", text);
  println(result);
  return 0;
}"""))

    # awk
    examples.append(("Extract second field from CSV data", """requires awk;
async fn main() -> i64 {
  data: string = "name,age,city\\nAlice,30,NYC\\nBob,25,LA";
  result: string = awk.field(2, ",", data);
  println(result);
  return 0;
}"""))

    examples.append(("Sum numeric field in delimited data", """requires awk;
async fn main() -> i64 {
  data: string = "item,10\\nitem,20\\nitem,30";
  total: float = awk.sum_field(2, ",", data);
  print_f64(total);
  println("");
  return 0;
}"""))

    examples.append(("Get unique values from a column", """requires awk;
async fn main() -> i64 {
  data: string = "red,1\\nblue,2\\nred,3\\ngreen,4";
  unique: string = awk.unique_field(1, ",", data);
  println(unique);
  return 0;
}"""))

    examples.append(("Count lines matching a pattern", """requires awk;
async fn main() -> i64 {
  data: string = "error: failed\\ninfo: ok\\nerror: timeout\\ninfo: done";
  count: int = awk.count_matching("error", data);
  println(f"Error lines: {count}");
  return 0;
}"""))

    # yq
    examples.append(("Convert YAML to JSON", """requires yq;
async fn main() -> i64 {
  yaml: string = "name: test\\nversion: 1.0";
  json: string = yq.to_json(yaml);
  println(json);
  return 0;
}"""))

    examples.append(("Extract value from YAML", """requires yq;
async fn main() -> i64 {
  yaml: string = "database:\\n  host: localhost\\n  port: 5432";
  host: string = yq.get(yaml, ".database.host");
  println(f"Host: {host}");
  return 0;
}"""))

    examples.append(("Update YAML value", """requires yq;
async fn main() -> i64 {
  yaml: string = "name: old\\nversion: 1.0";
  updated: string = yq.set(yaml, ".name", "new");
  println(updated);
  return 0;
}"""))

    # GitHub workflows
    examples.append(("Create PR and list open PRs", """requires gh;
async fn main() -> i64 {
  result: string = await gh.pr_create("Add feature X", "Implements feature X with tests");
  println(result);
  prs: string = await gh.pr_list("open");
  println(prs);
  return 0;
}"""))

    examples.append(("File a GitHub issue", """requires gh;
async fn main() -> i64 {
  result: string = await gh.issue_create("Bug: login fails", "Steps to reproduce: ...");
  println(result);
  return 0;
}"""))

    examples.append(("Check CI run status", """requires gh;
async fn main() -> i64 {
  runs: string = await gh.run_list("ci.yml");
  println(runs);
  return 0;
}"""))

    # Multi-capability workflows
    examples.append(("Search for pattern and count matches across project", """requires grep;
requires find;
async fn main() -> i64 {
  files: string = await find.by_name("*.py", "src/");
  println("Python files:");
  println(files);
  matches: string = await grep.search_recursive("import", "src/");
  println("Import statements:");
  println(matches);
  return 0;
}"""))

    examples.append(("Read config, parse JSON, extract value", """requires fs;
requires jq;
async fn main() -> i64 {
  config: string = fs.read_file("package.json");
  name: string = jq.query(".name", config);
  version: string = jq.query(".version", config);
  println(f"Package: {name} v{version}");
  return 0;
}"""))

    examples.append(("Fetch API data and save to file", """requires curl;
requires fs;
async fn main() -> i64 {
  data: string = await curl.get("https://api.example.com/config");
  fs.write_file("/tmp/api_response.json", data);
  println("Saved API response");
  return 0;
}"""))

    examples.append(("Build Rust project and check git status", """requires cargo;
requires git;
async fn main() -> i64 {
  build_result: int = await cargo.build(".");
  println(f"Build: {build_result}");
  status: string = git.status();
  println(status);
  return 0;
}"""))

    examples.append(("Run tests and commit if passing", """requires cargo;
requires git;
async fn main() -> i64 {
  test_result: int = await cargo.test(".");
  if test_result == 0 {
    result: int = git.add(".");
    msg: string = git.commit("Tests pass, committing changes");
    println(msg);
  } else {
    println("Tests failed, not committing");
  }
  return 0;
}"""))

    examples.append(("Timed file operation with logging", """requires fs;
requires process;
requires log;
async fn main() -> i64 {
  log.info("Starting file operation");
  start: int = process.timestamp();
  fs.write_file("/tmp/output.txt", "Generated data");
  end: int = process.timestamp();
  elapsed: int = end - start;
  log.info(f"File written in {elapsed}ms");
  return 0;
}"""))

    examples.append(("Search codebase for security patterns", """requires grep;
async fn main() -> i64 {
  sql_injection: string = await grep.search_recursive("execute.*%s", "src/");
  println("Potential SQL injection:");
  println(sql_injection);
  hardcoded: string = await grep.search_recursive("password.*=.*\"", "src/");
  println("Hardcoded passwords:");
  println(hardcoded);
  return 0;
}"""))

    examples.append(("Find and clean up temporary files", """requires find;
requires fs;
async fn main() -> i64 {
  tmp_files: string = await find.by_name("*.tmp", "/tmp");
  println("Temporary files:");
  println(tmp_files);
  return 0;
}"""))

    examples.append(("Docker container health check", """requires docker;
requires log;
async fn main() -> i64 {
  containers: string = docker.ps("");
  log.info("Running containers:");
  log.info(containers);
  return 0;
}"""))

    examples.append(("Environment diagnostic script", """requires process;
requires fs;
async fn main() -> i64 {
  cwd_val: string = process.cwd();
  println(f"Working directory: {cwd_val}");
  home: string = process.getenv("HOME");
  println(f"HOME: {home}");
  path: string = process.getenv("PATH");
  println(f"PATH: {path}");
  ts: int = process.timestamp();
  println(f"Timestamp: {ts}");
  return 0;
}"""))

    examples.append(("Python version and package check", """requires python3;
async fn main() -> i64 {
  ver: string = python3.version();
  println(f"Python version: {ver}");
  packages: string = python3.pip_list();
  println(packages);
  return 0;
}"""))

    examples.append(("Evaluate Python expression", """requires python3;
async fn main() -> i64 {
  result: string = python3.eval("2 ** 10");
  println(f"2^10 = {result}");
  return 0;
}"""))

    examples.append(("Install Python package and verify", """requires python3;
async fn main() -> i64 {
  install_result: string = await python3.pip_install("requests");
  println(install_result);
  packages: string = python3.pip_list();
  println(packages);
  return 0;
}"""))

    examples.append(("Run linting with logging", """requires cargo;
requires log;
async fn main() -> i64 {
  log.info("Starting lint check");
  output: string = await cargo.clippy(".");
  log.info(output);
  log.info("Lint check complete");
  return 0;
}"""))

    examples.append(("Git log with search for commits", """requires git;
async fn main() -> i64 {
  log_output: string = git.log("--oneline --all --grep=fix -20");
  println("Commits containing 'fix':");
  println(log_output);
  return 0;
}"""))

    examples.append(("Check repository state before deploy", """requires git;
requires cargo;
async fn main() -> i64 {
  status: string = git.status();
  println(status);
  diff: string = git.diff();
  if diff.len > 0 {
    println("Uncommitted changes detected, aborting");
    return 1;
  }
  test_result: int = await cargo.test(".");
  println(f"Tests: {test_result}");
  return 0;
}"""))

    examples.append(("Fetch, transform, and save JSON data", """requires curl;
requires jq;
requires fs;
async fn main() -> i64 {
  raw: string = await curl.get("https://api.example.com/users");
  names: string = jq.query(".[].name", raw);
  fs.write_file("/tmp/names.txt", names);
  println("Names saved to /tmp/names.txt");
  return 0;
}"""))

    examples.append(("Search and replace across project files", """requires sed;
requires grep;
async fn main() -> i64 {
  files: string = grep.files_matching("old_api", "src/");
  println("Files to update:");
  println(files);
  return 0;
}"""))

    examples.append(("Mathematical computation", """requires math;
async fn main() -> i64 {
  sum: int = math.add(42, 58);
  println(f"42 + 58 = {sum}");
  product: int = math.multiply(7, 8);
  println(f"7 * 8 = {product}");
  abs_val: int = math.abs(-15);
  println(f"abs(-15) = {abs_val}");
  max_val: int = math.max(100, 200);
  println(f"max(100, 200) = {max_val}");
  return 0;
}"""))

    examples.append(("Timer-based operation", """requires timer;
async fn main() -> i64 {
  result: int = await timer.setTimeout(100);
  println(f"Timer fired: {result}");
  return 0;
}"""))

    examples.append(("Logging at different levels", """requires log;
async fn main() -> i64 {
  log.debug("Debug information");
  log.info("Application started");
  log.warn("Low disk space");
  log.error("Connection failed");
  return 0;
}"""))

    examples.append(("Read YAML config and convert to JSON", """requires fs;
requires yq;
async fn main() -> i64 {
  yaml: string = fs.read_file("config.yaml");
  json: string = yq.to_json(yaml);
  fs.write_file("config.json", json);
  println("Converted YAML to JSON");
  return 0;
}"""))

    examples.append(("Delete key from YAML configuration", """requires yq;
async fn main() -> i64 {
  yaml: string = "database:\\n  host: localhost\\n  debug: true";
  result: string = yq.delete_key(yaml, ".database.debug");
  println(result);
  return 0;
}"""))

    examples.append(("Extract multiple fields from delimited data", """requires awk;
async fn main() -> i64 {
  data: string = "Alice:30:NYC\\nBob:25:LA\\nCarol:35:SF";
  result: string = awk.fields("1,3", ":", data);
  println(result);
  return 0;
}"""))

    examples.append(("Count fields in data line", """requires awk;
async fn main() -> i64 {
  data: string = "a,b,c,d,e";
  count: int = awk.field_count(",", data);
  println(f"Fields: {count}");
  return 0;
}"""))

    examples.append(("Insert comment before matching lines", """requires sed;
async fn main() -> i64 {
  text: string = "line1\\nIMPORTANT: do this\\nline3";
  result: string = sed.insert_before("IMPORTANT", "# NOTE:", text);
  println(result);
  return 0;
}"""))

    examples.append(("Extract text between markers", """requires sed;
async fn main() -> i64 {
  text: string = "header\\nBEGIN\\ndata1\\ndata2\\nEND\\nfooter";
  result: string = sed.extract_range("BEGIN", "END", text);
  println(result);
  return 0;
}"""))

    examples.append(("HTTP GET and POST workflow", """requires http;
async fn main() -> i64 {
  data: string = await http.get("https://api.example.com/status");
  println(data);
  result: string = await http.post("https://api.example.com/log", "{\\\"status\\\": \\\"ok\\\"}");
  println(result);
  return 0;
}"""))

    examples.append(("Clone repository and run tests", """requires gh;
requires cargo;
async fn main() -> i64 {
  clone_result: int = await gh.repo_clone("user/repo", "/tmp/repo");
  println(f"Clone: {clone_result}");
  test_result: int = await cargo.test("/tmp/repo");
  println(f"Tests: {test_result}");
  return 0;
}"""))

    examples.append(("View PR and check CI status", """requires gh;
async fn main() -> i64 {
  pr: string = await gh.pr_view(42);
  println(pr);
  runs: string = await gh.run_list("ci.yml");
  println(runs);
  return 0;
}"""))

    examples.append(("Find symlinks in directory", """requires find;
async fn main() -> i64 {
  links: string = await find.by_type("l", "/usr/local/bin");
  println(links);
  return 0;
}"""))

    examples.append(("Find TypeScript files by name and type", """requires find;
async fn main() -> i64 {
  files: string = await find.by_name_and_type("*.ts", "f", "src/");
  println(files);
  return 0;
}"""))

    examples.append(("Grep for fixed string match", """requires grep;
async fn main() -> i64 {
  matches: string = grep.search_fixed("[ERROR]", "/var/log/app.log");
  println(matches);
  return 0;
}"""))

    examples.append(("Run Python one-liner to calculate", """requires python3;
async fn main() -> i64 {
  result: string = python3.eval("sum(range(1, 101))");
  println(f"Sum 1-100: {result}");
  return 0;
}"""))

    examples.append(("Execute Python code block", """requires python3;
async fn main() -> i64 {
  output: string = python3.exec("for i in range(5): print(f'Line {i}')");
  println(output);
  return 0;
}"""))

    examples.append(("Run Python module", """requires python3;
async fn main() -> i64 {
  output: string = await python3.run_module("json.tool", "data.json");
  println(output);
  return 0;
}"""))

    examples.append(("Format and lint Rust project", """requires cargo;
async fn main() -> i64 {
  fmt_result: int = await cargo.fmt(".");
  println(f"Format: {fmt_result}");
  lint: string = await cargo.clippy(".");
  println(lint);
  return 0;
}"""))

    examples.append(("Build Rust in release mode", """requires cargo;
async fn main() -> i64 {
  result: int = await cargo.build(".");
  println(f"Build result: {result}");
  return 0;
}"""))

    examples.append(("Docker exec into container", """requires docker;
async fn main() -> i64 {
  output: string = docker.exec("webapp", "cat /etc/os-release");
  println(output);
  return 0;
}"""))

    examples.append(("Remove stopped containers", """requires docker;
async fn main() -> i64 {
  stopped: string = docker.ps("-a --filter status=exited");
  println("Stopped containers:");
  println(stopped);
  return 0;
}"""))

    examples.append(("Math operations with min and max", """requires math;
async fn main() -> i64 {
  min_val: int = math.min(5, 3);
  max_val: int = math.max(5, 3);
  diff: int = math.subtract(max_val, min_val);
  println(f"Min: {min_val}, Max: {max_val}, Diff: {diff}");
  return 0;
}"""))

    examples.append(("Division and absolute value", """requires math;
async fn main() -> i64 {
  result: int = math.divide(100, 7);
  println(f"100 / 7 = {result}");
  neg: int = math.subtract(0, 42);
  pos: int = math.abs(neg);
  println(f"abs(-42) = {pos}");
  return 0;
}"""))

    examples.append(("Substitute pattern in text", """requires sed;
async fn main() -> i64 {
  text: string = "The quick brown fox jumps over the lazy dog";
  result: string = sed.substitute("fox", "cat", text);
  println(result);
  return 0;
}"""))

    examples.append(("Replace all occurrences in text", """requires sed;
async fn main() -> i64 {
  text: string = "foo bar foo baz foo";
  result: string = sed.substitute_all("foo", "qux", text);
  println(result);
  return 0;
}"""))

    examples.append(("Insert line after matching pattern", """requires sed;
async fn main() -> i64 {
  text: string = "[section]\\nkey=value\\n[other]";
  result: string = sed.insert_after("\\[section\\]", "new_key=new_value", text);
  println(result);
  return 0;
}"""))

    examples.append(("Filter lines with awk", """requires awk;
async fn main() -> i64 {
  data: string = "error: something\\ninfo: ok\\nerror: timeout";
  errors: string = awk.filter("error", data);
  println(errors);
  return 0;
}"""))

    examples.append(("Format fields from delimited data", """requires awk;
async fn main() -> i64 {
  data: string = "Alice,30\\nBob,25\\nCarol,35";
  formatted: string = awk.format_fields("Name: %s, Age: %s", ",", data);
  println(formatted);
  return 0;
}"""))

    examples.append(("Transform JSON array", """requires jq;
async fn main() -> i64 {
  json_str: string = "[{\\\"name\\\": \\\"a\\\", \\\"val\\\": 1}, {\\\"name\\\": \\\"b\\\", \\\"val\\\": 2}]";
  result: string = jq.transform(".[].name", json_str);
  println(result);
  return 0;
}"""))

    examples.append(("Get JSON object values", """requires jq;
async fn main() -> i64 {
  json_str: string = "{\\\"x\\\": 1, \\\"y\\\": 2, \\\"z\\\": 3}";
  vals: string = jq.values(json_str);
  println(vals);
  return 0;
}"""))

    examples.append(("Set value in YAML document", """requires yq;
async fn main() -> i64 {
  yaml: string = "app:\\n  port: 8080";
  updated: string = yq.set(yaml, ".app.port", "9090");
  println(updated);
  return 0;
}"""))

    examples.append(("Convert JSON config to YAML", """requires yq;
async fn main() -> i64 {
  json: string = "{\\\"name\\\": \\\"app\\\", \\\"port\\\": 3000}";
  yaml: string = yq.from_json(json);
  println(yaml);
  return 0;
}"""))

    examples.append(("Full project analysis workflow", """requires find;
requires grep;
requires git;
async fn main() -> i64 {
  status: string = git.status();
  println("Git status:");
  println(status);
  rs_files: int = await find.count("*.rs", "src/");
  println(f"Rust files: {rs_files}");
  todos: string = await grep.search_recursive("TODO", "src/");
  println("TODOs:");
  println(todos);
  return 0;
}"""))

    examples.append(("API health check with retry delay", """requires curl;
requires process;
requires log;
async fn main() -> i64 {
  log.info("Checking API health...");
  response: string = await curl.get("https://api.example.com/health");
  println(response);
  await process.sleep(5000);
  response2: string = await curl.get("https://api.example.com/health");
  println(response2);
  return 0;
}"""))

    examples.append(("Backup file before modification", """requires fs;
requires sed;
async fn main() -> i64 {
  original: string = fs.read_file("config.txt");
  fs.write_file("config.txt.bak", original);
  modified: string = sed.substitute_all_in_file("debug=true", "debug=false", "config.txt");
  println("Config updated, backup saved");
  return 0;
}"""))

    examples.append(("Recursive search with context", """requires grep;
requires log;
async fn main() -> i64 {
  log.info("Searching for deprecated API usage...");
  matches: string = await grep.search_recursive("deprecated", "src/");
  if matches.len > 0 {
    log.warn("Found deprecated API usage:");
    println(matches);
  } else {
    log.info("No deprecated API usage found");
  }
  return 0;
}"""))

    examples.append(("YAML query for nested values", """requires yq;
async fn main() -> i64 {
  yaml: string = "services:\\n  web:\\n    port: 8080\\n  db:\\n    port: 5432";
  result: string = yq.query(yaml, ".services.web.port");
  println(f"Web port: {result}");
  return 0;
}"""))

    return examples


def main():
    # Read input commands
    commands = []
    with open(INPUT) as f:
        for line in f:
            obj = json.loads(line)
            commands.append((obj['command'], obj['description']))

    print(f"Loaded {len(commands)} commands")

    # Translate commands
    translations = []
    skipped = 0
    translated_count = 0

    for cmd, desc in commands:
        if not is_translatable(cmd):
            skipped += 1
            continue

        results = classify_and_translate(cmd, desc)
        for d, code in results:
            translations.append((d, code))
            translated_count += 1

    print(f"Translated {translated_count} from batch commands (skipped {skipped})")

    # Add standalone examples
    standalone = generate_standalone_examples()
    for d, code in standalone:
        translations.append((d, code))
    print(f"Added {len(standalone)} standalone examples")
    print(f"Total before validation: {len(translations)}")

    # Validate all translations
    valid = []
    invalid = 0
    for desc, code in translations:
        if validate_mog(code):
            valid.append(entry(desc, code))
        else:
            invalid += 1
            # Debug: print first few failures
            if invalid <= 3:
                print(f"  INVALID: {desc[:50]}")
                # Show error
                path = os.path.join(VALIDATE_DIR, "check.mog")
                with open(path, "w") as f:
                    f.write(code)
                result = subprocess.run(
                    [MOGC, path, "--emit-ir"],
                    capture_output=True, text=True, timeout=5
                )
                err_lines = [l for l in (result.stdout + result.stderr).split('\n') if 'error' in l.lower()]
                for el in err_lines[:3]:
                    print(f"    {el}")

    print(f"Valid: {len(valid)}, Invalid: {invalid}")

    # Write output
    with open(OUTPUT, 'w') as f:
        for item in valid:
            f.write(json.dumps(item) + '\n')

    print(f"Wrote {len(valid)} translations to {OUTPUT}")


if __name__ == '__main__':
    main()
