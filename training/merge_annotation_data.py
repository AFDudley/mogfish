#!/usr/bin/env python3
"""Merge original and scraped annotation data with short-input oversampling.

Combines:
- training/annotation_train.jsonl (original 1,010 examples)
- training/scraped_annotations/*.jsonl (from exophial workers)
- training/short_augmented_annotations.jsonl (synthetic short inputs)

Oversamples short inputs (<500 chars) by 3x to address the training gap
where the model fails on minimal help text.

Usage:
    python3 training/merge_annotation_data.py
"""

import json
import random
import sys
from pathlib import Path

ORIGINAL = Path("training/annotation_train.jsonl")
SCRAPED_DIR = Path("training/scraped_annotations")
SHORT_AUGMENTED = Path("training/short_augmented_annotations.jsonl")
DPO_PAIRS = Path("training/annotation_dpo_pairs.jsonl")

OUTPUT_TRAIN = Path("training/annotation_train_expanded.jsonl")
OUTPUT_EVAL = Path("training/annotation_eval_expanded.jsonl")

SHORT_THRESHOLD = 500  # chars
SHORT_OVERSAMPLE = 3   # duplication factor for short inputs
EVAL_FRACTION = 0.05
SEED = 42


def load_jsonl(path: Path) -> list[dict]:
    records = []
    if not path.exists():
        return records
    with open(path) as f:
        for line in f:
            line = line.strip()
            if line:
                records.append(json.loads(line))
    return records


def load_dir_jsonl(dir_path: Path) -> list[dict]:
    records = []
    if not dir_path.exists():
        return records
    for f in sorted(dir_path.glob("*.jsonl")):
        records.extend(load_jsonl(f))
    return records


def input_length(record: dict) -> int:
    return len(record.get("input", ""))


def main():
    # Load all sources
    original = load_jsonl(ORIGINAL)
    scraped = load_dir_jsonl(SCRAPED_DIR)
    augmented = load_jsonl(SHORT_AUGMENTED)

    print(f"Original:  {len(original)} examples")
    print(f"Scraped:   {len(scraped)} examples")
    print(f"Augmented: {len(augmented)} examples")

    # Combine
    all_records = original + scraped + augmented

    # Deduplicate by input field
    seen = set()
    deduped = []
    for r in all_records:
        key = r.get("input", "")
        if key not in seen:
            seen.add(key)
            deduped.append(r)

    dupes = len(all_records) - len(deduped)
    print(f"Deduplicated: {dupes} removed, {len(deduped)} unique")

    # Size distribution before oversampling
    short = [r for r in deduped if input_length(r) < SHORT_THRESHOLD]
    medium = [r for r in deduped if SHORT_THRESHOLD <= input_length(r) < 2000]
    long = [r for r in deduped if input_length(r) >= 2000]
    print(f"Size distribution: {len(short)} short (<{SHORT_THRESHOLD}), "
          f"{len(medium)} medium, {len(long)} long")

    # Oversample short inputs
    oversampled = deduped.copy()
    for _ in range(SHORT_OVERSAMPLE - 1):
        oversampled.extend(short)

    print(f"After {SHORT_OVERSAMPLE}x oversampling of short: {len(oversampled)} total")

    # Shuffle
    random.seed(SEED)
    random.shuffle(oversampled)

    # Split train/eval
    split_idx = int(len(oversampled) * (1 - EVAL_FRACTION))
    train = oversampled[:split_idx]
    eval_set = oversampled[split_idx:]

    # Write
    OUTPUT_TRAIN.parent.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_TRAIN, "w") as f:
        for r in train:
            f.write(json.dumps(r) + "\n")

    with open(OUTPUT_EVAL, "w") as f:
        for r in eval_set:
            f.write(json.dumps(r) + "\n")

    print(f"\nOutput: {len(train)} train, {len(eval_set)} eval")
    print(f"  {OUTPUT_TRAIN}")
    print(f"  {OUTPUT_EVAL}")

    # DPO pairs (separate, not merged into instruction-tuning data)
    dpo = load_jsonl(DPO_PAIRS)
    if dpo:
        print(f"\nDPO pairs available: {len(dpo)} (in {DPO_PAIRS})")
    else:
        print(f"\nNo DPO pairs yet (expected at {DPO_PAIRS})")


if __name__ == "__main__":
    main()
