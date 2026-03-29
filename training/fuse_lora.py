#!/usr/bin/env python3
"""Fuse MLX-format LoRA adapters into HF safetensors base model.

MLX LoRA stores lora_a and lora_b per layer. The fusion formula is:
    W_new = W_base + scale * delta
where delta has the same shape as W_base, derived from lora_a and lora_b.

Usage:
    source ~/mogfish-train/bin/activate
    python3 training/fuse_lora.py
"""

import json
import shutil
from pathlib import Path

import torch
from safetensors.torch import load_file, save_file

BASE_DIR = Path("/home/rix/mogfish-model/gemma3-1b-it")
ADAPTER_DIR = Path("/home/rix/mogfish-adapters/combined-v1")
OUTPUT_DIR = Path("/home/rix/mogfish-model/gemma3-1b-mogfish-combined-v1")


def main():
    # Load adapter config
    with open(ADAPTER_DIR / "adapter_config.json") as f:
        acfg = json.load(f)
    lora_params = acfg["lora_parameters"]
    scale = lora_params["alpha"] / lora_params["rank"]
    print(f"LoRA config: rank={lora_params['rank']}, alpha={lora_params['alpha']}, scale={scale}")

    # Load base weights
    print(f"Loading base model from {BASE_DIR}")
    base = load_file(str(BASE_DIR / "model.safetensors"))
    print(f"  {len(base)} tensors loaded")

    # Load adapter weights (final checkpoint)
    adapter_file = ADAPTER_DIR / "adapters.safetensors"
    print(f"Loading adapter from {adapter_file}")
    adapters = load_file(str(adapter_file))
    print(f"  {len(adapters)} adapter tensors loaded")

    # Group adapter tensors by target parameter
    lora_pairs = {}
    for key in adapters:
        if key.endswith(".lora_a"):
            param_name = key[: -len(".lora_a")]
            lora_pairs.setdefault(param_name, {})["a"] = adapters[key]
        elif key.endswith(".lora_b"):
            param_name = key[: -len(".lora_b")]
            lora_pairs.setdefault(param_name, {})["b"] = adapters[key]

    print(f"  {len(lora_pairs)} LoRA pairs found")

    # Fuse each pair
    fused = 0
    for param_name, pair in sorted(lora_pairs.items()):
        weight_key = param_name + ".weight"
        if weight_key not in base:
            print(f"  WARNING: no base weight for {weight_key}, skipping")
            continue

        a = pair["a"].float()
        b = pair["b"].float()
        w = base[weight_key].float()

        # Determine correct delta shape.
        # MLX LoRA: a=[out_features, rank], b=[rank, in_features] typically.
        # Try a @ b first, then transpose if needed.
        delta = None
        for fn, label in [
            (lambda: a @ b, "a @ b"),
            (lambda: (a @ b).T, "(a @ b).T"),
            (lambda: b @ a, "b @ a"),
            (lambda: (b @ a).T, "(b @ a).T"),
        ]:
            try:
                candidate = fn()
                if candidate.shape == w.shape:
                    delta = candidate
                    if fused == 0:
                        print(f"  Using {label} for delta (a={a.shape}, b={b.shape}, w={w.shape})")
                    break
            except RuntimeError:
                continue

        if delta is None:
            print(f"  ERROR: no orientation works for {weight_key}: "
                  f"a={a.shape}, b={b.shape}, w={w.shape}")
            continue

        base[weight_key] = (w + scale * delta).to(torch.bfloat16)
        fused += 1

    print(f"Fused {fused}/{len(lora_pairs)} LoRA pairs")

    # Save fused model
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    print(f"Saving fused model to {OUTPUT_DIR}")
    save_file(base, str(OUTPUT_DIR / "model.safetensors"))

    # Copy non-weight files from base
    copied = []
    for fname in [
        "config.json",
        "tokenizer.json",
        "tokenizer_config.json",
        "tokenizer.model",
        "special_tokens_map.json",
        "added_tokens.json",
        "generation_config.json",
        "chat_template.jinja",
    ]:
        src = BASE_DIR / fname
        if src.exists():
            shutil.copy2(src, OUTPUT_DIR / fname)
            copied.append(fname)

    print(f"Copied {len(copied)} config files: {', '.join(copied)}")
    print("Done.")


if __name__ == "__main__":
    main()
