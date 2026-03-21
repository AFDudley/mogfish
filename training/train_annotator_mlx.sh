#!/bin/bash
# Pass 1: Annotator fine-tuning using mlx-lm on Apple Silicon
# See mogfish-training.md Stage 2, Pass 1
#
# Run on marks (M4 Pro, 64GB). The 64GB unified memory pool handles
# the full 1B model + LoRA without any memory pressure.

set -euo pipefail

DATA_DIR="$HOME/mogfish-data"
ADAPTER_DIR="$HOME/mogfish-adapters/pass1-annotator"

# mlx-lm expects train.jsonl and valid.jsonl in the data directory
echo "Preparing data directory..."
cp "$DATA_DIR/annotation_train_chat.jsonl" "$DATA_DIR/train.jsonl"
cp "$DATA_DIR/annotation_eval_chat.jsonl" "$DATA_DIR/valid.jsonl"

# Create adapter output directory
mkdir -p "$ADAPTER_DIR"

# Write LoRA config (mlx-lm uses a YAML config for LoRA params)
cat > "$ADAPTER_DIR/lora_config.yaml" << 'EOF'
lora_parameters:
  rank: 16
  alpha: 32
  dropout: 0.05
  scale: 2.0
EOF

echo "Starting MLX LoRA training..."
# 1010 train examples, batch_size=4, grad_accum=4 → effective batch=16
# 1010 / 16 = ~63 steps per epoch, 3 epochs = 189 steps → use 192
mlx_lm.lora \
    --model "unsloth/gemma-3-1b-it" \
    --train \
    --data "$DATA_DIR" \
    --adapter-path "$ADAPTER_DIR" \
    --batch-size 4 \
    --grad-accumulation-steps 4 \
    --iters 192 \
    --learning-rate 2e-4 \
    --steps-per-eval 64 \
    --steps-per-report 10 \
    --max-seq-length 2048 \
    --seed 42 \
    -c "$ADAPTER_DIR/lora_config.yaml"

echo ""
echo "Training complete. Adapter saved to $ADAPTER_DIR"
echo ""
echo "To fuse adapter into base model:"
echo "  mlx_lm.fuse --model google/gemma-3-1b-it --adapter-path $ADAPTER_DIR --save-path ~/mogfish-model/gemma3-1b-mogfish-v1"
