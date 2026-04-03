# XLoRA/LoRA Support for Gemma 3 Text-Only Models -- TDD Implementation Plan

## 1. Architecture Overview

There are two workstreams, each following outside-in double-loop TDD:

**Workstream A: XLoraGemma3 text model** (~1,100 LOC, 3 files in the mistral.rs fork)
- New file: `mistralrs-core/src/xlora_models/gemma3.rs`
- Modified: `mistralrs-core/src/xlora_models/mod.rs`
- Modified: `mistralrs-core/src/pipeline/loaders/normal_loaders.rs`

**Workstream B: Per-request adapter swapping** (~250-400 LOC, 4-5 files across mistral.rs fork and mogfish)
- Modified: `mistralrs-core/src/request.rs` (add `adapters` field to `NormalRequest`)
- Modified: `mistralrs/src/model.rs` (wire `take_adapters()` into `NormalRequest`)
- Modified: `mistralrs-core/src/engine/` (propagate adapters to model forward)
- Modified: `mogfish/crates/mogfish-engine-mistralrs/src/lib.rs` (use `set_adapters()`)

## 2. Key Structural Differences: Gemma2 vs Gemma3

These must be adapted when copying from `xlora_models/gemma2.rs`:

| Feature | XLoraGemma2 | XLoraGemma3 (target) |
|---|---|---|
| Config type | `crate::models::gemma2::Config` | `crate::vision_models::gemma3::config::Gemma3TextConfig` |
| RoPE | Single `RotaryEmbedding` per device | Dual: `Gemma3RotaryEmbedding` (global) + `RotaryEmbedding` (local) |
| Q/K norms | None | `GemmaRmsNorm` on q and k after projection, before RoPE |
| Sliding window pattern | `layer_idx.is_multiple_of(2)` (even = SWA) | `(layer_idx + 1) % cfg.sliding_window_pattern != 0` via `is_sliding!` macro |
| Cache type | `EitherCache::Full(Cache::new(...))` | Must also use `EitherCache::Full(Cache)` for X-LoRA (NOT NormalCache) |
| Embedding | `candle_nn::Embedding` + manual `* sqrt(hidden_size)` | `ScaledEmbedding` (wraps embedding with built-in scaling) |
| lm_head tying | Always untied (uses embed_tokens weights) | `tie_word_embeddings` config flag |
| Softcapping | `attn_logit_softcapping` (via sdpa_params) + `final_logit_softcapping` | Same pattern, but `attn_logit_softcapping` may be `None` for Gemma3 1B |
| Layer norms | 4 per layer (same names) | 4 per layer (same names) -- no change needed |
| MLP | Custom `MLP` struct with LoRA wrappers | Must create custom MLP with LoRA (Gemma3 text uses `Mlp` from layers, not LoRA-wrapped) |

## 3. Outer Loop: Acceptance Tests

These describe end-to-end behavior and are written first. They will fail until
the full implementation is complete.

### 3a. Acceptance Test: XLoraGemma3 model loads and runs (in mistral.rs fork)

There are no existing XLoraGemma2 tests in the fork. The nearest reference is
`mogfish/crates/mogfish-engine-mistralrs/tests/acceptance.rs`. We model new
tests on that pattern.

**File**: `mistralrs-core/tests/xlora_gemma3_acceptance.rs` (new, in the fork)

```rust
// Test 1: load_xlora_gemma3_does_not_bail
// - Parse a Gemma3TextConfig from a fixture JSON
// - Call Gemma3TextLoader::load_xlora() with valid args
// - Assert it returns Ok (not the current bail!)
// - Gated behind env var MISTRALRS_TEST_GEMMA3_MODEL

// Test 2: xlora_gemma3_forward_produces_logits
// - Load model as above
// - Construct a simple input_ids tensor
// - Call xlora_forward()
// - Assert output shape is (batch, vocab_size)

// Test 3: xlora_gemma3_respects_adapter_ordering
// - Load with 2+ adapters in ordering
// - Verify model.xlora_classifier is Some
// - Verify layer count matches config
```

### 3b. Acceptance Test: Per-request adapter swapping (in mogfish)

