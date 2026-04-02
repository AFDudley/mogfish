# Lab Notebook: Mogfish Inference Validation

Base model: Gemma 3 1B-IT (HF safetensors, `unsloth/gemma-3-1b-it`).
Engine: forked mistral.rs (`AFDudley/mistral.rs`, rev `3cd629537`), ISQ Q4K.
Machine: kelce (Ryzen 9 7950X, 192GB RAM, RTX 5070 12GB).

## Experiment Log

### 1. Smoke test — debug build, CPU (2026-03-29)

**Hypothesis:** The base model loads and runs inference on CPU through the
mistral.rs engine wrapper.

**Result: INCONCLUSIVE — debug build too slow to complete.**

- Model loaded successfully: ISQ Q4K applied on 32 threads, all 26 layers
  on CPU, dummy run completed in 6.6 seconds.
- First real inference call (constrained JSON, `annotate` endpoint) ran for
  30+ minutes / 5+ hours CPU time without producing output.
- Process used 2.1GB RSS, 1100% CPU (11 cores).
- Killed manually after 27 minutes wall time.
- Test binary was `target/debug/deps/acceptance-*` — unoptimized.

**Conclusion:** Debug builds are unusable for CPU inference. The hot loops
in mistral.rs (matmul, attention, quantized kernels) need compiler
optimization. All subsequent tests must use `--release`.

### 2. Smoke test — release build, free-form generation, CPU (2026-03-29)

**Hypothesis:** Release build resolves the performance issue. Free-form
generation (no JSON schema constraint) completes in under 2 minutes.

**Result: PASS — 11.3 seconds total.**

- `generate_mog_returns_nonempty_script` test.
- Model load + ISQ: ~6 seconds.
- Dummy run: 0.19 seconds (vs 6.6s in debug — 35x faster).
- Free-form inference: ~3 seconds.
- Test passed (non-empty script output).

**Conclusion:** Release mode is required. Free-form generation on CPU is
fast enough for production use (~3 seconds per generation).

### 3. Smoke test — release build, constrained generation, CPU (2026-03-29)

**Hypothesis:** JSON schema constrained generation is also viable on CPU.

**Result: PASS — 82.7 seconds for classify.**

- `classify_returns_valid_classification` test.
- Constrained generation took ~75 seconds (vs ~3 seconds for free-form).
- Grammar FSM over 262K vocab at each token is the bottleneck.
- Output: `{"category": "KnownCommand", "confidence": 0.9, "command": "name"}`
  — the base model echoed the system prompt example verbatim. Structurally
  valid but semantically wrong (expected for un-fine-tuned base).

**Conclusion:** Constrained generation works but is ~25x slower than
free-form. 75 seconds per classification is too slow for interactive use
but acceptable for batch annotation (which runs in the background). The
classify endpoint may need to use free-form generation with post-hoc
JSON parsing instead of grammar constraints, or a smaller constrained
schema.

### 4. Full acceptance suite — release build, base model, CPU (2026-03-29)

**Hypothesis:** All 4 acceptance tests pass with the un-fine-tuned base model.

**Result: 3 PASS, 1 FAIL — 236 seconds total.**

| Test | Result | Notes |
|------|--------|-------|
| `generate_mog` (free-form) | PASS | Non-empty script output |
| `annotate` (simple input) | PASS | Valid JSON: description + intents + empty flags |
| `classify` (constrained) | PASS | Echoed system prompt example (base model, expected) |
| `annotate_flag_docs` (complex input) | FAIL | Generated description + intents, then filled remaining tokens with newlines. Never produced `flags` array. JSON truncated at 1024 tokens. |

**Details on the failure:**
- Input: rsync help text with `-v`, `-a`, `-n` flags.
- Model produced valid description and intents array.
- After the intents array, model emitted ~400 newline characters until
  hitting the 1024 token `max_len` limit.
- JSON object was never closed — missing `flags` array and closing brace.
- `serde_json` parse failed: "EOF while parsing an object at line 468".
- The JSON schema constraint ensured each token was individually valid
  but couldn't force the model to complete the structure within budget.

