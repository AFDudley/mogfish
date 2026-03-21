"""Fast concurrent annotation data preparation using asyncio.

Same logic as prepare_annotations.py but runs 10 API calls concurrently.
Resumes from annotation_progress.jsonl (compatible with the serial version).
"""

import anthropic
import asyncio
import json
import os
import random
import sys
from pathlib import Path

COMPLETIONS_DIR = Path("/home/rix/.exophial/dc/mogfish/fish/share/completions")
OUTPUT_DIR = Path("/home/rix/.exophial/dc/mogfish/training")
DATA_DIR = Path(os.path.expanduser("~/mogfish-data"))

CONCURRENCY = 10

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


def validate_annotation(ann: dict) -> bool:
    if not isinstance(ann.get("description"), str) or not ann["description"]:
        return False
    if not isinstance(ann.get("intents"), list) or len(ann["intents"]) < 2:
        return False
    if not isinstance(ann.get("flags"), list):
        return False
    for flag in ann["flags"]:
        if not isinstance(flag, dict) or "flag" not in flag or "description" not in flag:
            return False
    return True


async def process_file(
    client: anthropic.AsyncAnthropic,
    filepath: Path,
    semaphore: asyncio.Semaphore,
    progress_lock: asyncio.Lock,
    progress_file,
    counter: dict,
) -> dict | None:
    command = filepath.stem
    content = filepath.read_text(errors="replace")

    if len(content.strip()) < 20:
        counter["skipped"] += 1
        return None

    if len(content) > 8000:
        content = content[:8000] + "\n... (truncated)"

    async with semaphore:
        for attempt in range(3):
            try:
                response = await client.messages.create(
                    model="claude-sonnet-4-20250514",
                    max_tokens=1024,
                    system=SYSTEM_PROMPT,
                    messages=[{
                        "role": "user",
                        "content": USER_TEMPLATE.format(command=command, content=content),
                    }],
                )
                text = response.content[0].text.strip()
                if text.startswith("```"):
                    text = text.split("\n", 1)[1]
                    if text.endswith("```"):
                        text = text[:-3]
                    text = text.strip()

                ann = json.loads(text)
                if not validate_annotation(ann):
                    counter["invalid"] += 1
                    print(f"  INVALID: {command}", file=sys.stderr)
                    return None

                example = {
                    "instruction": "Generate a mogfish annotation for this command documentation",
                    "input": f"Command: {command}\n\n{filepath.read_text(errors='replace')}",
                    "output": json.dumps(ann, ensure_ascii=False),
                }

                async with progress_lock:
                    progress_file.write(json.dumps({"command": command, "example": example}) + "\n")
                    progress_file.flush()
                    counter["done"] += 1
                    if counter["done"] % 50 == 0:
                        print(f"  Progress: {counter['done']} done, {counter['invalid']} invalid, {counter['skipped']} skipped")

                return example

            except anthropic.RateLimitError:
                wait = 10 * (attempt + 1)
                print(f"  Rate limited on {command}, waiting {wait}s...", file=sys.stderr)
                await asyncio.sleep(wait)
            except json.JSONDecodeError:
                counter["invalid"] += 1
                print(f"  JSON error: {command}", file=sys.stderr)
                return None
            except Exception as e:
                print(f"  Error on {command}: {e}", file=sys.stderr)
                return None

    return None


async def main():
    client = anthropic.AsyncAnthropic()

    fish_files = sorted(COMPLETIONS_DIR.glob("*.fish"))
    print(f"Found {len(fish_files)} fish completion files")

    # Load existing progress
    progress_path = OUTPUT_DIR / "annotation_progress.jsonl"
    done_commands: set[str] = set()
    examples: list[dict] = []

    if progress_path.exists():
        with open(progress_path) as f:
            for line in f:
                rec = json.loads(line)
                done_commands.add(rec["command"])
                examples.append(rec["example"])
        print(f"Resuming: {len(done_commands)} already done")

    remaining = [f for f in fish_files if f.stem not in done_commands]
    print(f"Processing {len(remaining)} remaining files with {CONCURRENCY} concurrent requests...")

    semaphore = asyncio.Semaphore(CONCURRENCY)
    progress_lock = asyncio.Lock()
    counter = {"done": len(done_commands), "invalid": 0, "skipped": 0}

    with open(progress_path, "a") as pf:
        tasks = [
            process_file(client, fp, semaphore, progress_lock, pf, counter)
            for fp in remaining
        ]
        results = await asyncio.gather(*tasks)

    new_examples = [r for r in results if r is not None]
    examples.extend(new_examples)

    print(f"\nTotal: {len(examples)} valid examples ({counter['invalid']} invalid, {counter['skipped']} skipped)")

    # Shuffle and split 95/5
    random.seed(42)
    random.shuffle(examples)
    split_idx = max(1, int(len(examples) * 0.05))
    eval_set = examples[:split_idx]
    train_set = examples[split_idx:]

    for output_dir in [OUTPUT_DIR, DATA_DIR]:
        output_dir.mkdir(parents=True, exist_ok=True)
        with open(output_dir / "annotation_train.jsonl", "w") as f:
            for ex in train_set:
                f.write(json.dumps(ex, ensure_ascii=False) + "\n")
        with open(output_dir / "annotation_eval.jsonl", "w") as f:
            for ex in eval_set:
                f.write(json.dumps(ex, ensure_ascii=False) + "\n")
        print(f"Wrote {len(train_set)} train, {len(eval_set)} eval to {output_dir}")


if __name__ == "__main__":
    asyncio.run(main())
