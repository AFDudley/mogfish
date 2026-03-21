#!/usr/bin/env python3
"""Extract bash commands from Claude Code session transcripts for mogfish training data."""

import json
import sys
from collections import Counter
from pathlib import Path

# Trivial commands to skip (exact match on first token)
TRIVIAL_PREFIXES = {"cd", "ls", "pwd", "echo", "cat", "head", "tail", "wc", "true", "false"}

# Skip standalone grep/find (no pipe = read-only exploration)
SKIP_STANDALONE = {"grep", "find", "rg"}


def is_trivial(command: str) -> bool:
    """Check if a command is trivial and should be skipped."""
    stripped = command.strip()
    if not stripped:
        return True

    first_token = stripped.split()[0]

    # Skip trivial single commands
    if first_token in TRIVIAL_PREFIXES:
        return True

    # Skip standalone grep/find with no pipe
    if first_token in SKIP_STANDALONE and "|" not in stripped:
        return True

    return False


def extract_from_file(filepath: Path) -> list[dict]:
    """Extract bash commands from a single JSONL session file."""
    results = []
    with open(filepath, "r", errors="replace") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                event = json.loads(line)
            except json.JSONDecodeError:
                continue

            if event.get("type") != "assistant":
                continue

            message = event.get("message", {})
            content = message.get("content", [])
            if not isinstance(content, list):
                continue

            cwd = event.get("cwd", "")

            for block in content:
                if not isinstance(block, dict):
                    continue
                if block.get("type") != "tool_use" or block.get("name") != "Bash":
                    continue

                inp = block.get("input", {})
                command = inp.get("command", "")
                if not command:
                    continue

                results.append({
                    "command": command,
                    "description": inp.get("description", ""),
                    "cwd": cwd,
                    "session_file": str(filepath),
                })

    return results


def process_directory(projects_dir: Path, prefix: str = "") -> tuple[list[dict], int]:
    """Process all JSONL files in a projects directory."""
    all_commands: list[dict] = []
    total_events = 0

    jsonl_files = list(projects_dir.rglob("*.jsonl"))
    print(f"{prefix}Found {len(jsonl_files)} JSONL files in {projects_dir}")

    for i, filepath in enumerate(jsonl_files):
        if (i + 1) % 500 == 0:
            print(f"  Processed {i + 1}/{len(jsonl_files)} files...")

        # Count total events
        try:
            with open(filepath, "r", errors="replace") as f:
                for line in f:
                    if line.strip():
                        total_events += 1
        except (OSError, IOError):
            continue

        try:
            commands = extract_from_file(filepath)
            all_commands.extend(commands)
        except (OSError, IOError) as e:
            print(f"  Error reading {filepath}: {e}", file=sys.stderr)

    return all_commands, total_events


def main():
    output_path = Path("/home/rix/.exophial/dc/mogfish/training/bash_commands.jsonl")

    # Process local data
    local_dir = Path.home() / ".claude" / "projects"
    print("=== Processing local data ===")
    all_commands, total_events = process_directory(local_dir, prefix="[local] ")

    raw_count = len(all_commands)
    print(f"\nTotal events scanned: {total_events}")
    print(f"Bash commands found (before filter): {raw_count}")

    # Filter
    filtered = []
    seen_commands: set[str] = set()

    for cmd in all_commands:
        command = cmd["command"]

        # Skip long commands
        if len(command) > 500:
            continue

        # Skip trivial
        if is_trivial(command):
            continue

        # Dedup by exact command string
        if command in seen_commands:
            continue
        seen_commands.add(command)

        filtered.append(cmd)

    print(f"After dedup and filter: {len(filtered)}")

    # Write output
    with open(output_path, "w") as f:
        for cmd in filtered:
            f.write(json.dumps(cmd) + "\n")

    print(f"\nWritten to {output_path}")

    # Top 10 command prefixes
    prefix_counter: Counter[str] = Counter()
    for cmd in filtered:
        first = cmd["command"].strip().split()[0] if cmd["command"].strip() else ""
        prefix_counter[first] += 1

    print("\nTop 10 most common command prefixes:")
    for prefix, count in prefix_counter.most_common(10):
        print(f"  {prefix}: {count}")


if __name__ == "__main__":
    main()
