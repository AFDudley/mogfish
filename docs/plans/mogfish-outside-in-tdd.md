# Plan: Mogfish — Outside-In TDD Implementation

## Context

Mogfish combines fish shell, Mog, and a new annotator daemon into a local-first
LLM-enhanced shell. Fish and Mog exist as subtrees in
`/home/rix/.exophial/dc/mogfish/`. We're building this outside-in: start from
user-visible behavior, mock everything behind it, then peel inward replacing
mocks with real implementations one layer at a time.

DC is the development harness for building mogfish — sessions, validation,
training pipelines. Mogfish itself is pure Rust, no DC runtime dependency.
DC's validation pipeline is currently Python-only; we extend it for Rust first.

## Two Tracks

**Track A**: Extend DC for Rust validation (prerequisite)
**Track B**: Build mogfish (outside-in TDD, using DC airlock)

Track A is small and focused. Track B is the main work.

---

## Track A: Extend DC for Rust Validation

### What exists now

DC's session manager classifies files by extension:
- `_VALIDATED_EXTENSIONS = {".py", ".md"}` → full validation pipeline
- `_PASSTHROUGH_EXTENSIONS` includes `.rs` → stored as-is, zero validation

The validation pipeline (`_run_validation_pipeline`) is hardcoded:
tier1 (LibCST syntax) → tier1 (import resolution) → tier2 (ruff, bandit,
vulture, pydoclint, codespell) → tier2.5 (deps) → tier3 (pytest)

### Changes needed

**Files to modify** (installed copy is the live one):

1. **Session manager** — route `.rs` to Rust validation
   - `dc-install/venv/.../session_manager/session_manager_impl.py`
   - Line ~469: move `.rs` from `_PASSTHROUGH_EXTENSIONS` to `_VALIDATED_EXTENSIONS`
   - Line ~680–722: add `elif file_extension == ".rs":` branch that calls a
     Rust-specific validation function instead of Python's `validation_orchestrator`

2. **Rust validation module** — new file
   - `dc-install/venv/.../validation_orchestrator/rust_validation.py`
   - Implements the Rust tier pipeline:
     - **Tier 1 (syntax/types)**: `cargo check` — catches syntax + type errors
     - **Tier 2 (static)**: `cargo clippy -- -D warnings` + `cargo fmt --check`
     - **Tier 3 (runtime)**: `cargo test` (specific crate if filename maps to one)
   - Returns `ValidationResult` / `ValidationRun` using the same Pydantic models
   - Needs: workspace root detection (walk up from file to find `Cargo.toml`
     with `[workspace]`), crate detection (which crate does this `.rs` file
     belong to)

3. **Validation config** — add Rust tool config
   - `dc-install/venv/.../validation_config.py`
   - Add `get_cargo_check_subprocess_args()`, `get_clippy_subprocess_args()`,
     `get_rustfmt_check_subprocess_args()`
   - Add Rust section to `validation_tools.json` schema

### Rust validation pipeline design

```python
def _run_rust_validation_pipeline(
    session_id: str,
    filename: str,
    content: str,
    workspace_root: Path,
) -> dict[str, Any]:
    """Tiered Rust validation. Same structure as Python pipeline."""
    # Tier 1: cargo check (syntax + types — equivalent to LibCST + mypy)
    tier1 = _run_cargo_check(workspace_root, filename)
    if tier1.status == "failed":
        return _build_validation_error_response(...)

    # Tier 2: clippy + rustfmt (equivalent to ruff + bandit)
    tier2_clippy = _run_cargo_clippy(workspace_root, filename)
    tier2_fmt = _run_cargo_fmt_check(workspace_root, filename)
    if not all passed:
        return _build_validation_error_response(...)

    # Tier 3: cargo test (equivalent to pytest)
    tier3 = _run_cargo_test(workspace_root, filename)
    ...
```

Each `_run_cargo_*` function: writes content to overlay, runs subprocess,
parses JSON/text output into `ValidationError` objects, returns `ValidationResult`.

### Verification (Track A)

1. Create a DC session, add a valid `.rs` file → should validate and pass
2. Add an `.rs` file with a type error → should fail at tier 1
3. Add an `.rs` file with a clippy warning → should fail at tier 2
4. Add an `.rs` file with a failing test → should fail at tier 3

---

## Track B: Build Mogfish (Outside-In TDD)

### What already exists

- **Fish shell** (`fish/`): Rust. Input: `reader::reader_read()` → `input.rs`.
  Completions: `complete.rs` + autoloader + `share/completions/*.fish`.
- **Mog** (`mog/`): Rust. Compiler (`mogc`, 290+ tests), runtime (GC, async,
  sandbox), capabilities (`.mogdecl`: fs, http, process, env, log, math, timer).

### Project layout

