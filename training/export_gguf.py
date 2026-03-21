"""Merge LoRA adapter into base weights and export to GGUF.

After Pass 1 (or after all passes are merged), this script:
1. Loads the base model + LoRA adapter
2. Merges adapter weights into base model
3. Saves merged model in HF format
4. Calls llama.cpp's convert script to produce Q4_K_M GGUF
"""

import os
import subprocess
import sys
from pathlib import Path

from unsloth import FastLanguageModel

ADAPTER_DIR = Path(os.path.expanduser("~/mogfish-adapters/pass1-annotator"))
MERGED_DIR = Path(os.path.expanduser("~/mogfish-model/gemma3-1b-mogfish-v1"))
GGUF_PATH = Path(os.path.expanduser("~/mogfish-model/gemma3-1b-mogfish-v1.gguf"))
MAX_SEQ_LENGTH = 4096


def main():
    print("Loading model with adapter...")
    model, tokenizer = FastLanguageModel.from_pretrained(
        model_name=str(ADAPTER_DIR),
        max_seq_length=MAX_SEQ_LENGTH,
        load_in_4bit=True,
    )

    print(f"Merging and saving to {MERGED_DIR}...")
    MERGED_DIR.mkdir(parents=True, exist_ok=True)
    model.save_pretrained_merged(
        str(MERGED_DIR),
        tokenizer,
        save_method="merged_16bit",
    )

    print("Converting to GGUF Q4_K_M...")
    # unsloth includes llama.cpp conversion utilities
    # Try unsloth's built-in GGUF export first
    try:
        model.save_pretrained_gguf(
            str(GGUF_PATH.parent),
            tokenizer,
            quantization_method="q4_k_m",
        )
        print(f"GGUF saved to {GGUF_PATH.parent}")
    except Exception as e:
        print(f"Unsloth GGUF export failed: {e}")
        print("Falling back to llama.cpp convert script...")

        # Find convert script
        convert_script = None
        for candidate in [
            Path.home() / "llama.cpp" / "convert_hf_to_gguf.py",
            Path("/usr/local/bin/convert_hf_to_gguf.py"),
        ]:
            if candidate.exists():
                convert_script = candidate
                break

        if convert_script is None:
            print("ERROR: No GGUF converter found.", file=sys.stderr)
            print("Install llama.cpp or use unsloth's built-in export.", file=sys.stderr)
            print(f"Merged HF model is at {MERGED_DIR}", file=sys.stderr)
            sys.exit(1)

        subprocess.run(
            [
                sys.executable, str(convert_script),
                str(MERGED_DIR),
                "--outtype", "q4_k_m",
                "--outfile", str(GGUF_PATH),
            ],
            check=True,
        )

    # Report file size
    gguf_files = list(GGUF_PATH.parent.glob("*.gguf"))
    for gf in gguf_files:
        size_mb = gf.stat().st_size / (1024 * 1024)
        print(f"  {gf.name}: {size_mb:.1f} MB")

    print("Export complete.")


if __name__ == "__main__":
    main()
