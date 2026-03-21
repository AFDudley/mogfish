#!/usr/bin/env python3
"""Extract classification training data from Claude Code session transcripts.

Parses JSONL session files and extracts (user_input, classification) pairs
based on what the assistant did after each user message.

Categories:
- KnownCommand: Assistant executed a known CLI tool via Bash
- GenerateNew: Assistant used Write/Edit to generate code
- Passthrough: Assistant responded with text only (no tool_use)
"""

import json
import os
import random
import subprocess
import sys
from pathlib import Path
from typing import Optional


KNOWN_COMMANDS = {
    "git", "grep", "rg", "find", "ls", "cat", "head", "tail", "sed", "awk",
    "docker", "docker-compose", "cargo", "rustc", "python", "python3", "pip",
    "pip3", "uv", "npm", "npx", "node", "yarn", "pnpm", "curl", "wget",
    "ssh", "scp", "rsync", "make", "cmake", "gcc", "g++", "clang", "go",
    "ruby", "gem", "bundle", "java", "javac", "mvn", "gradle", "kubectl",
    "helm", "terraform", "ansible", "ansible-playbook", "ansible-lint",
    "systemctl", "journalctl", "ps", "kill", "top", "htop", "df", "du",
    "mount", "umount", "chmod", "chown", "chgrp", "tar", "zip", "unzip",
    "gzip", "gunzip", "wc", "sort", "uniq", "diff", "patch", "xargs",
    "cd", "pwd", "mkdir", "rmdir", "rm", "cp", "mv", "touch", "ln",
    "echo", "printf", "test", "true", "false", "env", "export", "source",
    "gh", "jq", "yq", "sqlite3", "psql", "mysql", "redis-cli",
    "pre-commit", "mypy", "ruff", "black", "isort", "flake8", "pylint",
    "pytest", "tox", "nox", "poetry", "pipenv", "conda",
    "exophial", "dagster", "dbt",
}

CODE_GEN_TOOLS = {"Write", "Edit", "NotebookEdit"}

# Tools that count as "known commands" even without Bash
READ_TOOLS = {"Read", "Glob", "Grep"}


def extract_command_name(bash_input: str) -> Optional[str]:
    """Extract the first command from a bash command string."""
    cmd = bash_input.strip()
    # Strip leading env vars like FOO=bar cmd
    while "=" in cmd.split()[0] if cmd.split() else False:
        parts = cmd.split(None, 1)
        if len(parts) < 2:
            break
        cmd = parts[1]

    first_word = cmd.split()[0] if cmd.split() else ""
    # Strip path prefix
    first_word = first_word.split("/")[-1]
    return first_word if first_word in KNOWN_COMMANDS else None


def classify_assistant_response(content_blocks: list) -> tuple[str, Optional[str]]:
    """Classify an assistant response based on tool_use blocks.

    Looks at ALL tool uses in the turn. Priority:
    1. If any Write/Edit tool is used → GenerateNew
    2. If any Bash with known command → KnownCommand
    3. If any Bash at all → KnownCommand
    4. If only text → Passthrough

    Returns (category, command_name).
    """
    tool_uses = [b for b in content_blocks if b.get("type") == "tool_use"]

    if not tool_uses:
        return ("Passthrough", None)

    # Check for code generation anywhere in the turn
    for tool in tool_uses:
        if tool.get("name", "") in CODE_GEN_TOOLS:
            return ("GenerateNew", None)

    # Check for bash commands
    for tool in tool_uses:
        if tool.get("name", "") == "Bash":
            cmd = tool.get("input", {}).get("command", "")
            cmd_name = extract_command_name(cmd)
            if cmd_name:
                return ("KnownCommand", cmd_name)

    # Any bash at all
    for tool in tool_uses:
        if tool.get("name", "") == "Bash":
            cmd = tool.get("input", {}).get("command", "")
            first_word = cmd.strip().split()[0].split("/")[-1] if cmd.strip() else ""
            if first_word:
                return ("KnownCommand", first_word)

    # Read/Glob/Grep without subsequent Write = research = Passthrough
    tool_names = {t.get("name", "") for t in tool_uses}
    if tool_names <= (READ_TOOLS | {"Agent", "Skill"}):
        return ("Passthrough", None)

    return ("Passthrough", None)