```
mogfish/
├── Cargo.toml              # workspace root (members = crates/*, exclude fish/, mog/)
├── crates/
│   ├── mogfish-traits/     # InferenceEngine trait, shared types
│   ├── annotator/          # core library + daemon
│   ├── annotator-cli/      # CLI entry point
│   ├── skill-cache/        # skill storage + .fish stub generation
│   ├── classifier/         # input classification
│   └── mogfish-mcp/        # MCP server
├── fish/                   # subtree
├── mog/                    # subtree
├── mogfish.md
└── mogfish-training.md
```

### Outside-in layers

#### Layer 0: The Outermost Test (Annotator CLI)

First user-visible behavior: **run annotator on a completions dir, get
annotated output.**

Write this acceptance test FIRST. Everything behind it is mocked.

```
Given: temp dir with real .fish completions from fish/share/completions/
When: `mogfish-annotate batch --dir {tmpdir} --engine mock`
Then: exit 0
And: each .fish file has # mog-description, # mog-intent, # mog-flags
And: original completion content byte-identical outside annotation block
And: summary printed to stdout
```

Files created (order driven by test failures):
- `crates/annotator-cli/src/main.rs` — CLI binary
- `crates/mogfish-traits/src/lib.rs` — `InferenceEngine` trait + `MockInferenceEngine`
- `crates/annotator/src/lib.rs` — `annotate_directory()` calling engine
- Wire together, make acceptance test pass

#### Layer 1: Annotator Internals

Acceptance test passes with mocks. Now test the annotator's own behavior:

- **Parser**: `CompletionFile::parse(content)` extracts command name, entries
- **Annotation insertion**: adds mog comments at top, preserves original content
- **Idempotency**: re-annotating replaces, doesn't duplicate
- **Error handling**: skips bad files, logs warning, continues

Files: `crates/annotator/src/{parser,enricher}.rs`
Reference: `fish/share/completions/git.fish`, `fish/src/complete.rs`

#### Layer 2: Daemon Mode

- **Directory watching**: new .fish file → annotated within 2s
- **Lifecycle**: SIGTERM → clean shutdown, no partial writes
- **Re-scan**: SIGUSR1 → re-scans and annotates new files

Files: `crates/annotator/src/{daemon,watcher}.rs`
Deps: tokio, notify crate

#### Layer 3: Skill Cache

New outermost test:
- **Store/retrieve**: intent → .mog file + .fish completion stub
- **Dependency invalidation**: `invalidate_dependency("fd")` → stale flag

Files: `crates/skill-cache/src/{lib,naming,stub}.rs`

#### Layer 4: Classifier

- Fast paths: known commands set, skill cache prefix match
- Model fallback: `InferenceEngine::classify()` for ambiguous input

Files: `crates/classifier/src/lib.rs`

#### Layer 5: MCP Server

- Query annotated commands by semantic filter
- Execute cached skills
- Generate new Mog scripts

Files: `crates/mogfish-mcp/src/{lib,main}.rs`

#### Layer 6: Fish Integration (deferred)

Hook: `fish/src/reader/reader.rs::reader_read()`. Don't touch until 0–5 solid.

### Scaffolding (before Layer 0)

1. `Cargo.toml` workspace at mogfish root
2. Empty crate shells (Cargo.toml + src/lib.rs each)
3. `InferenceEngine` trait + `MockInferenceEngine` in mogfish-traits
4. Pre-commit: clippy, rustfmt, cargo test
5. `.pebbles/` directory for issue tracking

Then immediately write the Layer 0 acceptance test.

---

## DC Development Workflow

Once Track A is done, all mogfish Rust code goes through DC sessions:

1. Generate `.rs` file (manually or via LLM)
2. `session_manager.add_file_to_session` → Rust validation runs
3. Tier 1 (`cargo check`) catches type errors before the file is stored
4. Tier 2 (`clippy` + `rustfmt`) catches lint/style issues
5. Tier 3 (`cargo test`) catches regressions
6. If all pass → file stored with "passed" status → inject into package
7. If any fail → file stored with "failed" status → fix via `edit_session_file`

Training data pipelines (Python, JSONL processing) use DC natively.

## Verification

**Track A**: Session with valid/invalid `.rs` files validates correctly
**Track B**: Each layer gates the next. `cargo test --workspace` always green.
Annotator smoke test against `fish/share/completions/` with mock engine.
Pre-commit on every commit. `.pebbles/` for issue tracking.

---

## Notes

### Inference backend: llama-cpp-4 (not mistral.rs)

We use `llama-cpp-4` (llama.cpp Rust bindings) instead of `mistralrs` because
mistralrs v0.7.0 doesn't support Gemma 3 GGUF format. PR #1964 on
`EricLBuehler/mistral.rs` adds text-only Gemma 3 GGUF support (CI passes,
branch: `glaziermag:codex/gemma3-text-gguf`) but is not yet merged.

If/when PR #1964 merges and a new mistralrs version ships, switching back is
an option — the `InferenceEngine` trait abstraction makes the backend swappable.
For now, llama-cpp-4 is the stable choice.
