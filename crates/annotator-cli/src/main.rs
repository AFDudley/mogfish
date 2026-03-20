// mogfish-annotate CLI — batch and daemon modes
//
// See docs/plans/mogfish-outside-in-tdd.md, Layer 0, 2

use std::path::PathBuf;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::time::Duration;

use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "mogfish-annotate", about = "Annotate fish completions with mog metadata")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Annotate all .fish files in a directory
    Batch {
        /// Directory containing .fish completion files
        #[arg(long)]
        dir: PathBuf,

        /// Inference engine to use (mock, mistralrs)
        #[arg(long, default_value = "mock")]
        engine: String,

        /// Show what would change without writing
        #[arg(long)]
        dry_run: bool,
    },

    /// Watch a directory and annotate new/changed .fish files
    Daemon {
        /// Directory to watch for .fish completion files
        #[arg(long)]
        dir: PathBuf,

        /// Inference engine to use
        #[arg(long, default_value = "mock")]
        engine: String,
    },
}

fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt::init();

    let cli = Cli::parse();

    match cli.command {
        Commands::Batch {
            dir,
            engine,
            dry_run,
        } => {
            let engine = make_engine(&engine)?;
            let results = mogfish_annotator::annotate_directory(&dir, engine.as_ref(), dry_run)?;

            let annotated = results.iter().filter(|r| r.annotated).count();
            let skipped = results.iter().filter(|r| r.error.is_some()).count();
            let unchanged = results.len() - annotated - skipped;

            if dry_run {
                println!(
                    "Dry run: {annotated} would be annotated, {unchanged} unchanged, {skipped} skipped"
                );
            } else {
                println!(
                    "Annotated {annotated} files, {unchanged} unchanged, {skipped} skipped ({} processed)",
                    results.len()
                );
            }

            for r in &results {
                if let Some(err) = &r.error {
                    eprintln!("  warning: {}: {err}", r.filename);
                }
            }
        }

        Commands::Daemon { dir, engine } => {
            let engine = make_engine(&engine)?;
            run_daemon(&dir, engine.as_ref())?;
        }
    }

    Ok(())
}

fn run_daemon(dir: &std::path::Path, engine: &dyn mogfish_traits::InferenceEngine) -> anyhow::Result<()> {
    eprintln!("mogfish-annotate daemon watching: {}", dir.display());

    // Initial scan
    let results = mogfish_annotator::annotate_directory(dir, engine, false)?;
    let annotated = results.iter().filter(|r| r.annotated).count();
    eprintln!("Initial scan: annotated {annotated} files");

    // Set up signal handler for clean shutdown
    let running = Arc::new(AtomicBool::new(true));
    let r = running.clone();
    ctrlc::set_handler(move || {
        r.store(false, Ordering::SeqCst);
    })?;

    // Poll loop — check for new/changed files
    while running.load(Ordering::SeqCst) {
        std::thread::sleep(Duration::from_secs(1));
        if let Ok(results) = mogfish_annotator::annotate_directory(dir, engine, false) {
            let annotated = results.iter().filter(|r| r.annotated).count();
            if annotated > 0 {
                eprintln!("Annotated {annotated} new/changed files");
            }
        }
    }

    eprintln!("Daemon shutting down cleanly");
    Ok(())
}

fn make_engine(name: &str) -> anyhow::Result<Box<dyn mogfish_traits::InferenceEngine>> {
    match name {
        "mock" => Ok(Box::new(mogfish_traits::MockInferenceEngine::new())),
        "mistralrs" => {
            let model_path = std::env::var("MOGFISH_MODEL_PATH")
                .map_err(|_| anyhow::anyhow!("MOGFISH_MODEL_PATH must be set for mistralrs engine"))?;
            let engine = mogfish_engine_mistralrs::MistralRsEngine::from_gguf(std::path::Path::new(&model_path))?;
            Ok(Box::new(engine))
        }
        other => anyhow::bail!("unknown engine: {other}"),
    }
}
