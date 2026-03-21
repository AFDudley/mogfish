"""Prepare annotation training data from fish completion files.

Reads .fish completion files, sends each to Claude API to generate
a mogfish Annotation (description, intents, flags), and writes
training JSONL files with a 95/5 train/eval split.

Output matches the Annotation struct in mogfish-traits:
  - description: one-sentence description of the command
  - intents: natural language phrases a user might type
  - flags: list of {flag, description} objects
"""

import anthropic
import json
import os
import random
import sys
import time
from pathlib import Path

COMPLETIONS_DIR = Path("/home/rix/.exophial/dc/mogfish/fish/share/completions")
OUTPUT_DIR = Path("/home/rix/.exophial/dc/mogfish/training")
DATA_DIR = Path(os.path.expanduser("~/mogfish-data"))

SYSTEM_PROMPT = """You are generating structured annotations for CLI commands based on their fish shell completion files.

For each command, produce a JSON object with exactly this structure:
{
  "description": "one-sentence description of what this command does",
  "intents": ["natural language phrase 1", "phrase 2", "phrase 3"],
  "flags": [
    {"flag": "--flag-name", "description": "what this flag does"},
    ...
  ]
}

Rules:
- description: one clear sentence, no period at end
- intents: 3-5 natural language phrases a user might type to invoke this tool (e.g., "search files for text" not "use grep")
- flags: include the 5-10 most commonly used flags. Use the short form if available (e.g., "-r" not "--recursive"). Include both short and long form if both exist (e.g., "-r/--recursive")
- Return ONLY the JSON object, no markdown fencing or explanation"""

USER_TEMPLATE = """Generate a mogfish annotation for the command `{command}` based on this fish completion file:

{content}"""


def extract_command_name(filepath: Path) -> str:
    """Extract command name from .fish filename."""
    return filepath.stem


def call_claude(client: anthropic.Anthropic, command: str, content: str) -> dict | None:
    """Call Claude API to generate annotation for a command."""
    # Truncate very long files to avoid token waste
    if len(content) > 8000:
        content = content[:8000] + "\n... (truncated)"

    try:
        response = client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=1024,
            system=SYSTEM_PROMPT,
            messages=[{
                "role": "user",
                "content": USER_TEMPLATE.format(command=command, content=content),
            }],
        )
        text = response.content[0].text.strip()
        # Strip markdown fencing if present
        if text.startswith("```"):
            text = text.split("\n", 1)[1]
            if text.endswith("```"):
                text = text[:-3]
            text = text.strip()
        return json.loads(text)
    except json.JSONDecodeError as e:
        print(f"  JSON parse error for {command}: {e}", file=sys.stderr)
        return None
    except anthropic.RateLimitError:
        print("  Rate limited, waiting 30s...", file=sys.stderr)
        time.sleep(30)
        return call_claude(client, command, content)
    except Exception as e:
        print(f"  API error for {command}: {e}", file=sys.stderr)
        return None


def validate_annotation(ann: dict) -> bool:
    """Check that annotation matches expected Annotation struct shape."""
    if not isinstance(ann.get("description"), str) or not ann["description"]:
        return False
    if not isinstance(ann.get("intents"), list) or len(ann["intents"]) < 2:
        return False
    if not isinstance(ann.get("flags"), list):
        return False
    for flag in ann["flags"]:
        if not isinstance(flag, dict):
            return False
        if "flag" not in flag or "description" not in flag:
            return False
    return True


def format_training_example(command: str, fish_content: str, annotation: dict) -> dict:
    """Format as instruction-tuning JSONL record."""
    return {
        "instruction": "Generate a mogfish annotation for this command documentation",
        "input": f"Command: {command}\n\n{fish_content}",
        "output": json.dumps(annotation, ensure_ascii=False),
    }


def main():
    client = anthropic.Anthropic()

    # Gather all .fish files
    fish_files = sorted(COMPLETIONS_DIR.glob("*.fish"))
    print(f"Found {len(fish_files)} fish completion files")

    # Check for existing progress
    progress_file = OUTPUT_DIR / "annotation_progress.jsonl"
    done_commands: set[str] = set()
    examples: list[dict] = []

    if progress_file.exists():
        with open(progress_file) as f:
            for line in f:
                rec = json.loads(line)
                done_commands.add(rec["command"])
                examples.append(rec["example"])
        print(f"Resuming: {len(done_commands)} already done")

    # Process each file
    remaining = [f for f in fish_files if extract_command_name(f) not in done_commands]
    print(f"Processing {len(remaining)} remaining files...")

    with open(progress_file, "a") as progress:
        for i, filepath in enumerate(remaining):
            command = extract_command_name(filepath)
            content = filepath.read_text(errors="replace")

            # Skip near-empty files
            if len(content.strip()) < 20:
                print(f"  [{i+1}/{len(remaining)}] Skipping {command} (too short)")
                continue

            print(f"  [{i+1}/{len(remaining)}] {command}...", end=" ", flush=True)
            annotation = call_claude(client, command, content)

            if annotation and validate_annotation(annotation):
                example = format_training_example(command, content, annotation)
                examples.append(example)
                # Save progress
                progress.write(json.dumps({"command": command, "example": example}) + "\n")
                progress.flush()
                print("OK")
            else:
                print("SKIP (invalid)")

            # Gentle rate limiting: ~2 requests/sec
            time.sleep(0.5)

    print(f"\nTotal valid examples: {len(examples)}")

    # Shuffle and split 95/5
    random.seed(42)
    random.shuffle(examples)
    split_idx = max(1, int(len(examples) * 0.05))
    eval_set = examples[:split_idx]
    train_set = examples[split_idx:]

    # Write to both training/ and ~/mogfish-data/
    for output_dir in [OUTPUT_DIR, DATA_DIR]:
        train_path = output_dir / "annotation_train.jsonl"
        eval_path = output_dir / "annotation_eval.jsonl"

        with open(train_path, "w") as f:
            for ex in train_set:
                f.write(json.dumps(ex, ensure_ascii=False) + "\n")

        with open(eval_path, "w") as f:
            for ex in eval_set:
                f.write(json.dumps(ex, ensure_ascii=False) + "\n")

        print(f"Wrote {len(train_set)} train, {len(eval_set)} eval to {output_dir}")


if __name__ == "__main__":
    main()
