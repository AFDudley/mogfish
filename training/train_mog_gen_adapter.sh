#!/bin/bash
# Train Mog generation LoRA adapter on marks (M4 Pro, 64GB)
#
# Uses mog_generation_with_spec_train.jsonl which includes the full
# Mog language reference (context.md) in the instruction field.
# max_seq_length=4096 to fit spec (~3K tokens) + output.
#
# Output: ~/mogfish-adapters/mog-gen-with-spec-v1/

set -euo pipefail

BASE_MODEL="unsloth/gemma-3-1b-it"
TRAIN_DATA="training/mog_generation_with_spec_train.jsonl"
EVAL_DATA="training/mog_generation_with_spec_eval.jsonl"
ADAPTER_OUT="$HOME/mogfish-adapters/mog-gen-with-spec-v1"

echo "=== Mog Generation Adapter Training ==="
echo "Base model: $BASE_MODEL"
echo "Train data: $TRAIN_DATA ($(wc -l < "$TRAIN_DATA") examples)"
echo "Eval data:  $EVAL_DATA ($(wc -l < "$EVAL_DATA") examples)"
echo "Output:     $ADAPTER_OUT"
echo "max_seq_length: 4096"
echo ""

mlx_lm.lora \
    --model "$BASE_MODEL" \
    --train \
    --data . \
    --train-file "$TRAIN_DATA" \
    --valid-file "$EVAL_DATA" \
    --adapter-path "$ADAPTER_OUT" \
    --lora-rank 16 \
    --lora-alpha 32 \
    --batch-size 4 \
    --learning-rate 1e-5 \
    --max-seq-length 4096 \
    --iters 500 \
    --val-batches 25 \
    --steps-per-eval 50 \
    --steps-per-report 10 \
    --save-every 100

echo ""
echo "=== Training complete ==="
echo "Adapter at: $ADAPTER_OUT"
echo ""
echo "To fuse:"
echo "  python3 training/fuse_lora.py $BASE_MODEL $ADAPTER_OUT ~/mogfish-model/gemma3-1b-mogfish-mog-gen-v1"
echo ""
echo "To test:"
echo "  MOGFISH_MODEL_PATH=~/mogfish-model/gemma3-1b-mogfish-mog-gen-v1 MOGFISH_USE_GPU=0 \\"
echo "    mogfish-annotate generate --intent 'list files bigger than 10mb' --engine mistralrs"
