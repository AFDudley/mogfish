# Plan: Mogfish — TDD Implementation Plan

## Context

Mogfish combines fish shell, the Mog language, and a new annotator daemon into a
local-first LLM-enhanced shell. Fish and Mog already exist as subtrees in
`/home/rix/.exophial/dc/mogfish/`. The new code to write: an annotator daemon
that semantically enriches fish completions, a skill cache, an input classifier,
and an MCP server that exposes it all.

**DC's role**: Development tooling only. DC (dagster-composable) is the harness
for *building* mogfish — code generation via sessions, training data pipelines,
validation workflows. Mogfish itself is pure Rust, no DC runtime dependency.

**Methodology**: Outside-in TDD. Every component starts with a failing acceptance
test that describes observable behavior. Code exists only to make tests pass.
Scientific method: hypothesis (test), experiment (implementation), observation
(test result), refinement (refactor).

## What Already Exists

| Component | Location | Language | Status |
|-----------|----------|----------|--------|
| Fish shell | `fish/` subtree | Rust (Cargo workspace) | Complete, upstream |
| Mog compiler (`mogc`) | `mog/compiler/` | Rust | Working, has tests |
| Mog runtime | `mog/runtime-rs/` | Rust | Working, staticlib/cdylib |
| Mog capabilities | `mog/capabilities/*.mogdecl` | Mog decl | fs, http, process, env, log, math, timer |

DC dev tooling available:
- `session_manager` — airlock pattern for generated code validation
- `file_operations` — file walking, search, pattern matching
- `spec-codegen` package — LLM → structured output → validation pattern
- `manage_execution` — job orchestration for training pipelines

## Project Layout

```
mogfish/
├── Cargo.toml              # NEW — workspace root
├── crates/
│   ├── mogfish-traits/     # NEW — shared traits (InferenceEngine, etc.)
│   ├── annotator/          # NEW — core annotator library + daemon
│   ├── annotator-cli/      # NEW — CLI entry point (batch + daemon modes)
│   ├── skill-cache/        # NEW — skill storage + completion stub generation
│   ├── classifier/         # NEW — input classification
│   └── mogfish-mcp/        # NEW — MCP server (depends on annotator + skill-cache)
├── fish/                   # subtree (unchanged)
├── mog/                    # subtree (unchanged)
├── mogfish.md
└── mogfish-training.md
```

## TDD Phases

### Phase 1: Scaffolding + Trait Definitions

**Hypothesis**: We can define the InferenceEngine trait and mock it before any
real model exists.

**Files to create**:
- `Cargo.toml` — workspace root (members = `crates/*`, exclude `fish/`, `mog/`)
- `crates/mogfish-traits/Cargo.toml`
- `crates/mogfish-traits/src/lib.rs`

**Implementation**:
1. `InferenceEngine` trait:
   - `async fn annotate(&self, help_text: &str) -> Result<Annotation>`
   - `async fn classify(&self, input: &str) -> Result<Classification>`
   - `async fn generate_mog(&self, intent: &str, context: &GroundingContext) -> Result<String>`
2. Data types: `Annotation`, `Classification`, `GroundingContext`, `FlagDoc`
3. `MockInferenceEngine` — deterministic responses, configurable per-test

**Test**: Mock implements trait, returns expected values, is Send + Sync.

### Phase 2: Annotator Core (Outside-In)

**Hypothesis**: Given a directory of `.fish` completion files, the annotator can
parse them, enrich them via InferenceEngine, and write back annotated versions.

**Acceptance test** (write first, watch fail):
```
Given: a temp dir with 3 sample .fish completion files (git, fd, rg)
And: a MockInferenceEngine with known responses
When: annotator.annotate_directory(dir, &engine).await
Then: each .fish file contains # mog-description, # mog-intent, # mog-flags
And: original completion content is preserved
And: annotations match the mock's responses
```

**Files to create**:
- `crates/annotator/Cargo.toml` (depends on mogfish-traits)
- `crates/annotator/src/lib.rs`
- `crates/annotator/src/parser.rs` — CompletionFile parser
- `crates/annotator/src/enricher.rs` — annotation logic
- `crates/annotator/tests/acceptance.rs`

