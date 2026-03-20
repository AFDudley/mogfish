# Mogfish Model Training

This document describes how to train the mogfish inference model. It assumes familiarity with the mogfish architecture described in mogfish.md. The model being trained is a fine-tuned variant of `gemma3:1b-it-qat` that handles three tasks: classifying shell input, generating Mog scripts from natural language intent, and annotating command documentation with semantic descriptions. All training runs on kelce, a Linux machine running Ubuntu with an RTX 5070 (12GB VRAM), 192GB RAM, and an AMD Ryzen 9 7950X. The Mac Mini (M4 Pro, 64GB) serves as the daily inference machine and fallback training environment.

---

## Environment Setup

### Verifying the CUDA Stack

The RTX 5070 is a Blackwell-generation card and requires CUDA 12.8 or later. Ubuntu's packaged CUDA lags behind NVIDIA's own releases, so install directly from NVIDIA's repository rather than apt.

```bash
# Check existing driver and CUDA versions
nvidia-smi
nvcc --version

# You need driver >= 570 and CUDA >= 12.8
# If not, install from NVIDIA's apt repository
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update
sudo apt install cuda-toolkit-12-8
```

After installing, verify with `nvcc --version` and confirm `nvidia-smi` shows the correct driver. Reboot if the driver version changed.

### Python Environment

Use a dedicated virtual environment for the training pipeline. Python 3.11 is the safest choice for compatibility with the training tooling.

```bash
python3.11 -m venv ~/mogfish-train
source ~/mogfish-train/bin/activate

# Install PyTorch nightly built against CUDA 12.8
pip install --pre torch torchvision torchaudio \
  --index-url https://download.pytorch.org/whl/nightly/cu128

# Install Unsloth from source for Blackwell support
pip install "unsloth[cu128] @ git+https://github.com/unslothai/unsloth.git"

# Supporting libraries
pip install transformers datasets peft trl accelerate bitsandbytes
pip install anthropic  # for the synthetic translation pass
```

Verify the GPU is visible to PyTorch:

```python
import torch
print(torch.cuda.is_available())        # True
print(torch.cuda.get_device_name(0))    # NVIDIA GeForce RTX 5070
print(torch.cuda.get_device_properties(0).total_memory // 1024**3)  # ~12
```

### Mac Mini Fallback

If Blackwell CUDA issues arise before the Linux stack is stable, the Mac Mini handles the first training pass using MLX. Install the MLX training tooling:

```bash
pip install mlx-lm
```

`mlx-lm` supports Gemma 3, LoRA fine-tuning, and runs natively on Apple Silicon using the full 64GB unified memory pool as effective VRAM. The training commands differ from Unsloth but the data format is identical, so your prepared datasets work on either machine without modification.

---

## Stage 1: Data Collection and Preparation

All data preparation runs on kelce. The 192GB RAM means the entire pipeline — large model API calls, compiler validation, dataset assembly — stays in memory without touching disk unnecessarily.

### Extracting Training Data from Claude Sessions

Your Claude Code and Claude.ai session transcripts are the primary data source. Write a parser that walks the transcript format and extracts three record types.

**Shell operation records** come from Claude Code tool calls where a shell command was executed. Each record captures the natural language context that led to the tool call, the command or script that was generated, and the outcome (success, failure, retry). These become your (intent, script) training pairs after the Mog translation pass.

**Correction records** come from sequences where Claude generated something, it failed or was wrong, and a corrected version followed. These are (intent, rejected output, preferred output) triples for the DPO stage later. Flag them now even though you won't use them until Stage 4.

**Intent description records** come from prose in your conversations that describes shell tasks — "find all Python files modified this week", "show me what's using port 8080", anything that maps natural language to a filesystem or process operation. These feed both the classifier and the annotator training sets.

Export your session history from the Claude.ai interface or via the API if you have programmatic access. Store everything as raw JSON before parsing so you can re-run the parser as its format evolves.

### Synthetic Mog Translation Pass

Your extracted shell operation records contain bash, not Mog. This pass converts them.

For each (intent, bash) pair, call the Anthropic API with the Mog language spec in context and ask for the equivalent Mog script. A prompt structure that works well:

