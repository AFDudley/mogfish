# Mogfish — Project Status

Last updated: 2026-03-29

## Summary

Mogfish is approximately **80% implemented** at the component level. All
foundational crates (Layers 0–6 per the TDD plan) are built, tested, and
passing. The remaining work is integration: wiring the MCP server transport,
completing the `generate_mog` inference endpoint, deploying a trained model,
and hooking into the fish input pipeline.

## Crate Status

| Crate | Purpose | Status | Tests |
|-------|---------|--------|-------|
| mogfish-traits | InferenceEngine trait, shared types, mock | Complete | 3 |
| annotator | Core annotation logic (parse, enrich, idempotent rewrite) | Complete | 227 |
| annotator-cli | Batch + daemon CLI, engine factory, signal handling | Complete | 700+ |
| skill-cache | Skill storage, dependency invalidation, fish stub gen | Complete | 122 |
| classifier | Fast-path routing (known cmd, skill prefix, engine fallback) | Complete | 90 |
| mogfish-classify | Standalone fast-path binary (no model required) | Complete | 85 |
| mogfish-engine-mistralrs | mistral.rs backend, ISQ Q4K, structured output | Partial | 121 |
| mogfish-host | Capability dispatcher (12 tools, 80+ functions, allowlist) | Complete | 228 |
| mogfish-mcp | MCP server lib (tool listing, dispatch) | Partial | 97 |

**Total**: ~2,800 lines of mogfish code, ~2,100 lines of tests.

## What Works

- **Annotation pipeline**: Batch-annotate a directory of `.fish` completion
  files with semantic descriptions, intent lines, and flag docs. Daemon mode
  watches for new files with 1-second polling and clean SIGTERM shutdown.
- **Skill cache**: Store, retrieve, list, and invalidate cached Mog scripts.
  Fish completion stubs are generated automatically for each skill.
- **Classifier**: Fast-path classification of shell input (known commands and
  cached skills resolve without model inference). Falls back to engine for
  ambiguous input.
- **Inference engine**: Loads HF safetensors models via mistral.rs with ISQ Q4K
  quantization. Structured JSON output for annotation and classification.
  PagedAttention with 4096 token KV cache limit for 12GB VRAM cards.
- **Capability host**: 12 tool capabilities (git, grep, find, sed, awk, jq, yq,
  curl, docker, gh, cargo, python3) with allowlist enforcement. Maps `.mogdecl`
  calls to subprocess invocations.
- **MCP server (lib)**: Tool listing and dispatch for classify, store/get skill,
  and batch annotate. Library complete; standalone binary not yet wired.

## What's Incomplete

### mogfish-engine-mistralrs
- `generate_mog()` endpoint: trait signature exists, not wired to model.
- Three loading modes work (HF, local, UQFF); inference works for annotate
  and classify.

### mogfish-mcp
- `main.rs` is a stub (exits with error). No transport layer (JSON-RPC over
  stdio/HTTP/WebSocket).
- Tool implementations mostly written in lib, some incomplete.

### Fish integration
- `share/mogfish/` contains function stubs (`__mogfish_execute.fish`,
  `__mogfish_run_skill.fish`, `__mogfish_generate.fish`, enable/disable).
- Not hooked into `fish/src/reader.rs` input pipeline. Deferred until
  Layers 0–5 are production-ready.

### Daemon mode
- Polling-based (1-second loop). Native inotify/kqueue watcher not implemented.

## Training Data

All training data preparation is complete. Datasets are in `training/`.

| Dataset | Records | Purpose |
|---------|---------|---------|
| annotation_train.jsonl | ~5.0M | Pass 1: man page annotation |
| annotation_eval.jsonl | 236K | Pass 1 eval |
| mog_generation_train.jsonl | 1,754 | Pass 2: bash-to-Mog translation |
| mog_generation_eval.jsonl | 28K | Pass 2 eval |
| classification_train.jsonl | 1,176 | Pass 3: input classification |
| classification_eval.jsonl | 13K | Pass 3 eval |
| combined_ordered_train.jsonl | 3,793 | All three merged (ordered: mog gen → classification → annotation) |
| bash_commands.jsonl | 23,620 | Raw extracted commands |

**Base model**: Gemma 3 1B-IT (HF safetensors, ISQ Q4K at load time).
**Training hardware**: marks (M4 Pro, 64GB) via mlx-lm LoRA; kelce (RTX 5070,
12GB) via Unsloth.

### Training Runs Completed

Reconstructed from 32 development sessions (2026-03-20 to 2026-03-29):

