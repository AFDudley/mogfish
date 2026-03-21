"""Convert annotation JSONL to mlx-lm chat format.

mlx-lm expects JSONL with a "messages" field containing chat-format entries.
This converts our instruction/input/output format to that.
"""

import json
import sys
from pathlib import Path


def convert_to_chat(record: dict) -> dict:
    """Convert instruction-tuning record to chat format."""
    return {
        "messages": [
            {
                "role": "user",
                "content": f"{record['instruction']}\n\n{record['input']}",
            },
            {
                "role": "assistant",
                "content": record["output"],
            },
        ]
    }


def main():
    data_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.home() / "mogfish-data"

    for split in ["train", "eval"]:
        input_path = data_dir / f"annotation_{split}.jsonl"
        output_path = data_dir / f"annotation_{split}_chat.jsonl"

        if not input_path.exists():
            print(f"Skipping {input_path} (not found)")
            continue

        count = 0
        with open(input_path) as f_in, open(output_path, "w") as f_out:
            for line in f_in:
                rec = json.loads(line)
                chat = convert_to_chat(rec)
                f_out.write(json.dumps(chat, ensure_ascii=False) + "\n")
                count += 1

        print(f"Wrote {count} chat examples to {output_path}")


if __name__ == "__main__":
    main()