```
You are translating bash shell commands into equivalent Mog scripts.
Mog is a sandboxed scripting language. Here is the complete language spec:

[insert contents of lang_spec.md from the Mog repository]

Translate the following bash command into a valid Mog script.
Declare all required capabilities in a comment header.
The natural language intent that produced this command was: {intent}
The bash command is: {bash}

Return only the Mog script, no explanation.
```

Run every output through the Mog compiler:

```bash
mogc --check script.mog
```

Keep only the pairs where the compiler exits cleanly. Discard the rest. Do not attempt to fix failed translations manually at this stage — the volume of discards tells you something about which bash patterns don't translate cleanly to Mog, and that information is useful later when you are debugging model output.

Expect to keep roughly 60-70% of your pairs on the first pass. After filtering you should have somewhere between 2,000 and 5,000 validated (intent, context, Mog) training examples depending on your session history volume.

Format each example as JSONL in the instruction-tuning format:

```json
{
  "instruction": "Find all Python files modified in the last 7 days",
  "input": "cwd: /home/user/projects/myapp\ninstalled: fd 10.1.0, find (GNU findutils) 4.9.0",
  "output": "# requires: process\n\nfn main() {\n  result := await process.exec(\"fd\", [\"--extension\", \"py\", \"--changed-within\", \"7d\"]);\n  print(result.stdout);\n}"
}
```

The `input` field carries the grounding context — current directory and relevant installed tools. This teaches the model to condition on local environment state rather than generating generic scripts that may not match what is actually installed.

### Man Page Annotation Pass

Collect man pages and `--help` output for the tools in your PATH:

```bash
# Dump help output for everything in PATH
for cmd in $(ls /usr/bin /usr/local/bin ~/.local/bin 2>/dev/null | sort -u); do
  $cmd --help 2>&1 | head -50 > /tmp/help/$cmd.txt 2>/dev/null
  man $cmd 2>/dev/null | col -bx > /tmp/manpages/$cmd.txt 2>/dev/null
done
```

Run each through a large model to produce the annotation format your `.fish` completion files expect. For each tool, generate: a one-sentence description, three to five natural language intent phrases a user might type to invoke it, and a list of its most commonly used flags in plain English. Spot-check a sample of the output manually — annotation quality matters more here than volume.

Format as JSONL:

```json
{
  "instruction": "Generate a mogfish annotation for this command documentation",
  "input": "[man page or --help output]",
  "output": "# mog-description: recursively search file contents for a pattern\n# mog-intent: search files for text, find string in files, grep recursively, look for pattern in codebase\n# mog-flags: -r recursive, -n line numbers, -i case insensitive, -l files only"
}
```

### Classifier Examples

Generate a balanced three-class dataset.

**Known command examples** come directly from your shell history. Run `history` and take the raw command strings. Strip arguments to get the base command patterns, then include some with common arguments to cover the realistic input distribution. Label these `known_command`.

**Natural language intent examples** come from your session transcripts — the descriptions you typed to Claude, plus synthetic variations generated by asking a large model to paraphrase each one several times. Label these `natural_language`.

**Cached skill invocation examples** look like parameterised skill names. Generate these synthetically from your Mog training set — take the skill name you assigned each cached script plus realistic argument variations. Label these `cached_skill`.

Format as JSONL:

```json
{"instruction": "Classify this shell input", "input": "git push origin main", "output": "known_command"}
{"instruction": "Classify this shell input", "input": "find all python files modified this week", "output": "natural_language"}
{"instruction": "Classify this shell input", "input": "find-modified-python --days 7", "output": "cached_skill"}
```

Aim for roughly equal class balance — around 1,500 examples per class.

### Final Dataset Layout

```
~/mogfish-data/
  mog_generation_train.jsonl    # ~4,000 validated (intent, context, Mog) pairs
  mog_generation_eval.jsonl     # ~200 held-out pairs (set aside before training)
  annotation_train.jsonl        # ~800 man page annotation pairs
  annotation_eval.jsonl         # ~100 held-out annotation pairs
  classifier_train.jsonl        # ~4,500 classifier examples
  classifier_eval.jsonl         # ~500 held-out classifier examples
  dpo_pairs.jsonl               # empty for now, populated during Stage 3
```

Hold out 5% of each dataset as an evaluation set before any training begins. These examples are never shown to the model during training and are used only for evaluation.

---

## Stage 2: Fine-Tuning

Three sequential passes, each building on the last. All passes use LoRA — you are not updating the full model weights, only small adapter matrices injected into the attention layers. The base model weights are frozen throughout.