**File**: `mogfish/crates/mogfish-engine-mistralrs/tests/acceptance.rs` (extend existing)

```rust
// Test: adapter_swap_per_request
// - Load engine with base model + 3 preloaded LoRA adapters
// - Send request with set_adapters(["annotator"])
// - Send request with set_adapters(["classifier"])
// - Send request with set_adapters(["mog_gen"])
// - Assert each returns a valid response (not an error)
// - Gated behind env var MOGFISH_TEST_LORA_MODEL
```

## 4. Inner Loop: Unit Tests and Implementation Steps

### Phase 1: XLoraGemma3 model (Workstream A)

#### Step 1.1: Create `xlora_models/gemma3.rs` skeleton

Copy `xlora_models/gemma2.rs` (934 lines) to `xlora_models/gemma3.rs`. Then
make these structural changes:

**Unit tests** (in the same file, `#[cfg(test)] mod tests`):

```
test_gemma3_sliding_window_pattern
  - Assert is_sliding!(0, cfg) with sliding_window_pattern=6 gives true
  - Assert is_sliding!(5, cfg) gives false (layer 5 = global)
  - Assert is_sliding!(6, cfg) gives true

test_gemma3_attention_has_qk_norms
  - Construct Attention struct
  - Assert q_norm and k_norm fields exist and have correct dim (head_dim)

test_gemma3_dual_rope_selection
  - Verify sliding layers use rotary_emb_local
  - Verify global layers use rotary_emb_global
```

**Implementation changes from gemma2.rs**:

1. **Imports**: Change `Config` import from `crate::models::gemma2::Config` to
   `crate::vision_models::gemma3::config::Gemma3TextConfig`. Add imports for
   `Gemma3RotaryEmbedding`, `ScaledEmbedding`.

2. **Attention struct**:
   - Add fields: `rotary_emb_global: Arc<Gemma3RotaryEmbedding>`,
     `rotary_emb_local: Arc<RotaryEmbedding>`, `q_norm: GemmaRmsNorm`,
     `k_norm: GemmaRmsNorm`
   - Remove single `rotary_emb: Arc<RotaryEmbedding>`
   - Change `Attention::new()` signature to accept both rope embeddings
   - In `new()`: construct q_norm and k_norm with `cfg.head_dim` and
     `cfg.rms_norm_eps`
   - Change sliding window check: `is_sliding!(layer_idx, cfg)` instead of
     `layer_idx.is_multiple_of(2)`
   - In `forward()`: apply q_norm and k_norm after projection, before RoPE.
     Then select RoPE: `if self.use_sliding_window {
     self.rotary_emb_local.forward(...) } else {
     self.rotary_emb_global.forward(...) }`

3. **MLP struct**: Change `act_fn` to use `cfg.hidden_activation` (Gemma3 uses
   `hidden_activation` field, not `hidden_act()` method). The field in
   Gemma3TextConfig is `hidden_activation: Activation`.

4. **DecoderLayer::new()**: Accept both rope embeddings, pass to
   Attention::new().

5. **Model struct**:
   - Change `embed_tokens` from `candle_nn::Embedding` to handling with
     `ScaledEmbedding` -- but for X-LoRA we need access to raw embeddings for
     lm_head tying. Use `candle_nn::Embedding` plus manual scaling by
     `(hidden_size as f64).sqrt()` in forward, same as Gemma2.
   - Add `sliding_window_pattern: usize` field.

6. **Model::new()**:
   - Create dual rope maps: `global_ropes` using
     `Gemma3RotaryEmbedding::new()` and `local_ropes` using
     `RotaryEmbedding::new(cfg.rope_local_base_freq, ...)`.
   - Handle `tie_word_embeddings`: if true, use embed_tokens weights for
     lm_head; if false, load separate lm_head.
   - Cache: use `EitherCache::Full(Cache::new(cfg.num_hidden_layers, true))`
     (same as Gemma2 XLoRA, NOT NormalCache).

7. **Model::inner_forward()**:
   - Use `is_sliding!(i, cfg)` macro for sliding window mask selection.
   - Scale embeddings: `(xs * (self.hidden_size as f64).sqrt())?`

