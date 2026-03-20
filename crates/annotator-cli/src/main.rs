// mogfish-annotate CLI — batch and daemon modes
//
// See docs/plans/mogfish-outside-in-tdd.md, Layer 0

use std::path::PathBuf;

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
    }

    Ok(())
}

fn make_engine(name: &str) -> anyhow::Result<Box<dyn mogfish_traits::InferenceEngine>> {
    match name {
        "mock" => Ok(Box::new(mogfish_traits::MockInferenceEngine::new())),
        other => anyhow::bail!("unknown engine: {other}"),
    }
}
