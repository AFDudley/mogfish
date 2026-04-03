// mogfish-classify — fast-path classifier CLI
//
// See docs/plans/mogfish-outside-in-tdd.md, Layer 6
//
// Takes user input as argument, prints classification to stdout:
//   known:CMD      — first word is a known shell command
//   skill:INTENT   — input matches a cached skill
//   passthrough    — everything else (no model in fast-path mode)

use std::env;
use std::path::PathBuf;

use mogfish_classifier::Classifier;
use mogfish_skill_cache::SkillCache;
use mogfish_traits::{ClassificationCategory, MockInferenceEngine};

/// Default known commands when MOGFISH_KNOWN_COMMANDS is not set.
const DEFAULT_KNOWN_COMMANDS: &[&str] = &[
    "ls", "cd", "cat", "cp", "mv", "rm", "mkdir", "rmdir", "touch", "chmod",
    "chown", "ln", "pwd", "echo", "printf", "test", "true", "false",
    "git", "grep", "find", "sed", "awk", "sort", "uniq", "wc", "head", "tail",
    "less", "more", "man", "which", "type", "command", "set", "export",
    "source", "eval", "exec", "exit", "return", "break", "continue",
    "if", "else", "for", "while", "switch", "case", "function", "end",
    "and", "or", "not", "begin", "string", "math", "status", "count",
    "contains", "read", "bind", "emit", "wait", "jobs", "fg", "bg",
    "kill", "trap", "ulimit", "umask", "builtin", "complete", "abbr",
    "ssh", "scp", "rsync", "curl", "wget", "tar", "zip", "unzip", "gzip",
    "docker", "cargo", "make", "cmake", "npm", "python", "python3", "pip",
    "sudo", "su", "apt", "dnf", "pacman", "brew",
    "vim", "nvim", "nano", "emacs", "code",
    "ps", "top", "htop", "df", "du", "free", "uname", "hostname",
    "ip", "ping", "nc", "ss", "dig", "nslookup",
];

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();
    // Skip leading "--" separator if present
    let input_args = if args.first().map(|a| a.as_str()) == Some("--") {
        &args[1..]
    } else {
        &args[..]
    };
    let input = input_args.join(" ");

    // Empty input → passthrough
    if input.trim().is_empty() {
        println!("passthrough");
        return;
    }

    // Load known commands from env or defaults
    let known_commands: Vec<&str> = if let Ok(val) = env::var("MOGFISH_KNOWN_COMMANDS") {
        // Leak is fine — process exits immediately after printing
        let leaked: &'static str = Box::leak(val.into_boxed_str());
        leaked.split(':').collect()
    } else {
        DEFAULT_KNOWN_COMMANDS.to_vec()
    };

    // Open skill cache
    let data_dir = env::var("MOGFISH_DATA_DIR")
        .map(PathBuf::from)
        .unwrap_or_else(|_| {
            dirs_or_default().join(".mogfish")
        });
    let skills_dir = data_dir.join("skills");
    let cache = match SkillCache::open(&skills_dir) {
        Ok(c) => c,
        Err(_) => {
            println!("passthrough");
            return;
        }
    };

    // Mock engine — fast path never calls it, but Classifier requires one
    let engine = MockInferenceEngine::new();
    let classifier = Classifier::new(&known_commands, &cache, &engine);

    match classifier.classify(&input) {
        Ok(result) => match result.category {
            ClassificationCategory::KnownCommand => {
                println!("known:{}", result.command.unwrap_or_default());
            }
            ClassificationCategory::CachedSkill => {
                // Find matching intent from cache
                if let Ok(skills) = cache.list() {
                    for skill in &skills {
                        if !skill.stale && input.starts_with(&skill.intent) {
                            println!("skill:{}", skill.intent);
                            return;
                        }
                    }
                }
                println!("passthrough");
            }
            _ => println!("passthrough"),
        },
        Err(_) => println!("passthrough"),
    }
}

/// Home directory fallback.
fn dirs_or_default() -> PathBuf {
    env::var("HOME")
        .map(PathBuf::from)
        .unwrap_or_else(|_| PathBuf::from("/tmp"))
}