**Conclusion:** The engine works. 3/4 tests pass with the base model.
The flag extraction failure is a model quality issue — the un-fine-tuned
base doesn't know to produce the `flags` field. Fine-tuning should fix
this. The engine, loading, structured output, and trait plumbing are all
validated.

### 5. Fused model availability check (2026-03-29)

**Hypothesis:** A fused 1B fine-tuned model exists on marks ready for
deployment.

**Result: NO FUSED 1B MODEL EXISTS ANYWHERE.**

- marks has only 12B artifacts:
  - `~/mogfish-model/gemma3-12b-mogfish-v1/` (18GB safetensors)
  - `~/mogfish-model/gemma3-12b-q4k/` (empty/minimal)
  - `~/mogfish-adapters/12b-combined-v1/` (adapter only)
- kelce has 1B LoRA adapters at `/home/rix/mogfish-adapters/combined-v1/`
  (MLX-format, 7 checkpoints + final, rank 16, alpha 32, scale 2.0).
- kelce has the base model at `/home/rix/mogfish-model/gemma3-1b-it/`.
- Multiple GGUF files exist on kelce but are from the old llama-cpp-4
  era and not loadable by the current `from_hf_model()` path.

**Conclusion:** The training pipeline produced adapters but never fused
them into a standalone HF safetensors model. This is a gap — the next
step is fusing the `combined-v1` adapter into the base model to produce
a deployable artifact.

### 6. Fuse 1B LoRA adapter and test (2026-03-29)

**Hypothesis:** Fusing the `combined-v1` LoRA adapter into the base model
produces a model that fixes the flag extraction failure and generates real
classifications.

**Fusion:** Wrote `training/fuse_lora.py`. MLX LoRA orientation is
`(a @ b).T` where a=[out, rank], b=[rank, in]. 182/182 pairs fused,
scale=2.0, output in bfloat16. Result at
`/home/rix/mogfish-model/gemma3-1b-mogfish-combined-v1/`.

**Result: 3 PASS, 1 FAIL — 239 seconds total. Different failure than base.**

| Test | Base model | Fused model |
|------|-----------|-------------|
| `generate_mog` | pass | pass |
| `classify` | pass (echoed example: `"command": "name"`) | **pass (real: `"command": "git"`, confidence 1.0)** |
| `annotate_flag_docs` (rsync) | **FAIL** (newlines, no flags) | **PASS (extracted -v, -a, -n correctly)** |
| `annotate` (git) | pass | **FAIL (repetition loop: "git push to remote repository" × ~100)** |

**Details on the flag extraction success:**
```json
{"description": "Synchronize files and directories between two or more locations",
 "intents": ["sync files", "copy files between computers", "backup data",
             "synchronize directories", "move files to different locations"],
 "flags": [{"flag": "-v/--verbose", "description": "increase verbosity"},
           {"flag": "-a/--archive", "description": "archive mode"},
           {"flag": "-n/--dry-run", "description": "perform a trial run with no changes made"}]}
```
Quality is good — description is accurate, intents are relevant, all 3 flags
extracted with correct descriptions.

**Details on the git annotation failure:**
- Description correct: "Manage Git repositories and track changes"
- Intents array entered repetition loop: "git push to remote repository"
  repeated ~100 times until hitting 1024 token `max_len`.
- JSON truncated mid-string, never closed.
- The JSON schema constraint ensures valid tokens but doesn't limit array
  length — the grammar allows infinite array elements.

**Conclusion:** Fine-tuning works. The fused model produces real
classifications and extracts flags correctly. The repetition loop is a
constrained generation issue, not a model quality issue — the schema
needs `maxItems` on the intents array, or `max_len` needs to be lower,
or a repetition penalty is needed.

### 7. Fix repetition: maxItems + DRY + max_len (2026-03-29)

**Hypothesis:** Adding `maxItems` to the JSON schema, DRY repetition
penalty, and reducing `max_len` from 1024 to 512 will prevent the
intents array repetition loop.

