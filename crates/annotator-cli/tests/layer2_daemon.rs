// Layer 2 acceptance tests — daemon mode
//
// The daemon watches a directory for new/changed .fish files
// and annotates them automatically.
//
// See docs/plans/mogfish-outside-in-tdd.md, Layer 2

use std::fs;
use std::process::{Child, Command};
use std::time::Duration;
use std::thread;

use tempfile::TempDir;

fn bin() -> String {
    env!("CARGO_BIN_EXE_mogfish-annotate").to_string()
}

/// Start daemon, drop a .fish file, verify it gets annotated.
#[test]
fn daemon_annotates_new_file() {
    let tmp = TempDir::new().unwrap();

    // Start daemon in background
    let mut daemon = start_daemon(tmp.path());

    // Give daemon time to start
    thread::sleep(Duration::from_millis(500));

    // Drop a new .fish file
    fs::write(
        tmp.path().join("newcmd.fish"),
        "complete -c newcmd -s h -d 'help'\n",
    )
    .unwrap();

    // Wait for daemon to pick it up
    thread::sleep(Duration::from_secs(3));

    // Check annotation
    let content = fs::read_to_string(tmp.path().join("newcmd.fish")).unwrap();
    assert!(
        content.contains("# mog-description:"),
        "daemon should have annotated the new file",
    );

    // Clean shutdown
    daemon.kill().ok();
    daemon.wait().ok();
}

/// Daemon should exit cleanly on SIGTERM.
#[test]
fn daemon_clean_shutdown() {
    let tmp = TempDir::new().unwrap();
    let mut daemon = start_daemon(tmp.path());

    thread::sleep(Duration::from_millis(500));

    // Send SIGTERM
    unsafe {
        libc::kill(daemon.id() as i32, libc::SIGTERM);
    }

    let status = daemon.wait().unwrap();
    assert!(
        status.success(),
        "daemon should exit 0 on SIGTERM, got: {status}",
    );
}

fn start_daemon(dir: &std::path::Path) -> Child {
    Command::new(bin())
        .args([
            "daemon",
            "--dir",
            dir.to_str().unwrap(),
            "--engine",
            "mock",
        ])
        .spawn()
        .expect("failed to start daemon")
}