| Run | What | Where | Outcome |
|-----|------|-------|---------|
| Pass 1 | Annotator fine-tune (man page → annotation) | marks, mlx-lm LoRA | Adapter saved (`pass1-annotator`) |
| Pass 2 | Mog generation fine-tune | marks, LoRA on Pass 1 base | Adapter saved (`pass2-mog-gen`) |
| Pass 3 | Classification fine-tune | marks, LoRA on Pass 2 fused | Adapter saved (`pass3-classifier`) |
| Combined | All 3 tasks, shuffled | marks, LoRA from base | Adapter saved (`combined-v1`) |
| Combined ordered | All 3 tasks, annotation last (recency bias) | marks, LoRA from base | Adapter saved (`combined-ordered-v1`) |
| 12B attempt | Gemma 3 12B, all tasks | marks, mlx-lm LoRA | Completed (525-message session) |

Bash-to-Mog translation was done via 10 parallel worker sessions
(cap_batch_001–010), each translating ~100–500 commands using per-tool
`.mogdecl` capabilities. Workers validated output with `mogc --emit-ir`.

### Training Pipeline Status

| Step | Status |
|------|--------|
| Extract bash commands from sessions | Done |
| Generate per-tool .mogdecl files | Done |
| Build host runtime (mogfish-host) | Done |
| Add Escalate classification category | Done |
| Translate bash to Mog with capabilities | Done (10 parallel workers) |
| Validate translations with mogc | Done (during translation) |
| Train Pass 1 (annotation) | Done |
| Train Pass 2 (Mog generation) | Done |
| Train Pass 3 (classification) | Done |
| Train combined model (all 3 tasks) | Done (two variants: shuffled + ordered) |
| Train 12B model | Done (experimental) |
| LoRA adapter swapping (single base + per-task adapters) | Attempted, abandoned for combined model |
| Engine migration to mistral.rs (safetensors, ISQ) | Done |
| Deploy model + collect live feedback | Not started |
| DPO refinement on feedback | Not started |

### Engine Migration History

The inference backend went through three iterations (tracked across sessions):

1. **mistral.rs** (initial) — Gemma 3 GGUF not supported at v0.7.0
2. **llama-cpp-4** — worked but hit SentencePiece `[UNK_BYTE]` artifacts,
   repetition loops without JSON schema constraints, vocab padding issues
3. **mistral.rs (forked)** — forked with text-only Gemma 3 support, native
   JSON schema constraints via `.with_constraint()`, HF tokenizer (no
   SentencePiece), ISQ Q4K at load time. This is the current backend.

LoRA adapter swapping was attempted (131-message session) to run one base GGUF
with per-task adapters, but was abandoned in favor of a single combined
fine-tuned model loaded as HF safetensors.

## Infrastructure

- **Inference**: Forked mistral.rs with text-only Gemma 3 support (upstream PR
  not merged). HF safetensors only — no GGUF (causes vocab padding, tokenizer
  hash, and SentencePiece artifact issues).
- **Subtrees**: `fish/` (fish-shell upstream, squash-merged) and `mog/`
  (compiler, runtime, capabilities).
- **Hardware**: kelce (RTX 5070, 192GB RAM) for training; marks (M4 Pro, 64GB)
  for daily inference and fallback training.

## Development History

Built over 10 days (2026-03-20 to 2026-03-29) across 32 tracked sessions
totaling ~3,500+ messages. Development was orchestrated via exophial with
parallel worker dispatch for training data generation and sequential sessions
for crate implementation.

### Session Timeline

| Date | Sessions | Work |
|------|----------|------|
| Mar 20 | 1 | DC Rust validation (1,755 messages), scaffolding, plans written to repo |
| Mar 21 | 18 | Bash→Mog translation (10 parallel workers), Pass 1/2/3 training, combined model training, LoRA adapter swapping attempt, engine migration to mistral.rs |
| Mar 22 | 3 | 12B model training on marks (525 messages), summaries |
| Mar 25 | 2 | Batch annotation integration test with quality validation |
| Mar 29 | 2 | Repo location, this status review |

### Implementation Order (outside-in TDD)

1. Layer 0: Annotator core + CLI acceptance tests (failing tests first)
2. Layer 1: Parser edge cases, idempotency
3. Layer 2: Daemon mode with signal handling
4. Layer 3: Skill cache with dependency invalidation
5. Layer 4: Classifier with fast paths
6. Layer 5: MCP server library
7. Layer 6: Fish shell integration stubs
8. Engine: mistral.rs → llama-cpp-4 → mistral.rs (forked, current)
9. Capability host: 12 tool `.mogdecl` files + dispatcher (19/19 tests)
10. Training: 10 parallel translation workers, 6 training runs on marks
11. Integration test: batch annotation with real model, quality validation

## Next Priorities

1. **Wire `generate_mog()`** to mistral.rs backend
2. **Implement MCP server binary** with JSON-RPC stdio transport
3. **Deploy trained model** and begin live feedback collection
4. **DPO refinement** on collected feedback data
5. **Fish integration** — hook classifier into `reader.rs`
6. **Escalation path** — route failures to large model via exophial MCP