def process_session_file(filepath: str) -> list[dict]:
    """Process a single JSONL session file and extract training pairs."""
    results = []
    events = []

    try:
        with open(filepath, "r") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    events.append(json.loads(line))
                except json.JSONDecodeError:
                    continue
    except (OSError, IOError):
        return []

    # Find user→assistant pairs
    for i, ev in enumerate(events):
        if ev.get("type") != "user":
            continue

        msg = ev.get("message", {})
        if msg.get("role") != "user":
            continue

        content = msg.get("content", "")

        # Extract text from content
        if isinstance(content, list):
            text_parts = []
            for block in content:
                if isinstance(block, dict):
                    if block.get("type") == "text":
                        text_parts.append(block.get("text", ""))
                    elif block.get("type") == "tool_result":
                        # Skip tool_result messages
                        text_parts = []
                        break
                elif isinstance(block, str):
                    text_parts.append(block)
            text = " ".join(text_parts).strip()
        elif isinstance(content, str):
            text = content.strip()
        else:
            continue

        if not text:
            continue

        # Apply filters
        word_count = len(text.split())
        if word_count < 3:
            continue
        if len(text) > 500:
            continue

        # Skip system/automated messages and messages with potential secrets
        if text.startswith("Execute pipeline") or text.startswith("IMPORTANT:"):
            continue
        if "<task-notification>" in text or "<task-id>" in text:
            continue
        if "<system-reminder>" in text or "<tool-use-id>" in text:
            continue
        # Skip messages containing potential secrets/tokens
        import re
        if re.search(r'(?i)(secret\s*access\s*key|access\s*key\s*id)', text):
            continue
        if re.search(r'[A-Za-z0-9+/=]{40,}', text):
            continue
        if re.search(r'(?i)(password|token|secret)\s*[:=]\s*\S{8,}', text):
            continue

        # Collect ALL assistant content blocks until next user message
        all_assistant_blocks = []
        for j in range(i + 1, min(i + 30, len(events))):
            next_ev = events[j]
            if next_ev.get("type") == "user":
                break  # Next user turn — stop
            if next_ev.get("type") != "assistant":
                continue
            next_msg = next_ev.get("message", {})
            if next_msg.get("role") != "assistant":
                continue
            next_content = next_msg.get("content", [])
            if isinstance(next_content, list):
                all_assistant_blocks.extend(next_content)

        if not all_assistant_blocks:
            continue

        category, command = classify_assistant_response(all_assistant_blocks)

        output = {"category": category, "confidence": 1.0, "command": command}
        results.append({
            "instruction": "Classify this user input",
            "input": text,
            "output": json.dumps(output),
        })

    return results


def collect_files_local(base_dir: str) -> list[str]:
    """Collect all JSONL session files from local directory."""
    files = []
    base = Path(base_dir)
    if not base.exists():
        return []

    for f in base.rglob("*.jsonl"):
        # Skip subagent files and test files
        fstr = str(f)
        if "/subagents/" in fstr or "pytest" in fstr:
            continue
        if f.stat().st_size < 5000:
            continue
        files.append(fstr)

    return files


def collect_files_remote(host: str, base_dir: str, ssh_auth: str) -> list[str]:
    """Collect JSONL files from remote host via SSH, download to temp dir."""
    tmp_dir = "/tmp/claude_sessions_remote"
    os.makedirs(tmp_dir, exist_ok=True)

    env = os.environ.copy()
    env["SSH_AUTH_SOCK"] = ssh_auth

    # List remote files
    try:
        result = subprocess.run(
            ["ssh", host, f"find {base_dir} -name '*.jsonl' -not -path '*/subagents/*' -size +5k"],
            capture_output=True, text=True, timeout=30, env=env,
        )
        remote_files = [l.strip() for l in result.stdout.strip().split("\n") if l.strip()]
    except (subprocess.TimeoutExpired, subprocess.CalledProcessError):
        print("  Failed to list remote files", file=sys.stderr)
        return []

    if not remote_files:
        return []

    print(f"  Found {len(remote_files)} remote session files")

    # Download in batches using rsync
    local_files = []
    for rf in remote_files:
        local_path = os.path.join(tmp_dir, rf.replace("/", "_"))
        if os.path.exists(local_path):
            local_files.append(local_path)
            continue
        try:
            subprocess.run(
                ["scp", "-q", f"{host}:{rf}", local_path],
                capture_output=True, timeout=30, env=env,
            )
            if os.path.exists(local_path):
                local_files.append(local_path)
        except (subprocess.TimeoutExpired, subprocess.CalledProcessError):
            continue

    return local_files


