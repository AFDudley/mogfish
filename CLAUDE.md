# Mogfish Project Rules

## Model Format

**NEVER use GGUF format.** This decision has been made 4+ times. Use HF
safetensors with mistral.rs ISQ (in-situ quantization) at load time.

GGUF conversion causes:
- Vocab padding issues (262144 vs 262145)
- Tokenizer hash mismatches requiring manual patching
- SentencePiece `[UNK_BYTE]` artifacts in model output
- `build.rs` race conditions in llama-cpp-sys-4

The fused HF model directories on marks are the deployment artifacts.
mistral.rs loads them directly via `ModelBuilder::new(path).with_isq(IsqType::Q4K)`.