8. **NormalModel impl**: Same pattern as XLoraGemma2, implement
   `xlora_forward` to call `self.forward(...)`.

9. **ScalingsMaker impl**: Same pattern as XLoraGemma2.

10. **AnyMoeBaseModelMixin impl**: Empty impl, same as Gemma2.

#### Step 1.2: Register in `xlora_models/mod.rs`

Add to the file:

```rust
mod gemma3;
// ...
pub(crate) use gemma3::Model as XLoraGemma3;
```

#### Step 1.3: Wire `Gemma3TextLoader::load_xlora()` in `normal_loaders.rs`

At line 5141-5152, replace the bail with:

```rust
fn load_xlora(
    &self,
    config: &str,
    vb: ShardedVarBuilder,
    lora_config: &[((String, String), LoraConfig)],
    xlora_config: Option<XLoraConfig>,
    xlora_ordering: Ordering,
    normal_loading_metadata: NormalLoadingMetadata,
    preload_adapters: &Option<HashMap<String, (ShardedVarBuilder, LoraConfig)>>,
) -> Result<Box<dyn NormalModel + Send + Sync>> {
    let cfg: Gemma3TextConfig = serde_json::from_str(config)?;
    Ok(Box::new(xlora_models::XLoraGemma3::new(
        &cfg,
        vb,
        lora_config,
        xlora_config,
        xlora_ordering,
        self.is_gptx(config)?,
        normal_loading_metadata,
        preload_adapters,
    )?))
}
```

### Phase 2: Per-request adapter swapping (Workstream B)

#### Step 2.1: Add `adapters` field to `NormalRequest`

**File**: `mistralrs-core/src/request.rs` (line ~177)

```rust
pub struct NormalRequest {
    // ... existing fields ...
    pub adapters: Option<Vec<String>>,  // NEW
}
```

#### Step 2.2: Wire `take_adapters()` in `model.rs`

**File**: `mistralrs/src/model.rs`

In both `stream_chat_request_with_model` (line 131) and
`send_chat_request_with_model` (line 182), add
`adapters: request.take_adapters(),` to the `NormalRequest` construction.

Also in `send_raw_chat_request_with_model` (line 226+).

#### Step 2.3: Propagate adapters through the engine to model forward

Key files to modify:
- `mistralrs-core/src/engine/` -- where `NormalRequest` is processed and
  sequences are created
- The scheduler/sequence system needs to carry adapter info

The preload_adapters mechanism in mistral.rs already supports loading multiple
adapters at model-load time. The per-request activation can use the existing
`lora_forward` with appropriate scalings or adapter selection.

#### Step 2.4: Mogfish engine integration

**File**: `mogfish/crates/mogfish-engine-mistralrs/src/lib.rs`

Modify `MistralRsEngine` to:
1. Accept adapter config in constructor (adapter model IDs, ordering file path)
2. Use `TextModelBuilder` with LoRA configuration instead of plain
   `ModelBuilder`
3. In `chat_constrained` and `chat_free`, call
   `request.set_adapters(vec![adapter_name])` before sending

```rust
// New method signature
pub fn from_hf_model_with_lora(
    model_id: &str,
    ordering_path: &Path,
    adapter_model_id: &str,
    use_gpu: bool,
) -> anyhow::Result<Self>
```

## 5. Implementation Order (TDD Sequence)

```
OUTER LOOP (acceptance tests, all fail initially):
  1. Write xlora_gemma3_acceptance tests
  2. Write adapter_swap_per_request test

INNER LOOP, Phase 1 (make XLoraGemma3 tests pass):
  3. Write unit test: test_gemma3_sliding_window_pattern --> FAIL
  4. Create xlora_models/gemma3.rs with is_sliding! macro --> PASS
  5. Write unit test: test_gemma3_attention_has_qk_norms --> FAIL
  6. Implement Attention struct with q_norm, k_norm --> PASS
  7. Write unit test: test_gemma3_dual_rope_selection --> FAIL
  8. Implement dual RoPE in Attention::forward --> PASS
  9. Implement full Model::new() and Model::forward()
  10. Register in xlora_models/mod.rs
  11. Wire Gemma3TextLoader::load_xlora() in normal_loaders.rs
  12. Run acceptance tests --> PASS (for workstream A)

INNER LOOP, Phase 2 (make adapter swapping tests pass):
  13. Write unit test: test_normal_request_accepts_adapters --> FAIL
  14. Add adapters field to NormalRequest --> PASS
  15. Wire take_adapters() in model.rs
  16. Propagate adapters through engine pipeline
  17. Update mogfish MistralRsEngine
  18. Run acceptance tests --> PASS (for workstream B)
```

