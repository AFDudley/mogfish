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

## Open Questions

1. **Constrained generation speed.** 75 seconds per constrained call on
   CPU is too slow for interactive classification. Options: free-form +
   post-hoc parsing, smaller schema, or accept it for batch-only use.

2. **Fused model quality.** Will the fine-tuned model fix the flag
   extraction failure? Unknown until we fuse and test.

3. **Memory footprint.** The debug build used 2.1GB RSS. The release
   build RSS was not measured. Need to verify the <1GB target is met.