def main():
    output_dir = "/home/rix/.exophial/dc/mogfish/training"
    train_path = os.path.join(output_dir, "classification_train.jsonl")
    eval_path = os.path.join(output_dir, "classification_eval.jsonl")

    all_results = []
    seen_inputs = set()

    # Process local files
    print("Processing local session files...")
    local_files = collect_files_local(os.path.expanduser("~/.claude/projects"))
    print(f"  Found {len(local_files)} local session files")

    for i, filepath in enumerate(local_files):
        pairs = process_session_file(filepath)
        for pair in pairs:
            inp = pair["input"]
            if inp not in seen_inputs:
                seen_inputs.add(inp)
                all_results.append(pair)
        if (i + 1) % 200 == 0:
            print(f"  Processed {i + 1}/{len(local_files)} files, {len(all_results)} unique pairs so far")

    local_count = len(all_results)
    print(f"  Local: {local_count} unique pairs extracted")

    # Process remote files
    ssh_auth = "/tmp/ssh-Lk7vHxsKl1/agent.3889143"
    remote_host = "rix@10.5.5.1"
    remote_dir = "/Users/rix/.claude/projects/"

    if os.path.exists(ssh_auth):
        print("Processing remote session files...")
        remote_files = collect_files_remote(remote_host, remote_dir, ssh_auth)
        print(f"  Downloaded {len(remote_files)} remote session files")

        for i, filepath in enumerate(remote_files):
            pairs = process_session_file(filepath)
            for pair in pairs:
                inp = pair["input"]
                if inp not in seen_inputs:
                    seen_inputs.add(inp)
                    all_results.append(pair)
            if (i + 1) % 200 == 0:
                print(f"  Processed {i + 1}/{len(remote_files)} remote files")

        remote_count = len(all_results) - local_count
        print(f"  Remote: {remote_count} new unique pairs extracted")
    else:
        print(f"SSH_AUTH_SOCK not found at {ssh_auth}, skipping remote")

    # Category breakdown
    categories = {}
    for r in all_results:
        cat = json.loads(r["output"])["category"]
        categories[cat] = categories.get(cat, 0) + 1

    print(f"\nTotal unique user messages: {len(all_results)}")
    print("Breakdown by category:")
    for cat, count in sorted(categories.items()):
        print(f"  {cat}: {count} ({count * 100 / len(all_results):.1f}%)")

    # Balance: cap each category at 2x the smallest category
    if len(categories) > 1:
        min_count = min(categories.values())
        cap = min_count * 3  # Allow 3x imbalance max

        balanced = []
        cat_counts = {}
        random.seed(42)
        random.shuffle(all_results)

        for r in all_results:
            cat = json.loads(r["output"])["category"]
            cat_counts[cat] = cat_counts.get(cat, 0) + 1
            if cat_counts[cat] <= cap:
                balanced.append(r)

        if len(balanced) < len(all_results):
            print(f"\nBalanced: {len(all_results)} → {len(balanced)} (capped at {cap} per category)")
            all_results = balanced

            # Recount
            categories = {}
            for r in all_results:
                cat = json.loads(r["output"])["category"]
                categories[cat] = categories.get(cat, 0) + 1
            print("Balanced breakdown:")
            for cat, count in sorted(categories.items()):
                print(f"  {cat}: {count}")

    # Shuffle and split 95/5
    random.seed(42)
    random.shuffle(all_results)
    split_idx = max(1, int(len(all_results) * 0.95))
    train_data = all_results[:split_idx]
    eval_data = all_results[split_idx:]

    # Write output
    with open(train_path, "w") as f:
        for item in train_data:
            f.write(json.dumps(item) + "\n")

    with open(eval_path, "w") as f:
        for item in eval_data:
            f.write(json.dumps(item) + "\n")

    print(f"\nFinal dataset: {len(train_data)} train, {len(eval_data)} eval")
    print(f"Written to:\n  {train_path}\n  {eval_path}")


if __name__ == "__main__":
    main()
