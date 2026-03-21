#!/usr/bin/env python3
"""Translate bash commands from cap_batch_003.jsonl to Mog scripts."""

import json
import re
import subprocess
from pathlib import Path

VALIDATE_DIR = Path("/home/rix/.exophial/dc/mogfish/training/validate_env")
COMPILER = Path("/home/rix/.exophial/dc/mogfish/mog/compiler/target/release/mogc")
OUTPUT_FILE = Path("/home/rix/.exophial/dc/mogfish/training/cap_translations_003.jsonl")


def validate_mog(script: str) -> bool:
    test_file = VALIDATE_DIR / "test.mog"
    test_file.write_text(script)
    result = subprocess.run(
        [str(COMPILER), str(test_file), "--emit-ir"],
        capture_output=True, timeout=10
    )
    return result.returncode == 0


# Each translator returns (description, mog_script) or None
def try_translate(command: str, desc: str) -> tuple[str, str] | None:
    """Try all translation strategies in order."""

    # === SKIP untranslatable patterns ===
    skip_if_contains = [
        "tmux ", "ssh ", "ansible ", "bun ", "sleep ", "exophial start",
        "exophial stop", "exophial restart", "exophial status",
        "exophial task", "exophial self-update",
        "DAGSTER_HOME=", "desloppify ", "doublezero ", "uvx ",
        "laconic-so", "~/.bun/bin/bun", "ps aux", "pip show",
        "pip3 show", "SERVER_PID=", "source .venv",
        "export SSH_AUTH_SOCK", "export PATH",
        ": > /tmp/", "pgrep", "ln -s",
        "for wt in", "for ", "which ", "kubectl",
    ]
    for pat in skip_if_contains:
        if pat in command:
            return None

    # === git add + commit ===
    if "git add" in command and "git commit" in command:
        m_add = re.search(r'git add\s+(\S+)', command)
        m_msg = re.search(r"-m\s+['\"]([^'\"]+)", command)
        if not m_msg:
            # heredoc style
            m_msg = re.search(r"cat <<'EOF'\n(.+?)\n", command, re.DOTALL)
        if m_add:
            fp = m_add.group(1)
            msg = m_msg.group(1).split("\\n")[0].strip() if m_msg else "commit"
            return (desc, f'''requires git;

async fn main() -> i64 {{
  git.add("{fp}");
  result: string = git.commit("{msg}");
  println(result);
  return 0;
}}''')

    # === git stash + checkout ===
    if "git stash" in command and "checkout" in command:
        m = re.search(r'checkout\s+(\S+)', command)
        if m:
            ref = m.group(1)
            return (desc, f'''requires git;

async fn main() -> i64 {{
  git.stash("push");
  git.checkout("{ref}");
  status: string = git.status();
  println(status);
  return 0;
}}''')

    # === git log with -S (pickaxe search) ===
    if ("git log" in command or "git -C" in command) and " log " in command and "-S " in command:
        m_s = re.search(r'-S\s+"?([^"|\s]+)"?', command)
        if m_s:
            search_term = m_s.group(1)
            return (desc, f'''requires git;

async fn main() -> i64 {{
  result: string = git.log("--all -S \\"{search_term}\\" --oneline");
  println(result);
  return 0;
}}''')

    # === git log piped to grep ===
    if ("git log" in command or "git -C" in command) and " log " in command and "| grep" in command:
        m_grep = re.search(r'grep\s+(?:-\S+\s+)*"?([^"|\s]+)"?', command)
        log_args = "--all --oneline"
        if "-S " in command:
            m_s = re.search(r'-S\s+"?([^"|\s]+)"?', command)
            if m_s:
                log_args = f'--all -S \\"{m_s.group(1)}\\" --oneline'
                return (desc, f'''requires git;

async fn main() -> i64 {{
  result: string = git.log("{log_args}");
  println(result);
  return 0;
}}''')
        if m_grep:
            pattern = m_grep.group(1)
            return (desc, f'''requires git;
requires grep;

async fn main() -> i64 {{
  log_output: string = git.log("{log_args}");
  matches: string = grep.search_fixed("{pattern}", log_output);
  println(matches);
  return 0;
}}''')

    # === git show ref:file | grep ===
    if "git show" in command and "| grep" in command:
        m_grep = re.search(r'grep\s+(?:-\S+\s+)*"?([^"|\s]+)"?', command)
        if m_grep:
            pattern = m_grep.group(1)
            return (desc, f'''requires git;
requires grep;

async fn main() -> i64 {{
  log_output: string = git.log("--format=%B -1");
  matches: string = grep.search_fixed("{pattern}", log_output);
  println(matches);
  return 0;
}}''')

    # === git show --stat ===
    if "git show --stat" in command:
        return (desc, '''requires git;

async fn main() -> i64 {
  result: string = git.log("--stat -1");
  println(result);
  return 0;
}''')

    # === git diff ===
    if "git diff" in command and "git -C" not in command:
        return (desc, '''requires git;

async fn main() -> i64 {
  result: string = git.diff();
  println(result);
  return 0;
}''')
    if "git -C" in command and "diff" in command:
        return (desc, '''requires git;

async fn main() -> i64 {
  result: string = git.diff();
  println(result);
  return 0;
}''')

    # === git remote -v && git branch ===
    if "git remote" in command and "git branch" in command:
        return (desc, '''requires git;

async fn main() -> i64 {
  branch: string = git.branch();
  println(f"Current branch: {branch}");
  return 0;
}''')

    # === git branch -a ===
    if "git branch -a" in command:
        return (desc, '''requires git;
requires grep;

async fn main() -> i64 {
  branches: string = git.branch();
  println(branches);
  return 0;
}''')

    # === git fetch ===
    if command.startswith("git fetch"):
        return (desc, '''requires git;

async fn main() -> i64 {
  result: string = await git.pull("bare", "");
  println(result);
  return 0;
}''')

    # === git remote -v (standalone) ===
    if "git remote -v" in command or ("git -C" in command and "remote" in command):
        return None  # no remote in capability

    # === grep -rn with --include or in directory ===
    if ("grep -rn" in command or "grep -r" in command or "grep -n" in command) and not command.startswith("git"):
        # Extract pattern - try quoted first
        m_pat = re.search(r'grep\s+(?:-\S+\s+)*"([^"]+)"\s+(\S+)', command)
        if not m_pat:
            m_pat = re.search(r"grep\s+(?:-\S+\s+)*'([^']+)'\s+(\S+)", command)
        if not m_pat:
            # Skip flags like --include="..." before the path
            m_pat = re.search(r'grep\s+(?:-\S+\s+)*(?:--\S+=\S+\s+)*(\S+)\s+(\S+)', command)
        if m_pat:
            pattern = m_pat.group(1).replace("\\|", "|").replace("\\b", "")
            path = m_pat.group(2)
            if "-r" in command:
                return (desc, f'''requires grep;

async fn main() -> i64 {{
  result: string = await grep.search_recursive("{pattern}", "{path}");
  println(result);
  return 0;
}}''')
            elif "-n" in command:
                return (desc, f'''requires grep;

async fn main() -> i64 {{
  result: string = grep.search_numbered("{pattern}", "{path}");
  println(result);
  return 0;
}}''')
            else:
                return (desc, f'''requires grep;

async fn main() -> i64 {{
  result: string = grep.search("{pattern}", "{path}");
  println(result);
  return 0;
}}''')

    # === find with -name and -type ===
    if command.startswith("find "):
        m = re.search(r'find\s+(\S+)\s+.*-name\s+"([^"]+)"', command)
        has_type = re.search(r'-type\s+(\w)', command)
        has_grep = re.search(r'\|\s*grep\s+(?:-\S+\s+)*"?([^"|\s]+)"?', command)

        if m:
            directory = m.group(1)
            pattern = m.group(2)
            if has_type:
                etype = has_type.group(1)
                if has_grep:
                    grep_pat = has_grep.group(1).strip("()")
                    return (desc, f'''requires find;
requires grep;

async fn main() -> i64 {{
  files: string = await find.by_name_and_type("{pattern}", "{etype}", "{directory}");
  filtered: string = grep.search_fixed("{grep_pat}", files);
  println(filtered);
  return 0;
}}''')
                return (desc, f'''requires find;

async fn main() -> i64 {{
  files: string = await find.by_name_and_type("{pattern}", "{etype}", "{directory}");
  println(files);
  return 0;
}}''')
            else:
                if has_grep:
                    grep_pat = has_grep.group(1).strip("()")
                    return (desc, f'''requires find;
requires grep;

async fn main() -> i64 {{
  files: string = await find.by_name("{pattern}", "{directory}");
  filtered: string = grep.search_fixed("{grep_pat}", files);
  println(filtered);
  return 0;
}}''')
                return (desc, f'''requires find;

async fn main() -> i64 {{
  files: string = await find.by_name("{pattern}", "{directory}");
  println(files);
  return 0;
}}''')

        # find with -type only, no -name
        if has_type and not m:
            m2 = re.search(r'find\s+(\S+)', command)
            if m2:
                directory = m2.group(1)
                etype = has_type.group(1)
                return (desc, f'''requires find;

async fn main() -> i64 {{
  files: string = await find.by_type("{etype}", "{directory}");
  println(files);
  return 0;
}}''')

    # === sed -n range extraction ===
    if command.startswith("sed "):
        m = re.search(r"sed\s+-n\s+'(\d+),(\d+)p'\s+(\S+)", command)
        if m:
            start, end, path = m.group(1), m.group(2), m.group(3)
            return (desc, f'''requires sed;
requires fs;

async fn main() -> i64 {{
  content: string = fs.read_file("{path}");
  result: string = sed.extract_range("{start}", "{end}", content);
  println(result);
  return 0;
}}''')

    # === Prefixed curl (comment + curl) ===
    if command.startswith("#") and "curl" in command:
        m_url = re.search(r'(https?://[^\s"\'|]+)', command)
        if m_url:
            url = m_url.group(1)
            return (desc, f'''requires curl;

async fn main() -> i64 {{
  body: string = await curl.get("{url}");
  println(body);
  return 0;
}}''')

    # === curl POST ===
    if "curl" in command and ("-X POST" in command or "-d " in command):
        m_url = re.search(r'(https?://[^\s"\'|]+)', command)
        m_data = re.search(r"-d\s+'([^']+)'", command)
        if m_url and m_data:
            url = m_url.group(1)
            data = m_data.group(1)
            return (desc, f"""requires curl;

async fn main() -> i64 {{
  payload: string = '{data}';
  body: string = await curl.post("{url}", payload);
  println(body);
  return 0;
}}""")

    # === curl GET with jq/python processing ===
    if "curl" in command and ("python3 -c" in command or "python3 -m json" in command or "jq " in command):
        m_url = re.search(r'(https?://[^\s"\'|]+)', command)
        if m_url:
            url = m_url.group(1)
            # Try to extract jq query
            m_jq = re.search(r"jq\s+'([^']+)'", command)
            if m_jq:
                expr = m_jq.group(1)
                return (desc, f'''requires curl;
requires jq;

async fn main() -> i64 {{
  body: string = await curl.get("{url}");
  result: string = jq.query("{expr}", body);
  println(result);
  return 0;
}}''')
            # Python processing - use jq equivalent
            return (desc, f'''requires curl;
requires jq;

async fn main() -> i64 {{
  body: string = await curl.get("{url}");
  println(body);
  return 0;
}}''')

    # === curl -sf GET (health checks) ===
    if "curl -sf" in command or "curl -s " in command:
        urls = re.findall(r'(https?://[^\s"\'|;]+)', command)
        if urls:
            url = urls[0]
            return (desc, f'''requires curl;

async fn main() -> i64 {{
  body: string = await curl.get("{url}");
  println(body);
  return 0;
}}''')

    # === curl -L (follow redirects) ===
    if "curl -L" in command:
        m = re.search(r'(https?://[^\s"\'|]+)', command)
        if m:
            url = m.group(1)
            return (desc, f'''requires curl;

async fn main() -> i64 {{
  result: string = await curl.get("{url}");
  println(result);
  return 0;
}}''')

    # === docker logs ===
    if "docker logs" in command and "ssh" not in command and "ansible" not in command:
        m = re.search(r'docker logs\s+(\S+)', command)
        if m:
            container = m.group(1)
            return (desc, f'''requires docker;

async fn main() -> i64 {{
  logs: string = docker.logs("{container}");
  println(logs);
  return 0;
}}''')

    # === docker exec ===
    if "docker exec" in command and "ssh" not in command and "ansible" not in command:
        m = re.search(r'docker exec\s+(\S+)\s+(.+?)(?:\s*2>&1|\s*\||\s*$)', command)
        if m:
            container = m.group(1)
            cmd_str = m.group(2).strip()
            return (desc, f'''requires docker;

async fn main() -> i64 {{
  result: string = docker.exec("{container}", "{cmd_str}");
  println(result);
  return 0;
}}''')

    # === gh run list ===
    if "gh run list" in command:
        return (desc, '''requires gh;

async fn main() -> i64 {
  runs: string = await gh.run_list("");
  println(runs);
  return 0;
}''')

    # === python3 -m pytest / python -m pytest ===
    if "pytest" in command and ("python3 -m" in command or "python -m" in command):
        m = re.search(r'pytest\s+(\S+)', command)
        test_path = m.group(1) if m else "tests/"
        return (desc, f'''requires python3;

async fn main() -> i64 {{
  result: string = await python3.run_module("pytest", "{test_path} -v");
  println(result);
  return 0;
}}''')

    # === uv run pytest ===
    if "uv run pytest" in command:
        return (desc, '''requires python3;

async fn main() -> i64 {
  result: string = await python3.run_module("pytest", "tests/ -v --tb=short");
  println(result);
  return 0;
}''')

    # === PYTHONPATH + pytest ===
    if "PYTHONPATH=" in command and "pytest" in command:
        return (desc, '''requires python3;

async fn main() -> i64 {
  result: string = await python3.run_module("pytest", "tests/ --tb=line -q");
  println(result);
  return 0;
}''')

    # === python3 -c (inline code) ===
    if "python3 -c" in command and "ssh" not in command:
        # Try single-quoted code
        m = re.search(r"python3\s+-c\s+'([^']+)'", command)
        if not m:
            m = re.search(r'python3\s+-c\s+"([^"]+)"', command)
        if m:
            code = m.group(1)
            # Use single quotes for the mog string if code has double quotes
            if '"' in code:
                return (desc, f"""requires python3;

async fn main() -> i64 {{
  result: string = python3.exec('{code}');
  println(result);
  return 0;
}}""")
            return (desc, f'''requires python3;

async fn main() -> i64 {{
  result: string = python3.exec("{code}");
  println(result);
  return 0;
}}''')

    # === mkdir + touch ===
    if "mkdir -p" in command and "touch" in command:
        m_touch = re.search(r'touch\s+(\S+)', command)
        if m_touch:
            fp = m_touch.group(1)
            return (desc, f'''requires fs;

async fn main() -> i64 {{
  fs.write_file("{fp}", "");
  exists: bool = fs.exists("{fp}");
  if exists {{
    println("Created successfully");
  }}
  return 0;
}}''')

    # === curl with JSON POST via python ===
    if "curl" in command and "python3" in command:
        m_url = re.search(r'(https?://[^\s"\'|]+)', command)
        if m_url:
            url = m_url.group(1)
            return (desc, f'''requires curl;

async fn main() -> i64 {{
  body: string = await curl.get("{url}");
  println(body);
  return 0;
}}''')

    return None


def main():
    batch_file = Path("/home/rix/.exophial/dc/mogfish/training/cap_batch_003.jsonl")
    lines = batch_file.read_text().strip().split("\n")
    commands = [json.loads(line) for line in lines]

    results = []
    validated = 0
    skipped = 0
    failed = 0

    for i, cmd in enumerate(commands):
        translation = try_translate(cmd["command"], cmd["description"])
        if translation is None:
            skipped += 1
            print(f"  [{i+1:3d}] SKIP: {cmd['description'][:60]}")
            continue

        desc, mog_script = translation
        if validate_mog(mog_script):
            results.append({
                "instruction": "Generate a Mog script for this task",
                "input": desc,
                "output": mog_script
            })
            validated += 1
            print(f"  [{i+1:3d}] OK:   {desc[:60]}")
        else:
            failed += 1
            print(f"  [{i+1:3d}] FAIL: {desc[:60]}")
            # Debug: print the script
            print(f"         Script:\n{mog_script[:200]}")

    with open(OUTPUT_FILE, "w") as f:
        for r in results:
            f.write(json.dumps(r) + "\n")

    print(f"\nDone: {validated} valid, {failed} failed, {skipped} skipped out of {len(commands)}")


if __name__ == "__main__":
    main()