### LoRA Configuration

A rank of 16 fits comfortably within 12GB VRAM for a 1B model with reasonable batch sizes. If you hit memory pressure, reduce batch size before reducing rank. The alpha parameter is typically set to twice the rank.

```python
from peft import LoraConfig

lora_config = LoraConfig(
    r=16,
    lora_alpha=32,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj",
                    "gate_proj", "up_proj", "down_proj"],
    lora_dropout=0.05,
    bias="none",
    task_type="CAUSAL_LM"
)
```

### Pass 1: Annotator Fine-Tuning

Load the base model and train on the annotation dataset first. This is the easiest task and establishes the model's vocabulary around command line tooling before you ask it to generate code.

```python
from unsloth import FastLanguageModel
import torch

model, tokenizer = FastLanguageModel.from_pretrained(
    model_name="google/gemma-3-1b-it",
    max_seq_length=4096,
    load_in_4bit=True,  # QAT variant
)

model = FastLanguageModel.get_peft_model(model, lora_config)

# Train on annotation_train.jsonl
# 2-3 epochs, learning rate 2e-4, batch size 4 with gradient accumulation 4
```

After training, evaluate by running the model on `annotation_eval.jsonl` and manually reviewing a sample of twenty outputs. You are checking that descriptions are accurate, intent phrases are natural, and the format is consistent. Save the LoRA adapter to `~/mogfish-adapters/pass1-annotator/`.

### Pass 2: Mog Generation Fine-Tuning

Continue from the Pass 1 checkpoint. Load the base model with the Pass 1 adapter merged, then attach a fresh LoRA configuration for this pass.

Train on `mog_generation_train.jsonl`. This pass requires the most epochs and produces the most important capability, so invest time here. After each epoch run the evaluation set through the model and pipe every output to `mogc --check`. Track the compilation pass rate.

```bash
# Evaluation script run after each epoch
python eval_mog.py \
  --model ~/mogfish-adapters/pass2-mog-gen/ \
  --eval ~/mogfish-data/mog_generation_eval.jsonl \
  --compiler mogc
# Reports: compile_pass_rate, avg_script_length, capability_declaration_rate
```

You want the compile pass rate above 90% before proceeding to Pass 3. If it stalls lower than that, examine the failure cases. They will cluster — typically around async syntax, capability declarations, or specific control flow patterns. Add ten to twenty targeted training examples for each failure cluster and run another epoch.

Save the adapter to `~/mogfish-adapters/pass2-mog-gen/`.

### Pass 3: Classifier Fine-Tuning

Continue from the merged Pass 1 + Pass 2 checkpoint. Train on `classifier_train.jsonl` for 1-2 epochs.

Evaluation here is straightforward — compute accuracy on `classifier_eval.jsonl` and report a confusion matrix. You are most concerned about the natural_language / cached_skill boundary, since confusing these two is the failure mode most visible to you as a user. Aim for above 95% overall accuracy with no class below 92%.

Save the adapter to `~/mogfish-adapters/pass3-classifier/`.

### Merging and Exporting

After all three passes, merge the LoRA adapters into the base model weights to produce a single deployable model file. With three sequential passes you will have merged incrementally at each stage — the final merge produces a clean model with no adapter overhead at inference time.

```python
model.save_pretrained_merged(
    "~/mogfish-model/gemma3-1b-mogfish-v1",
    tokenizer,
    save_method="merged_16bit"
)
```

Convert to GGUF format for deployment via mistral.rs:

```bash
python convert_hf_to_gguf.py ~/mogfish-model/gemma3-1b-mogfish-v1 \
  --outtype q4_k_m \
  --outfile ~/mogfish-model/gemma3-1b-mogfish-v1.gguf
```

Copy the GGUF to the Mac Mini for deployment. The model should sit around 800MB-1GB on disk at Q4_K_M quantisation.

---

## Stage 3: Integration and Live Feedback Collection

Before doing any more training, deploy the model and use it as your daily shell. This is where you find out what actually goes wrong in practice.

### Deploying on the Mac Mini

Load the model via mistral.rs. The M4 Pro with 64GB unified memory will keep the entire model resident with room to spare. Inference latency on a 1B model for a typical Mog generation request — a few hundred tokens of context, fifty to one hundred tokens of output — should be under two seconds on M4 Pro.