**Unit tests** (each written before implementation):
- Parser: reads a .fish file, extracts command name + existing completions
- Parser: handles empty files, files with existing mog comments (idempotent)
- Parser: handles malformed files gracefully (skip, don't crash)
- Enricher: inserts annotations at correct position in file
- Enricher: preserves original content byte-for-byte outside annotation block

**Reference files** for .fish completion format:
- `fish/share/completions/git.fish` — complex, multi-subcommand
- `fish/share/completions/fd.fish` — simple flags
- `fish/src/complete.rs` — how fish loads completions

### Phase 3: Annotator Daemon + CLI

**Hypothesis**: The annotator runs as both a batch CLI tool and a long-running
daemon with package manager hooks.

**Acceptance tests**:
```
# Batch mode
Given: a directory of .fish completions
When: `mogfish-annotate batch --dir ./completions --engine mock`
Then: exit 0, files annotated, summary to stdout

# Dry-run
When: `mogfish-annotate batch --dir ./completions --engine mock --dry-run`
Then: exit 0, no files modified, diff to stdout

# Daemon mode
When: `mogfish-annotate daemon --completions-dir ./completions --engine mock`
Then: daemon starts, annotates existing files, watches for new files
When: a new .fish file appears in the directory
Then: daemon annotates it within 1 second

# Package manager hook
When: daemon receives SIGUSR1 (or inotify event on completions dir)
Then: re-scans directory, annotates new/changed files
```

**Files to create**:
- `crates/annotator-cli/Cargo.toml` (depends on annotator)
- `crates/annotator-cli/src/main.rs` — clap CLI, batch + daemon subcommands
- `crates/annotator/src/daemon.rs` — event loop, directory watching, lifecycle
- `crates/annotator/src/watcher.rs` — inotify/kqueue file system watcher

**Implementation**:
1. CLI with `batch` and `daemon` subcommands (clap derive)
2. `--engine` flag: `mock` (testing), `mistralrs` (real model, later)
3. Daemon: tokio event loop + notify crate for filesystem watching
4. Graceful shutdown on SIGTERM, re-scan on SIGUSR1

### Phase 4: Skill Cache

**Hypothesis**: Cached Mog scripts + their .fish completion stubs can be stored,
retrieved, and invalidated as a pure data layer.

**Acceptance test**:
```
Given: an empty skill cache directory
When: cache.store("find modified python files", mog_script, deps=["fd"])
Then: dir contains find-modified-python.mog with the script
And: dir contains find-modified-python.fish completion stub
When: cache.lookup("find modified python files") → Some(CachedSkill)
When: cache.invalidate_dependency("fd")
Then: find-modified-python is flagged stale
When: cache.list_stale() → ["find-modified-python"]
```

**Files to create**:
- `crates/skill-cache/Cargo.toml`
- `crates/skill-cache/src/lib.rs`
- `crates/skill-cache/src/naming.rs` — intent → slug derivation
- `crates/skill-cache/src/stub.rs` — .fish completion stub generation
- `crates/skill-cache/tests/acceptance.rs`

**Unit tests**:
- Naming: "find all Python files modified this week" → "find-modified-python"
- Stub: generates valid .fish completion with correct `complete -c` syntax
- Store: writes .mog + .fish + metadata to disk
- Lookup: exact match, fuzzy match, miss
- Dependency: parse `# requires:` header → dep list
- Invalidation: flag stale without deleting

### Phase 5: Input Classifier

**Hypothesis**: A classifier distinguishes known commands, cached skills, and
natural language, using fast paths before model inference.

**Acceptance test**:
```
Given: MockInferenceEngine, skill cache with "find-modified-python",
       known_commands = {"git", "ls", "cd", "cargo", ...}
When: classify("git push origin main") → KnownCommand("git")
When: classify("find-modified-python --days 7") → CachedSkill("find-modified-python")
When: classify("show me what's using port 8080") → NaturalLanguage
```

**Files to create**:
- `crates/classifier/Cargo.toml` (depends on mogfish-traits, skill-cache)
- `crates/classifier/src/lib.rs`
- `crates/classifier/tests/acceptance.rs`

**Implementation order** (each step has a test first):
1. Known command check: split on whitespace, check first token against set
2. Cached skill check: check first token against skill cache names
3. Heuristic fast path: if input parses as valid shell syntax, likely known command
4. Model fallback: call `InferenceEngine::classify()` for genuinely ambiguous input

### Phase 6: MCP Server

**Hypothesis**: An MCP server can expose the annotator's knowledge base and skill
cache to external tools (Claude Code, other agents).

**Acceptance test**:
```
Given: annotator with annotated completions, skill cache with cached skills
When: MCP query "what tools can search files?" → list of annotated commands
When: MCP query "run skill find-modified-python" → executes cached Mog script
When: MCP query "generate script for: show disk usage by directory" → new Mog script
```

**Files to create**:
- `crates/mogfish-mcp/Cargo.toml` (depends on annotator, skill-cache, mogfish-traits)
- `crates/mogfish-mcp/src/lib.rs` — MCP protocol implementation
- `crates/mogfish-mcp/src/main.rs` — standalone MCP server binary

### Phase 7: Fish Integration (deferred — plan only)

Modifies the fish subtree. Don't implement until Phases 1–6 are solid.

- Hook point: `fish/src/reader.rs` — early in input pipeline
- Classifier runs as Rust function call (same process, no IPC)
- Cached skill → Mog runtime (link against mog-runtime crate)
- NL intent → annotator's inference engine for Mog generation
- Generated Mog → mogc compile → mog-runtime execute → cache result as skill

## DC as Development Tooling

DC orchestrates the *building* of mogfish, not its runtime:

1. **Code generation sessions**: Use dc `session_manager` airlock pattern when
   generating Rust code via LLM — stage files, validate (cargo check/test),
   commit or reject
2. **Training data pipeline**: dc package with assets for each Stage 1 step
   from mogfish-training.md (transcript extraction, Mog translation, man page
   annotation, classifier data generation)
3. **Validation workflows**: dc jobs to run `mogc --check` over generated Mog
   scripts, compute pass rates, flag failure clusters
4. **Development orchestration**: Use dc `manage_execution` to run cargo test
   suites, track results, and surface regressions

## Verification Strategy

Each phase gates the next. No phase starts until the previous phase's tests pass.

1. **Per-phase**: `cargo test -p <crate>` — all tests green
2. **Workspace**: `cargo test --workspace` — no cross-crate regressions
3. **Annotator smoke**: run batch mode against `fish/share/completions/` with mock
4. **Skill cache round-trip**: store → lookup → invalidate → verify
5. **Classifier**: hand-labeled test set of 50 inputs, >95% accuracy on fast paths
6. **MCP**: start server, query from Claude Code, verify responses
7. **Pre-commit**: clippy, rustfmt, cargo test on every commit
