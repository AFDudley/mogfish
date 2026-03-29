# Mogfish

## What It Is

Mogfish is a local-first, LLM-enhanced shell environment that combines three existing projects — fish, Mog, and a locally running inference engine — into a system that learns from use, executes intent safely, and grows smarter over time without ever sending your data to the cloud.

It is not a new shell. It is not a chatbot. It is fish, largely unchanged, with two additions: a background daemon that knows everything installed on your machine and annotates it semantically, and a sandboxed execution layer that turns natural language intent into cached, reusable skills. The first time you express an intent mogfish doesn't recognise, it generates a solution. Every time after that, it runs the cached version instantly.

---

## The Three Parts

### Fish

Fish is the interactive surface. You type into it. It handles your history, your completions, your prompt, your environment — everything it already does, unchanged. The only modification is a lightweight classifier sitting early in the input pipeline that asks, before fish tries to parse anything: is this a known command, a cached skill, or natural language intent? For known commands the classifier is invisible. For the other two cases it routes accordingly.

Fish's completion machinery is central to how mogfish feels native. Every skill mogfish learns is registered as a `.fish` completion file. From fish's perspective there is no distinction between a skill that came with the system and one that was generated last Tuesday — they all live in the same completions directory, they all tab-complete, they all show up in suggestions. The shell gets smarter without the user having to do anything.

### The Annotator

The annotator is a Rust daemon that runs in the background and maintains a semantically enriched view of everything installed on the system. On first run it walks fish's existing generated completions directory — fish already parses man pages and writes completion stubs for installed software — and augments each entry using a locally running model. The augmentation adds natural language descriptions: what the command does, what kinds of intent a user might express to invoke it, what its parameters mean in plain terms. These annotations are written back as structured comments in the `.fish` completion files themselves. No database, no separate index — the filesystem is the store, consistent with how fish already works.

The annotator hooks into the package manager. When software is installed, new completions are annotated automatically in the background. When software is removed, its completion entries are cleaned up, and any cached Mog scripts that declared a dependency on it are flagged for invalidation. This dependency tracking comes for free from Mog's capability declaration system — every generated script begins with a header declaring what it requires, so the annotator always knows exactly what depends on what.

The annotator also exposes an MCP server. This means any MCP-compatible agent — Claude Code, a coding assistant, any automation tool — can query it for an accurate, current picture of what is available on the local machine. The annotator does not know anything about the shell specifically. It is a grounded knowledge base of local system capabilities with a semantic index on top, and the shell is just its first consumer.

### Mog

Mog is the execution layer. When mogfish encounters genuine natural language intent that has no cached match, it passes the intent to the locally running model along with grounding context from the annotated completions. The model generates a Mog script: a small, statically typed, sandboxed program that declares exactly what it needs to do its job. That declaration — `requires fs, http` or `requires fs` — is enforced before a single line executes. The host decides what the script is allowed to touch. There is no way for a generated Mog script to escape its sandbox, access the filesystem behind the host's back, or crash the process.

The generated script is cached as a plain file with a comment header recording its capability dependencies and the natural language that produced it. A `.fish` completion stub is emitted alongside it, naming the skill and describing its parameters. On every subsequent invocation fish recognises the skill name through its normal completion machinery and the Mog runtime executes the cached script directly, bypassing the model entirely. The skill is now a permanent part of the environment, as fast and native-feeling as anything that shipped with the system.

---

## How the Parts Work Together

Fish is the thing you interact with. The annotator is the thing that knows your machine. Mog is the thing that acts on it safely.

When you type a command fish already knows, nothing changes. When you type something that matches a cached skill — even loosely, because fish's completion suggestions surface it — the Mog runtime runs the cached script. When you type something genuinely new, the input classifier routes it to the annotator's model, which generates a Mog script grounded in the annotator's knowledge of what's actually installed, caches it, registers it with fish, and runs it. The next time you need the same thing, it's a cached skill. The time after that, fish is already suggesting it before you finish typing.

The skill cache is shared. It is not per-session or per-tool. A skill generated interactively at the command line is immediately available to Claude Code via the MCP interface, and a skill exercised by Claude Code is available at the command line. Every use pattern, regardless of which tool produced it, contributes to a single growing library of verified, working, sandboxed capabilities grounded in your actual environment.

---

## Deployment Constraints

