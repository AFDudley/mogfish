"""Evaluate Pass 1 annotator on held-out annotation_eval.jsonl.

Loads the fine-tuned model, generates annotations for each eval example,
and reports quality metrics: JSON parse rate, field completeness, and
a sample of outputs for manual review.
"""

import json
import os
import sys
from pathlib import Path

import torch
from unsloth import FastLanguageModel

ADAPTER_DIR = Path(os.path.expanduser("~/mogfish-adapters/pass1-annotator"))
DATA_DIR = Path(os.path.expanduser("~/mogfish-data"))
MAX_SEQ_LENGTH = 4096


def format_input_prompt(example: dict) -> str:
    """Format just the input portion (no expected output)."""
    return (
        f"<start_of_turn>user\n"
        f"{example['instruction']}\n\n"
        f"{example['input']}<end_of_turn>\n"
        f"<start_of_turn>model\n"
    )


def validate_annotation(text: str) -> tuple[bool, dict | None]:
    """Try to parse model output as a valid Annotation."""
    text = text.strip()
    # Strip markdown fencing
    if text.startswith("```"):
        text = text.split("\n", 1)[1]
        if "```" in text:
            text = text[:text.rindex("```")]
        text = text.strip()

    try:
        ann = json.loads(text)
    except json.JSONDecodeError:
        return False, None

    if not isinstance(ann.get("description"), str) or not ann["description"]:
        return False, None
    if not isinstance(ann.get("intents"), list) or len(ann["intents"]) < 1:
        return False, None
    if not isinstance(ann.get("flags"), list):
        return False, None

    return True, ann


def main():
    print("Loading model...")
    model, tokenizer = FastLanguageModel.from_pretrained(
        model_name=str(ADAPTER_DIR),
        max_seq_length=MAX_SEQ_LENGTH,
        load_in_4bit=True,
    )
    FastLanguageModel.for_inference(model)

    eval_path = DATA_DIR / "annotation_eval.jsonl"
    examples = []
    with open(eval_path) as f:
        for line in f:
            examples.append(json.loads(line))

    print(f"Evaluating {len(examples)} examples...\n")

    valid_count = 0
    total = len(examples)
    sample_outputs = []

    for i, ex in enumerate(examples):
        prompt = format_input_prompt(ex)
        inputs = tokenizer(prompt, return_tensors="pt").to(model.device)

        with torch.no_grad():
            outputs = model.generate(
                **inputs,
                max_new_tokens=512,
                temperature=0.1,
                do_sample=True,
            )

        generated = tokenizer.decode(outputs[0][inputs["input_ids"].shape[1]:], skip_special_tokens=True)
        is_valid, parsed = validate_annotation(generated)

        if is_valid:
            valid_count += 1

        # Keep first 20 for manual review
        if i < 20:
            expected = json.loads(ex["output"])
            sample_outputs.append({
                "command": ex["input"].split("\n")[0],
                "valid": is_valid,
                "expected_description": expected["description"],
                "generated_description": parsed["description"] if parsed else generated[:200],
            })

        print(f"  [{i+1}/{total}] {'OK' if is_valid else 'FAIL'}")

    print(f"\n{'='*60}")
    print(f"Results: {valid_count}/{total} valid ({valid_count/total*100:.1f}%)")
    print(f"{'='*60}")

    print("\nSample outputs for manual review:")
    for s in sample_outputs:
        print(f"\n  {s['command']}")
        print(f"    Valid: {s['valid']}")
        print(f"    Expected: {s['expected_description']}")
        print(f"    Got:      {s['generated_description']}")

    # Write results
    results_path = DATA_DIR / "eval_results_pass1.json"
    with open(results_path, "w") as f:
        json.dump({
            "valid_count": valid_count,
            "total": total,
            "valid_rate": valid_count / total if total > 0 else 0,
            "samples": sample_outputs,
        }, f, indent=2)
    print(f"\nResults saved to {results_path}")


if __name__ == "__main__":
    main()
