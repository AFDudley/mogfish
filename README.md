# Mogfish

A local-first, LLM-enhanced shell that combines [fish](https://fishshell.com),
the [Mog](https://github.com/voltropy/mog) sandboxed scripting language, and a
locally running inference engine into a system that learns from use, executes
intent safely, and grows smarter over time — without sending data to the cloud.

## Purpose

Mogfish is not a new shell and not a chatbot. It is fish, largely unchanged,
with two additions:

1. **An annotator daemon** that knows everything installed on your machine and
   enriches it with semantic descriptions using a local 1B model.
2. **A sandboxed execution layer** (Mog) that turns natural language intent into
   cached, reusable skills. The first time you express an intent mogfish doesn't
   recognize, it generates a solution. Every time after that, it runs the cached
   version instantly.

## Objectives

- **Local-first**: All inference runs on local hardware (Gemma 3 1B via
  mistral.rs). No API calls, no cloud dependencies, no data leaves your machine.
- **Learn from use**: Every generated script is cached as a skill with a fish
  completion stub. The shell accumulates capabilities over time.
- **Safe execution**: All generated code runs through Mog's sandbox. Scripts
  declare their capabilities (`requires git, fs`) and the host enforces an
  allowlist. No escape from the sandbox.
- **Grounded generation**: The annotator maintains a semantic index of what's
  actually installed. Generated scripts are grounded in your real environment,
  not a model's prior about what flags a tool probably supports.
- **Shared skill library**: Skills generated at the command line are available
  to Claude Code via MCP, and vice versa. One growing library of verified,
  sandboxed capabilities.

## Architecture

```
User input
  │
  ├─ Known command (git, ls, cargo) → fish handles it natively
  ├─ Cached skill → Mog runtime executes cached script
  └─ Natural language intent
       │
       ├─ Annotator provides grounding context (what's installed)
       ├─ Local model generates Mog script
       ├─ mogc compiles and validates
       ├─ mogfish-host dispatches capability calls to real tools
       ├─ Mog runtime executes in sandbox
       └─ Result cached as skill + fish completion registered
```

### Components

| Component | Description |
|-----------|-------------|
| **mogfish-traits** | `InferenceEngine` trait, shared types, mock engine |
| **annotator** | Parses `.fish` completion files, enriches with semantic annotations |
| **annotator-cli** | Batch and daemon modes for annotation |
| **skill-cache** | Stores cached Mog scripts, generates fish completion stubs |
| **classifier** | Routes input: known command → cached skill → model inference |
| **mogfish-classify** | Standalone fast-path classifier (no model required) |
| **mogfish-engine-mistralrs** | Local inference via mistral.rs with ISQ quantization |
| **mogfish-host** | Capability dispatcher — maps Mog declarations to real CLI tools |
| **mogfish-mcp** | MCP server exposing annotation, skills, and generation to external tools |

### Subtrees

- `fish/` — [fish-shell](https://github.com/fish-shell/fish-shell) (upstream, via git subtree)
- `mog/` — [Mog](https://github.com/voltropy/mog) compiler, runtime, and capability declarations

## Model

Base model: **Gemma 3 1B-IT** (HF safetensors format).
Loaded with ISQ Q4K quantization at runtime via a forked mistral.rs.

**Never use GGUF.** See `CLAUDE.md` for rationale.

Training uses LoRA fine-tuning across three tasks:
1. **Annotation** — enrich command documentation with semantic descriptions
2. **Mog generation** — translate natural language intent into sandboxed Mog scripts
3. **Classification** — route shell input to the correct handler

Training hardware: RTX 5070 (12GB, Unsloth) or M4 Pro (64GB, mlx-lm).

## Install

### Ubuntu/Debian

```bash
# Download and install the .deb (pulls in fish, downloads the model)
sudo apt install ./mogfish-annotator-cli_0.1.0-1_amd64.deb
```

This installs the binaries, fish shell integration, and downloads the
inference model (~1.2GB) from GitHub releases.

### Set fish as your shell

```bash
chsh -s /usr/bin/fish
```

Or launch fish from bash without changing your login shell:

```bash
fish
```

Mogfish activates automatically when fish starts. It aliases `bash` to
`mogfish-bass`, which routes commands through the classifier:

- **Known commands** (git, ls, cargo, etc.) run directly in fish
- **Cached skills** execute previously generated Mog scripts
- **Bash-specific syntax** (if/then/fi, heredocs) falls through to
  real bash via [bass](https://github.com/edc/bass)
- **Novel intents** generate new skills in the background

AI tools like Claude Code that call `bash -c "CMD"` automatically
route through mogfish. Over time, the skill cache grows and fewer
commands need the bash fallback.

## Building

```bash
# Requires Rust 1.85+
cargo build --release -p mogfish-annotator-cli -p mogfish-classify

# With GPU support (requires CUDA 12.8+)
cargo build --release -p mogfish-annotator-cli --features cuda
```

### Build the .deb

```bash
cargo install cargo-deb
cargo deb -p mogfish-annotator-cli --no-build
```

## Status

See [docs/status.md](docs/status.md) for detailed implementation status
and [docs/lab-notebook.md](docs/lab-notebook.md) for experimental results.

## License

All rights reserved. No license is granted for use, modification, or
distribution.
