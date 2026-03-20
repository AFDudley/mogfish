// mogfish-annotator — core annotator library
//
// See docs/plans/mogfish-outside-in-tdd.md, Layer 0-1

use std::fs;
use std::path::Path;

use mogfish_traits::{Annotation, InferenceEngine};

/// Marker that delimits the mog annotation block in a .fish file.
const MOG_BLOCK_START: &str = "# --- mog annotations ---";
const MOG_BLOCK_END: &str = "# --- end mog annotations ---";

/// Result of annotating a single file.
#[derive(Debug)]
pub struct AnnotateResult {
    pub filename: String,
    pub annotated: bool,
    pub error: Option<String>,
}

/// Annotate all .fish files in a directory using the given engine.
///
/// If `dry_run` is true, returns what would change without writing.
pub fn annotate_directory(
    dir: &Path,
    engine: &dyn InferenceEngine,
    dry_run: bool,
) -> anyhow::Result<Vec<AnnotateResult>> {
    let mut results = Vec::new();

    let entries: Vec<_> = fs::read_dir(dir)?
        .filter_map(|e| e.ok())
        .filter(|e| e.path().extension().is_some_and(|ext| ext == "fish"))
        .collect();

    for entry in entries {
        let path = entry.path();
        let filename = path
            .file_name()
            .unwrap_or_default()
            .to_string_lossy()
            .to_string();

        match annotate_file(&path, engine, dry_run) {
            Ok(annotated) => results.push(AnnotateResult {
                filename,
                annotated,
                error: None,
            }),
            Err(e) => {
                tracing::warn!("skipping {}: {e}", path.display());
                results.push(AnnotateResult {
                    filename,
                    annotated: false,
                    error: Some(e.to_string()),
                });
            }
        }
    }

    Ok(results)
}

/// Annotate a single .fish file. Returns true if the file was modified.
fn annotate_file(path: &Path, engine: &dyn InferenceEngine, dry_run: bool) -> anyhow::Result<bool> {
    let content = fs::read_to_string(path)?;

    // Extract command name from filename (e.g., "ls.fish" -> "ls")
    let command_name = path
        .file_stem()
        .unwrap_or_default()
        .to_string_lossy()
        .to_string();

    // Strip existing mog annotation block if present (for idempotency)
    let original_content = strip_mog_block(&content);

    // Get annotation from engine
    let annotation = engine.annotate(&command_name, &original_content)?;

    // Build the annotation block
    let block = format_annotation_block(&annotation);

    // Compose: annotation block + original content
    let annotated = format!("{block}{original_content}");

    // Check if anything changed
    if annotated == content {
        return Ok(false);
    }

    if !dry_run {
        fs::write(path, &annotated)?;
    }

    Ok(true)
}

/// Strip an existing mog annotation block from file content.
/// Returns the original content without the block.
fn strip_mog_block(content: &str) -> String {
    if let Some(start) = content.find(MOG_BLOCK_START) {
        if let Some(end_marker) = content[start..].find(MOG_BLOCK_END) {
            let end = start + end_marker + MOG_BLOCK_END.len();
            // Skip the trailing newline after the block
            let end = if content[end..].starts_with('\n') {
                end + 1
            } else {
                end
            };
            let mut result = String::with_capacity(content.len());
            result.push_str(&content[..start]);
            result.push_str(&content[end..]);
            return result;
        }
    }
    content.to_string()
}

/// Format an Annotation into a mog comment block.
fn format_annotation_block(ann: &Annotation) -> String {
    let mut block = String::new();
    block.push_str(MOG_BLOCK_START);
    block.push('\n');
    block.push_str(&format!("# mog-description: {}\n", ann.description));
    for intent in &ann.intents {
        block.push_str(&format!("# mog-intent: {intent}\n"));
    }
    for flag in &ann.flags {
        block.push_str(&format!("# mog-flags: {} — {}\n", flag.flag, flag.description));
    }
    block.push_str(MOG_BLOCK_END);
    block.push('\n');
    block
}