Mogfish must run anywhere a shell runs. The inference model targets three deployment classes:

1. **Lightweight VMs** — CPU-only, less than 1GB total RAM budget for the model. This is the hardest target and the one that sets the ceiling on model size. If it fits here, it fits everywhere.
2. **Phones** — ARM processors with on-device AI accelerators (Apple ANE, Qualcomm Hexagon NPU, Samsung NPU). Typically 2–6GB total device RAM. The model must be small enough to share memory with the rest of the system and structured to take advantage of neural engine hardware when available.
3. **PCs** — x86 or ARM with optional GPU (CUDA, Metal, ROCm). The easiest case. If the model runs on a phone it runs here trivially.

The RAM budget is the hard constraint, not the parameter count. The current model — Gemma 3 1B at Q4K quantization — is approximately 700MB on disk, which fits the VM case. If a 1B model can't solve the task (annotation, classification, Mog generation) at sufficient quality, the answer is a larger model with more aggressive quantization, not giving up on the task. The deployment envelope determines what quantization and parameter count combinations are viable. If the quality bar requires a model that can't fit under 1GB at any quantization, the VM RAM ceiling moves — but that's a last resort.

The engine must support multiple inference backends to cover these targets. The current implementation uses a forked mistral.rs with CUDA support, which covers the PC case. Phone and VM deployment will require additional backends (Core ML, ONNX Runtime, or similar) but the model itself — the weights, the fine-tuning, the task structure — is the same across all targets. The `InferenceEngine` trait abstraction exists specifically to make backends swappable without touching the rest of the system.

The skill cache is central to making this work. A 1B model running on a phone NPU is not fast. But it only needs to generate each skill once. After that, execution is a cached Mog script — no inference, no latency, no power draw. The system gets faster with use, and the amortized cost of inference approaches zero.

---

## User Story: Replacing Claude Code's Shell Tools

Claude Code today interacts with the local machine through a set of shell-level tools: it reads and writes files, runs bash commands, searches with ripgrep, and performs git operations. Each of these involves generating and executing arbitrary shell commands with full system access. Claude Code knows your machine only as well as it can infer from context — it does not know what version of git you have, what flags your particular ripgrep supports, or what is actually in your PATH. It generates bash and hopes the model got it right.

With mogfish, this changes.

Imagine a developer, Maya, working on a Python project. She has mogfish installed. She opens a new project directory and starts Claude Code. Claude Code's shell tools are configured to route through the mogfish MCP interface rather than executing bash directly.

Claude Code needs to find all Python files modified in the last week. It queries the annotator: what's available for searching files on this machine? The annotator returns an annotated entry for `fd` — the file finder Maya installed six months ago — including its flags, its behaviour, and the natural language description the annotator generated at install time. Claude Code generates a Mog script that uses `fd` with the correct flags for Maya's installed version, declares `requires process`, and submits it. The mogfish runtime runs the script sandboxed. It works first time because it was grounded in accurate local knowledge rather than a general model prior about what flags `fd` probably supports.

The script is cached as a skill: `find-modified-python`. A `.fish` completion stub is registered.

Later that afternoon Maya is at the command line and wants to do the same thing. She starts typing and fish suggests `find-modified-python` before she finishes. She hits tab. The cached Mog script runs instantly — no model invocation, no bash, no guessing.

The next day Claude Code needs to do a git rebase. It queries the annotator for git capabilities. The annotator returns Maya's git version, its supported flags, and annotations the model generated when git was installed. Claude Code generates a Mog script for the rebase operation, declares `requires fs`, caches it. If the rebase hits a conflict, the capability model means the script can only touch the repository directory it was given access to — it cannot silently reach into other parts of the filesystem.

After a week of normal use — a mix of interactive shell sessions and Claude Code work — Maya's mogfish installation has accumulated dozens of cached skills covering file operations, git workflows, project search patterns, and build tooling. All of them are sandboxed. All of them are grounded in her actual environment. All of them are available to every tool on her machine via the MCP interface. None of them required her to write a single line of shell script.

Claude Code's shell tools have not been replaced in the sense of being removed. They have been replaced in the sense that they now operate through a layer that makes them safer, more accurate, and incrementally smarter with every use. The arbitrary bash execution path still exists as a fallback. But in practice it is rarely reached, because mogfish has already seen — and cached — most of what gets asked of it.
