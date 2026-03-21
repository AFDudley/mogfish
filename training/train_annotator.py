"""Pass 1: Annotator fine-tuning on gemma-3-1b-it.

Trains a LoRA adapter on the annotation dataset (command -> structured annotation).
This is the first pass in the mogfish training pipeline, establishing the model's
vocabulary around CLI tooling before code generation passes.

See mogfish-training.md Stage 2, Pass 1.
"""

import unsloth  # must be imported first per unsloth requirements

import json
import os
import sys
from pathlib import Path

import torch
from datasets import Dataset
from peft import LoraConfig
from trl import SFTTrainer, SFTConfig
from unsloth import FastLanguageModel

# Paths
DATA_DIR = Path(os.path.expanduser("~/mogfish-data"))
ADAPTER_DIR = Path(os.path.expanduser("~/mogfish-adapters/pass1-annotator"))

# Model config
MODEL_NAME = "google/gemma-3-1b-it"
MAX_SEQ_LENGTH = 1024

# LoRA config per training doc
LORA_CONFIG = LoraConfig(
    r=16,
    lora_alpha=32,
    target_modules=[
        "q_proj", "k_proj", "v_proj", "o_proj",
        "gate_proj", "up_proj", "down_proj",
    ],
    lora_dropout=0.05,
    bias="none",
    task_type="CAUSAL_LM",
)


def load_dataset_from_jsonl(path: Path) -> Dataset:
    """Load JSONL instruction-tuning dataset."""
    records = []
    with open(path) as f:
        for line in f:
            rec = json.loads(line)
            records.append(rec)
    return Dataset.from_list(records)


def format_prompt(example: dict) -> str:
    """Format as Gemma instruction-tuning prompt."""
    return (
        f"<start_of_turn>user\n"
        f"{example['instruction']}\n\n"
        f"{example['input']}<end_of_turn>\n"
        f"<start_of_turn>model\n"
        f"{example['output']}<end_of_turn>"
    )


def main():
    print("Loading base model...")
    model, tokenizer = FastLanguageModel.from_pretrained(
        model_name=MODEL_NAME,
        max_seq_length=MAX_SEQ_LENGTH,
        load_in_4bit=True,
    )

    print("Applying LoRA...")
    model = FastLanguageModel.get_peft_model(
        model,
        r=16,
        lora_alpha=32,
        target_modules=[
            "q_proj", "k_proj", "v_proj", "o_proj",
            "gate_proj", "up_proj", "down_proj",
        ],
        lora_dropout=0.05,
        bias="none",
    )

    # Load datasets
    train_path = DATA_DIR / "annotation_train.jsonl"
    eval_path = DATA_DIR / "annotation_eval.jsonl"

    if not train_path.exists():
        print(f"Training data not found at {train_path}", file=sys.stderr)
        print("Run prepare_annotations.py first.", file=sys.stderr)
        sys.exit(1)

    train_dataset = load_dataset_from_jsonl(train_path)
    eval_dataset = load_dataset_from_jsonl(eval_path)

    print(f"Train: {len(train_dataset)} examples, Eval: {len(eval_dataset)} examples")

    # Format prompts
    train_dataset = train_dataset.map(
        lambda x: {"text": format_prompt(x)},
        remove_columns=train_dataset.column_names,
    )
    eval_dataset = eval_dataset.map(
        lambda x: {"text": format_prompt(x)},
        remove_columns=eval_dataset.column_names,
    )

    # Training config per training doc: 2-3 epochs, lr 2e-4, batch 4, grad accum 4
    ADAPTER_DIR.mkdir(parents=True, exist_ok=True)

    training_args = SFTConfig(
        output_dir=str(ADAPTER_DIR),
        num_train_epochs=3,
        per_device_train_batch_size=1,
        gradient_accumulation_steps=16,
        learning_rate=2e-4,
        warmup_steps=10,
        logging_steps=10,
        eval_strategy="no",
        save_strategy="epoch",
        save_total_limit=2,
        fp16=not torch.cuda.is_bf16_supported(),
        bf16=torch.cuda.is_bf16_supported(),
        max_seq_length=MAX_SEQ_LENGTH,
        dataset_text_field="text",
        report_to="none",
        torch_compile=False,
    )

    trainer = SFTTrainer(
        model=model,
        tokenizer=tokenizer,
        train_dataset=train_dataset,
        eval_dataset=eval_dataset,
        args=training_args,
    )

    print("Starting training...")
    trainer.train()

    print(f"Saving adapter to {ADAPTER_DIR}...")
    model.save_pretrained(str(ADAPTER_DIR))
    tokenizer.save_pretrained(str(ADAPTER_DIR))

    print("Pass 1 complete.")


if __name__ == "__main__":
    main()