## 6. File Inventory

### Files to create (in mistral.rs fork):
- `mistralrs-core/src/xlora_models/gemma3.rs` (~1,100 LOC)
- `mistralrs-core/tests/xlora_gemma3_acceptance.rs` (test file, ~100 LOC)

### Files to modify (in mistral.rs fork):
- `mistralrs-core/src/xlora_models/mod.rs` (+3 lines: mod, use, export)
- `mistralrs-core/src/pipeline/loaders/normal_loaders.rs` (~15 lines: replace
  bail)
- `mistralrs-core/src/request.rs` (+1 field)
- `mistralrs/src/model.rs` (+3 lines across 3 functions)

### Files to modify (in mogfish):
- `crates/mogfish-engine-mistralrs/src/lib.rs` (~100 LOC: LoRA constructor,
  adapter-aware methods)
- `crates/mogfish-engine-mistralrs/tests/acceptance.rs` (~50 LOC: new test
  cases)

## 7. Risks and Mitigations

1. **Cache type mismatch**: Gemma3 text model uses `NormalCache` with `KvCache`
   per-layer (supports sliding window cache types). XLoRA requires
   `EitherCache::Full(Cache)` for its dual-pass (scaling pass + full pass)
   mechanism. The XLoraGemma3 model MUST use `EitherCache::Full` and
   `Cache::update_kv_cache_sliding_window` for sliding window layers, matching
   the XLoraGemma2 approach. This means the XLoRA variant does not use
   PagedAttention.

2. **Gemma3RotaryEmbedding takes &Gemma3TextConfig**: The global RoPE
   constructor `Gemma3RotaryEmbedding::new(is_gptx, dtype, cfg, device)` takes
   the full config, not individual parameters. This is fine -- pass the config
   reference.

3. **tie_word_embeddings**: When true (default for Gemma3 1B), lm_head shares
   weights with embed_tokens. For X-LoRA, lm_head must NOT have LoRA adapters
   (enforced by the existing check at xlora_models/gemma2.rs line 592-594).
   With tied weights, use `linear_no_bias` wrapping the embedding weights, same
   as Gemma2.

4. **Per-request adapter swapping is dead code**: The
   `RequestBuilder.set_adapters()` -> `take_adapters()` path exists but
   `model.rs` never calls `take_adapters()` and `NormalRequest` has no
   `adapters` field. This is a complete dead path that must be wired
   end-to-end.

5. **Engine adapter propagation**: The deepest unknown is how the
   engine/scheduler processes the `adapters` field to actually activate adapters
   at inference time. The `lora_activation.py` example shows
   `adapters=["adapter_4"]` in the request body. Investigation of the pyo3
   bindings and server routes may clarify the intended wiring.

### Critical Source Files
- `~/.cargo/git/checkouts/mistral.rs-fb1e3f4125e7b584/16d583b/mistralrs-core/src/xlora_models/gemma2.rs` (template)
- `~/.cargo/git/checkouts/mistral.rs-fb1e3f4125e7b584/16d583b/mistralrs-core/src/vision_models/gemma3/text.rs` (Gemma3 reference)
- `~/.cargo/git/checkouts/mistral.rs-fb1e3f4125e7b584/16d583b/mistralrs-core/src/pipeline/loaders/normal_loaders.rs` (line 5141: bail to replace)
- `~/.cargo/git/checkouts/mistral.rs-fb1e3f4125e7b584/16d583b/mistralrs/src/model.rs` (dead adapter path)
- `mogfish/crates/mogfish-engine-mistralrs/src/lib.rs` (mogfish engine)