**Changes:**
- `annotation_schema()`: added `"maxItems": 10` on intents, `"maxItems": 30` on flags
- `chat_constrained()`: added `DrySamplingParams::new_with_defaults(0.8, ...)`
- `chat_constrained()`: reduced `set_sampler_max_len` from 1024 to 512

**Result: 3 PASS, 1 FAIL — 126 seconds (down from 241s).**

The `maxItems` constraint works — intents array caps at 10 items with
unique entries (DRY prevents duplicates). But the git annotation still
pads with whitespace after 10 intents instead of transitioning to the
`flags` field. The model doesn't know to close the array and move on
for this specific short input.

The rsync annotation continues to pass perfectly every run — correct
description, 5 intents, 3 flags with accurate descriptions.

| Test | maxItems only | maxItems + DRY | + max_len 512 |
|------|-------------|----------------|---------------|
| rsync annotate | pass | pass | pass |
| git annotate | fail (whitespace) | fail (whitespace, unique intents) | fail (less whitespace, 126s vs 241s) |
| classify | pass | pass | pass |
| generate_mog | pass | pass | pass |

**Conclusion:** The engine tuning (`maxItems` + DRY + shorter `max_len`)
is correct and standard practice per prior art (Outlines #690, llguidance).
The remaining git annotation failure is model quality — the model wasn't
trained on short help text inputs and doesn't learn to transition between
JSON fields. This needs better training data, not more engine parameters.

### 8. GPU inference failure — RTX 5070 Blackwell (2026-04-01)

**Hypothesis:** GPU inference with `MOGFISH_USE_GPU=1` will be faster
than CPU for batch annotation data generation.

**Result: FAIL — shape mismatch in PagedAttention matmul.**

```
ERROR mistralrs_core::engine: step - Model failed with error:
  shape mismatch in matmul, lhs: [2, 4, 23, 256], rhs: [1, 4, 256, 1262]
```

First few files failed with "A weight is negative, too large or not a
valid number", then the engine panicked and all remaining files got
"channel error: channel closed".

The batch dimension mismatch (2 vs 1) suggests PagedAttention is
constructing KV cache tensors with the wrong batch size for this GPU
architecture (RTX 5070, sm_120 Blackwell). The forked mistral.rs
(rev `3cd629537`) predates Blackwell — the PagedAttention CUDA kernels
likely don't handle sm_120 compute capability correctly.

### 8b. GPU without PagedAttention — still fails (2026-04-01)

Added `from_hf_model_gpu_no_pa()` to bypass PagedAttention and test
GPU with standard attention. Different error:

```
CUDA_ERROR_DEINITIALIZED, "<Failure when calling cuGetErrorString()>"
inference error: A weight is negative, too large or not a valid number
```

This confirms the problem is not PagedAttention — it's the Q4K
dequantization CUDA kernels. They don't handle sm_120 (Blackwell,
compute capability 12.0). The forked mistral.rs rev `3cd629537`
predates Blackwell support.

**Conclusion:** GPU inference is broken at the kernel level for
Blackwell GPUs. Fix requires updating the mistral.rs fork to a version
with sm_120 support. CPU inference works fine for all current needs.

### 9. Training data expansion via exophial (2026-03-30 — 2026-04-01)

Scraped 941 fish completion files from GitHub. Dispatched 3 exophial
tasks for annotation. Two succeeded, one failed (DPO task couldn't
access host model from worktree — see feat-agentfs-worktree-isolation
pebble in exophial repo).

| Source | Records |
|--------|---------|
| Original annotation_train.jsonl | 1,010 |
| Scraped annotations (exophial task) | 1,056 |
| Short-input augmented (exophial task) | 680 |
| DPO pairs (running locally) | pending |

Merged dataset: 1,736 unique examples, 3,509 train / 185 eval after
3x oversampling of short inputs (<500 chars).

### 10. Bonsai-8B 1-bit model evaluation attempt (2026-04-01)

**Hypothesis:** PrismML's Bonsai-8B (1.15GB, Qwen3 architecture) can
be loaded through the mogfish engine for quality comparison against
Gemma 1B.

**Result: BLOCKED — custom weight format incompatible with mistral.rs.**

