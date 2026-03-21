#!/usr/bin/env bash
set -euo pipefail

# Pass 2: Mog generation LoRA training
# Base: Pass 1 fused model (gemma3-1b-mogfish-v1)
# Output: ~/mogfish-adapters/pass2-mog-gen/

DATA_DIR=~/mogfish-training/data
MODEL=~/mogfish-model/gemma3-1b-mogfish-v1
ADAPTER_OUT=~/mogfish-adapters/pass2-mog-gen

LORA_CONFIG=~/mogfish-training/lora_config.yaml

mkdir -p "$DATA_DIR" "$ADAPTER_OUT"

# Write LoRA config (rank 16, alpha 32, same as Pass 1)
cat > "$LORA_CONFIG" <<'YAML'
lora_parameters:
  rank: 16
  alpha: 32
  dropout: 0.05
  scale: 2.0
YAML

# Convert instruction/input/output JSONL to mlx-lm chat messages format
python3 -c "
import json, sys

for split in ['train', 'valid']:
    src = 'mog_generation_train.jsonl' if split == 'train' else 'mog_generation_eval.jsonl'
    dst = f'$DATA_DIR/{split}.jsonl'
    with open(src) as fin, open(dst, 'w') as fout:
        for line in fin:
            rec = json.loads(line)
            messages = [
                {'role': 'user', 'content': rec['instruction'] + '\n' + rec['input']},
                {'role': 'assistant', 'content': rec['output']}
            ]
            fout.write(json.dumps({'messages': messages}) + '\n')
    count = sum(1 for _ in open(dst))
    print(f'{split}: {count} examples written to {dst}')
"

echo "Starting LoRA training..."
echo "Model: $MODEL"
echo "Adapter output: $ADAPTER_OUT"

# LoRA training: rank 16, alpha 32
# 1666 train / batch 4 / grad_accum 4 = effective batch 16
# ~104 steps/epoch, 3 epochs = ~312 steps
# Val every 52 steps (~2x per epoch)
python3 -m mlx_lm.lora \
    --model "$MODEL" \
    --data "$DATA_DIR" \
    --train \
    --adapter-path "$ADAPTER_OUT" \
    -c "$LORA_CONFIG" \
    --num-layers 18 \
    --batch-size 4 \
    --grad-accumulation-steps 4 \
    --grad-checkpoint \
    --mask-prompt \
    --iters 312 \
    --steps-per-eval 52 \
    --steps-per-report 10 \
    --val-batches 22 \
    --learning-rate 1e-4 \
    --save-every 104

echo "Training complete. Adapter saved to $ADAPTER_OUT"