```bash
mistralrs run --model ~/mogfish-model/gemma3-1b-mogfish-v1.gguf \
  --arch gemma3 \
  --prefix-cache-size 512  # cache the Mog spec prefix
```

### Structured Feedback Logging

Every mogfish interaction writes a structured record to a local log file. Implement this logging in the mogfish shell hook from the start — retrofitting it later means losing the early interactions which are often the most informative.

Each log record contains: a timestamp, the raw input string, the classifier decision, the generated Mog script if any, the compiler result, the runtime outcome if the script was executed, and an outcome flag (pending, success, rejected, corrected).

The outcome flag is updated asynchronously. When you run a generated script successfully the flag is set to success. When you reject a script and rephrase your intent the original record is marked rejected and linked to the follow-up record. When you edit a generated script before running it the edited version is stored alongside the original.

After a few weeks of use you will have a feedback log with hundreds of structured interaction records. The compiler failures and rejection pairs are your most valuable data.

---

## Stage 4: DPO Refinement

Direct Preference Optimisation trains on (preferred, rejected) output pairs for the same input. It does not require a reward model or reinforcement learning infrastructure — it is a standard fine-tuning pass with a different loss function, supported natively by the `trl` library that is already in your environment.

### Building the DPO Dataset

Extract (intent, preferred Mog, rejected Mog) triples from your feedback log. Several sources:

Compiler failures paired with the corrected version that followed. The compiler error message tells you exactly what was wrong, which makes these the highest signal examples — the preference is unambiguous and machine-verified.

Rejected scripts where you rephrased and got a better result. The second generation is the preferred output if it ran successfully.

Scripts you edited before running. The edited version is the preferred output; the raw generated version is the rejected output.

You need a few hundred clean pairs to see a meaningful improvement. Quality matters more than quantity — discard any pairs where the preference is ambiguous or where both outputs are roughly equivalent.

Format as JSONL in the TRL DPO format:

```json
{
  "prompt": "Find all Python files modified in the last 7 days\ncwd: /home/user/projects/myapp",
  "chosen": "# requires: process\n\nfn main() {\n  ..correct script..\n}",
  "rejected": "# requires: process\n\nfn main() {\n  ..incorrect script..\n}"
}
```

### Running the DPO Pass

```python
from trl import DPOTrainer, DPOConfig

dpo_config = DPOConfig(
    beta=0.1,          # controls deviation from reference model
    learning_rate=5e-5,
    num_train_epochs=1,
    per_device_train_batch_size=2,
    gradient_accumulation_steps=8,
)

trainer = DPOTrainer(
    model=model,
    ref_model=None,  # uses implicit reference via PEFT
    args=dpo_config,
    train_dataset=dpo_dataset,
    tokenizer=tokenizer,
)

trainer.train()
```

Evaluate using the same compiler pass rate metric from Stage 2, plus manual review of a held-out sample. A successful DPO pass should improve the compile pass rate and reduce the rate of plausible-looking-but-wrong scripts — the failure mode that compiler validation cannot catch.

Merge, export, and redeploy as before. Tag the model version: `gemma3-1b-mogfish-v1.1`.

### Iteration Cadence

Repeat Stage 3 and Stage 4 on a rolling basis. A few weeks of daily use, a DPO pass, redeploy, repeat. Each cycle the model gets incrementally better at your specific patterns and your specific tooling. After three or four cycles the gap between what you type and what the model generates narrows to the point where most interactions require no correction at all.

There is no fixed endpoint. The model continues improving as long as you use the shell and log interactions. The training infrastructure stays warm on kelce, ready to run a DPO pass whenever the feedback log has accumulated enough new pairs to be worth a cycle.

---

## Quick Reference: Key Paths and Commands

```
~/mogfish-train/          Python virtual environment
~/mogfish-data/           Training datasets (JSONL)
~/mogfish-adapters/       LoRA checkpoints by pass
~/mogfish-model/          Merged and exported model files
~/mogfish-logs/           Live feedback logs from shell usage

# Activate training environment
source ~/mogfish-train/bin/activate

# Check GPU
python -c "import torch; print(torch.cuda.get_device_name(0))"

# Compile-pass evaluation
python eval_mog.py --model [adapter] --eval [jsonl] --compiler mogc

# Convert to GGUF for deployment
python convert_hf_to_gguf.py [hf model dir] --outtype q4_k_m --outfile [path]
```
