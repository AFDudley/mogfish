// mogfish-host — maps Mog capability calls to subprocess invocations
//
// Each .mogdecl capability gets a host implementation that translates
// typed function calls into subprocess invocations with an allowlist.

use std::io::Write;
use std::process::{Command, Stdio};

use anyhow::{bail, Result};

/// Dispatch a capability call to the appropriate subprocess.
///
/// Returns stdout as a string. Errors on unknown capability/function pairs
/// (allowlist enforcement) or subprocess failures.
pub fn call(capability: &str, function: &str, args: &[&str]) -> Result<String> {
    match (capability, function) {
        // git
        ("git", "status") => run("git", &["status"]),
        ("git", "branch") => run("git", &["branch"]),
        ("git", "log") => {
            let mut cmd_args = vec!["log"];
            if let Some(extra) = args.first() {
                cmd_args.extend(extra.split_whitespace());
            }
            run("git", &cmd_args)
        }

        // grep
        ("grep", "search") => run("grep", &[args[0], args[1]]),
        ("grep", "count") => run("grep", &["-c", args[0], args[1]]),

        // find
        ("find", "by_name") => run("find", &[args[1], "-name", args[0]]),

        // sed
        ("sed", "substitute") => {
            let expr = format!("s/{}/{}/", args[0], args[1]);
            pipe_stdin("sed", &[&expr], args[2])
        }
        ("sed", "substitute_all") => {
            let expr = format!("s/{}/{}/g", args[0], args[1]);
            pipe_stdin("sed", &[&expr], args[2])
        }
        ("sed", "delete_matching") => {
            let expr = format!("/{}/d", args[0]);
            pipe_stdin("sed", &[&expr], args[1])
        }

        // awk
        ("awk", "field") => {
            let program = format!("{{print ${}}}", args[0]);
            let delim = format!("-F{}", args[1]);
            pipe_stdin("awk", &[&delim, &program], args[2])
        }
        ("awk", "count_matching") => pipe_stdin("grep", &["-c", args[0]], args[1]),

        // jq
        ("jq", "query") => pipe_stdin("jq", &[args[0]], args[1]),
        ("jq", "keys") => pipe_stdin("jq", &["keys"], args[0]),

        // python3
        ("python3", "eval") => {
            let code = format!("print({})", args[0]);
            run("python3", &["-c", &code])
        }
        ("python3", "exec") => run("python3", &["-c", args[0]]),

        // cargo
        ("cargo", "check") => {
            let manifest = format!("{}/Cargo.toml", args[0]);
            let output = Command::new("cargo")
                .args(["check", "-p", "mogfish-host", "--manifest-path", &manifest])
                .output()?;
            let code = output.status.code().unwrap_or(1);
            Ok(code.to_string())
        }

        // curl
        ("curl", "get") => run("curl", &["-s", args[0]]),

        // Allowlist enforcement
        _ => bail!("unknown capability/function: {capability}/{function}"),
    }
}

/// Run a command and return stdout.
fn run(program: &str, args: &[&str]) -> Result<String> {
    let output = Command::new(program).args(args).output()?;
    Ok(String::from_utf8_lossy(&output.stdout).to_string())
}

/// Run a command with text piped to stdin, return stdout.
fn pipe_stdin(program: &str, args: &[&str], input: &str) -> Result<String> {
    let mut child = Command::new(program)
        .args(args)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()?;

    if let Some(mut stdin) = child.stdin.take() {
        stdin.write_all(input.as_bytes())?;
    }

    let output = child.wait_with_output()?;
    Ok(String::from_utf8_lossy(&output.stdout).to_string())
}
