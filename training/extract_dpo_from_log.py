#!/usr/bin/env python3
"""Extract DPO pairs from annotator log output.

Parses [annotate] response lines from the mogfish-annotate batch log,
classifies each as valid or degraded (repetition, whitespace padding,
truncation), and generates DPO pairs for degraded outputs.

Usage:
    python3 training/extract_dpo_from_log.py /tmp/dpo-run-cpu.log /tmp/dpo-batch
"""

import json
import re
import sys
from collections import Counter
from pathlib import Path

OUTPUT = Path("training/annotation_dpo_pairs.jsonl")
INSTRUCTION = "Generate a mogfish annotation for this command documentation"


def extract_responses(log_path: Path) -> list[str]:
    """Extract raw JSON responses from annotator log."""
    responses = []
    with open(log_path) as f:
        for line in f:
            # Log format: [annotate] response (NNN chars): "ESCAPED_JSON"
            match = re.search(r'\[annotate\] response \(\d+ chars\): "(.+)"$', line.rstrip())
            if match:
                # The content is Rust's {:?} debug format — escaped quotes
                raw = match.group(1)
                # Unescape Rust debug string: \" -> "  and \\ -> \
                raw = raw.replace('\\"', '"').replace('\\\\', '\\').replace('\\n', '\n')
                responses.append(raw)
    return responses


def classify_response(raw: str) -> tuple[str, str]:
    """Classify a response as valid or degraded. Returns (status, reason)."""
    # Check if it's valid JSON
    try:
        ann = json.loads(raw)
    except json.JSONDecodeError:
        return "broken", "invalid JSON"

    desc = ann.get("description", "")
    intents = ann.get("intents", [])
    flags = ann.get("flags", [])

    if not desc:
        return "broken", "no description"

    if not intents:
        return "broken", "no intents"

    # Check for repetitive intents
    if len(intents) > 3:
        unique = len(set(intents))
        if unique < len(intents) * 0.6:
            return "degraded", f"repetitive intents ({unique} unique / {len(intents)} total)"

    # Check for whitespace padding (raw response much longer than content)
    content_len = len(desc) + sum(len(i) for i in intents) + sum(
        len(f.get("flag", "")) + len(f.get("description", "")) for f in flags
    )
    if len(raw) > content_len * 3 and len(raw) > 500:
        return "degraded", f"whitespace padding ({len(raw)} raw vs {content_len} content)"

    # Check for degenerate tokens in any field
    all_text = desc + " " + " ".join(intents)
    tokens = all_text.split()
    if tokens:
        most_common_count = Counter(tokens).most_common(1)[0][1]
        if most_common_count > len(tokens) * 0.4 and len(tokens) > 10:
            return "degraded", f"degenerate tokens ({most_common_count}/{len(tokens)})"

    # Check intents hit maxItems cap (10) — may have been truncated
    if len(intents) >= 10:
        return "degraded", "hit maxItems cap (10 intents)"

    return "valid", ""


def get_fish_files(batch_dir: Path) -> list[Path]:
    """Get fish files in order matching annotator processing."""
    return sorted(batch_dir.glob("*.fish"))


def generate_correct_annotation(command: str, content: str) -> str:
    """Generate a rule-based correct annotation from fish completion content."""
    flags = []
    descriptions = []

    for line in content.split("\n"):
        line = line.strip()
        if not line.startswith("complete"):
            continue

        short = ""
        long_flag = ""
        desc = ""

        short_match = re.search(r"-s\s+(\S+)", line)
        if short_match:
            short = f"-{short_match.group(1)}"

        long_match = re.search(r"-l\s+(\S+)", line)
        if long_match:
            long_flag = f"--{long_match.group(1)}"

        desc_match = re.search(r"""-d\s+['"]([^'"]+)['"]""", line)
        if not desc_match:
            desc_match = re.search(r"-d\s+(\S+)", line)
        if desc_match:
            desc = desc_match.group(1)

        if (short or long_flag) and desc:
            flag_name = f"{short}/{long_flag}" if short and long_flag else (short or long_flag)
            if flag_name not in [f["flag"] for f in flags]:
                flags.append({"flag": flag_name, "description": desc})
                if len(desc) > 5:
                    descriptions.append(desc)

    intents = [f"use {command}", f"run {command}"]
    for d in descriptions[:3]:
        intents.append(d.lower()[:50])
    intents = intents[:5]

    return json.dumps({
        "description": f"Command-line tool: {command}",
        "intents": intents,
        "flags": flags[:10],
    })


def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <log-file> <batch-dir>", file=sys.stderr)
        sys.exit(1)

    log_path = Path(sys.argv[1])
    batch_dir = Path(sys.argv[2])

    responses = extract_responses(log_path)
    fish_files = get_fish_files(batch_dir)

    print(f"Responses in log: {len(responses)}")
    print(f"Fish files in batch: {len(fish_files)}")

    valid = 0
    degraded = 0
    broken = 0
    pairs = []

    for i, raw in enumerate(responses):
        status, reason = classify_response(raw)

        if status == "valid":
            valid += 1
        else:
            if status == "degraded":
                degraded += 1
            else:
                broken += 1

            # Match to fish file (responses are in order)
            if i < len(fish_files):
                fish_file = fish_files[i]
                command = fish_file.stem
                content = fish_file.read_text()

                correct = generate_correct_annotation(command, content)
                prompt = f"{INSTRUCTION}\n\nCommand: {command}\n\n{content[:2000]}"

                pairs.append({
                    "prompt": prompt,
                    "chosen": correct,
                    "rejected": raw,
                    "reason": reason,
                })

                print(f"  {status}: {command} — {reason}")

    print(f"\nResults: {valid} valid, {degraded} degraded, {broken} broken")
    print(f"DPO pairs: {len(pairs)}")

    with open(OUTPUT, "w") as f:
        for pair in pairs:
            f.write(json.dumps(pair) + "\n")

    print(f"Written to {OUTPUT}")


if __name__ == "__main__":
    main()