Downloaded both GGUF (1.16GB) and MLX (1.28GB safetensors) variants.
The MLX variant reports `hidden_size: 4096` in config.json but the
actual `embed_tokens.weight` shape is `[151669, 128]` — weights are
packed 32 1-bit values per element (4096/32 = 128). mistral.rs expects
unpacked weights and fails with shape mismatch.

The model requires a runtime that understands 1-bit packed weights.
Options: PrismML's own inference code, QVAC Fabric (Tether's BitNet
runtime), or adding 1-bit unpacking to mistral.rs/candle.

**Conclusion:** Can't evaluate Bonsai-8B through our current engine.
Testing requires integrating a 1-bit inference backend, which is a
significant effort. The model exists and is downloadable but isn't
plug-compatible with the HF safetensors ecosystem.

### 11. Expanded dataset retraining (2026-04-01)

**Hypothesis:** Retraining on 3,509 examples (3.5x original, with 3x
oversampling of short inputs) fixes the git annotation failure.

**Training:** marks (M4 Pro, 64GB), mlx-lm LoRA, rank 16, alpha 32,
877 iterations, batch 4, lr 1e-5, max_seq_length 2048.

**Loss curve:**
- Iter 1: val 3.051
- Iter 10: train 2.472
- Iter 50: train 1.431
- Iter 877: train 0.873, val 1.043

**Result: 4/4 acceptance tests pass on both GPU and CPU.**

| Test | GPU (Blackwell) | CPU (Ryzen 9 7950X) |
|------|----------------|---------------------|
| rsync annotate (constrained) | pass | pass, ~44s inference |
| git annotate (constrained) | pass | pass, ~41s inference |
| classify (constrained) | pass | pass, ~42s inference |
| generate_mog (free-form) | pass | pass, ~4s inference |
| **Total (incl model load)** | **23.6s** | **138.6s** |

The git annotation that previously failed now produces complete JSON:
description + 5 intents + 10–15 flags, no whitespace padding, no
repetition loops.

**Conclusion:** The expanded training dataset fixed the short-input
failure. The model generalizes correctly to minimal help text inputs.

### 12. CPU memory footprint (2026-04-02)

**Hypothesis:** The model fits in <1GB RAM on CPU (deployment target
for lightweight VMs).

**Result: FAIL — 2,115 MB RSS.**

The peak memory is ~2.1GB because ISQ loads the full BF16 model
(~1.9GB) into memory, quantizes to Q4K (~700MB), and briefly holds
both copies. After quantization completes, resident memory would drop
to ~700MB + KV cache + runtime, but the peak allocation exceeds the
target.

**Fix:** Load a pre-quantized model (UQFF or pre-quantized safetensors)
to skip the BF16 intermediate. Peak memory would then be ~700MB +
overhead, within the <1GB target.

### 13. Per-test CPU timing (2026-04-02)

Ran each test individually to isolate inference time from model load
(~8s on CPU).

| Test | Wall time (incl load) | Inference est. | Type |
|------|----------------------|----------------|------|
| rsync annotate | 52s | ~44s | JSON schema constrained |
| git annotate | 49s | ~41s | JSON schema constrained |
| classify | 50s | ~42s | JSON schema constrained |
| generate_mog | 12s | ~4s | Free-form |

Constrained generation is ~10x slower than free-form on CPU due to
grammar FSM evaluation over the 262K token vocabulary at each step.
For interactive classification, free-form + post-hoc JSON parsing
would give ~4s latency vs ~42s with grammar constraints.

## Open Questions

1. **Constrained generation speed on CPU.** ~42s per constrained call
   is too slow for interactive use. Free-form is ~4s. Options:
   free-form + post-hoc JSON parse for interactive paths, grammar
   constraints only for batch annotation.

2. **Memory footprint.** 2.1GB peak RSS due to ISQ BF16→Q4K
   conversion. Need pre-quantized model format (UQFF or pre-quantized
   safetensors) to hit <1GB target.

3. **Pre-quantized model packaging.** The `create-uqff` binary exists
   in the engine crate. Need to run it against the fused expanded-v1
   model and test loading via `from_uqff()` on CPU.
