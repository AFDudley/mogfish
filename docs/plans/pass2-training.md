# Plan: Pass 2 Training — Mog Generation with Per-Tool Capabilities

## Status

| Step | Status | Output |
|------|--------|--------|
| Extract bash commands from sessions | ✅ Done | `training/bash_commands.jsonl` (23,620 commands) |
| Generate per-tool .mogdecl files | ✅ Done | `mog/capabilities/tools/` (12 tools) |
| Build host runtime (mogfish-host) | ✅ Done | `crates/mogfish-host/` (19 tests pass) |
| Add Escalate classification category | ✅ Done | `mogfish-traits` updated |
| Translate bash → Mog with capabilities | 🔲 Next | spawn workers |
| Validate translations with mogc | 🔲 | |
| Train Pass 2a (capability generation) | 🔲 | |
| Train Pass 2b (Mog script generation) | 🔲 | |
| Export GGUF + deploy | 🔲 | |

## Architecture

Mog is sandboxed — all I/O flows through declared capabilities. Each CLI tool
gets a `.mogdecl` file with typed functions. The host runtime (`mogfish-host`)
maps capability calls to subprocess invocations with an allowlist.

```
User intent → classifier → Mog script → mogc compile → host runtime → subprocess
                                              ↓
                                        .mogdecl validation
```

### Escalation path (future, via exophial)

When the local 1B model fails (bad .mogdecl, invalid Mog, wrong tool mapping):
1. Local model detects failure → classifies as `Escalate`
2. Mogfish routes to large model (Claude) via exophial MCP
3. Large model fixes the .mogdecl or Mog script with source code context
4. Fix cached locally → becomes DPO training data for next cycle

## Available tool capabilities (12)

| Capability | Functions | Source |
|-----------|-----------|--------|
| git | status, branch, log, diff, add, commit, checkout, merge, rebase, stash, push*, pull* | mogdecl |
| grep | search, search_recursive*, count, files_matching, search_fixed, invert_match, search_numbered | mogdecl |
| find | by_name*, by_type*, by_min_size*, by_max_size*, modified_within*, modified_before*, count | mogdecl |
| sed | substitute, substitute_all, delete_matching, insert_before, insert_after, extract_range | mogdecl |
| awk | field, fields, filter, sum_field, count_matching, unique_field, format_fields | mogdecl |
| jq | query, filter, transform, keys, values | mogdecl |
| yq | query, get, to_json, from_json, set | mogdecl |
| curl | get*, post*, put*, delete*, download* | mogdecl |
| docker | ps, run, exec, logs, stop, rm, images, build* | mogdecl |
| gh | pr_create*, pr_list*, pr_view*, issue_create*, issue_list*, repo_clone*, run_list*, run_view* | mogdecl |
| cargo | build*, test*, check*, clippy*, run*, fmt* | mogdecl |
| python3 | eval, exec, run_script*, run_module* | mogdecl |

\* = async fn

Plus existing core capabilities: fs, http, process, env, log, math, timer

## Next: Translation phase

Spawn workers to translate bash commands → Mog scripts using per-tool capabilities.

**Input**: `training/bash_commands.jsonl` (23,620 commands with descriptions)
**Process**: Each worker takes a batch, translates to Mog using `requires <tool>;`,
validates with `mogc --emit-ir`, keeps only valid compilations.
**Output**: `training/mog_generation_train.jsonl` + `training/mog_generation_eval.jsonl`

mogc finds .mogdecl files in `capabilities/` relative to:
1. Source file directory
2. Compiler binary location
3. Current working directory

For validation, copy tool mogdecls into a flat `capabilities/` dir alongside the .mog file.

## Two training passes from translated data

**Pass 2a — Capability generation**: Train model to produce `.mogdecl` files
from tool documentation (fish annotations + help text).

**Pass 2b — Mog script generation**: Train model to produce Mog scripts that
use declared capabilities, given natural language intent + available tools.

Both train on marks (M4 Pro, 64GB) via mlx-lm LoRA on top of Pass 1 adapter.

## SSH to marks
```bash
SSH_AUTH_SOCK=/tmp/ssh-Lk7vHxsKl1/agent.3889143 ssh rix@10.5.5.1
```
