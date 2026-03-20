use std::env;
use std::fs;
use std::path::PathBuf;
use std::process;

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();

    let mut check_mode = false;
    let mut file_args: Vec<String> = Vec::new();

    for arg in &args {
        if arg == "--check" {
            check_mode = true;
        } else {
            file_args.push(arg.clone());
        }
    }

    let files: Vec<PathBuf> = if file_args.is_empty() {
        // Find all .mog files in current directory
        match fs::read_dir(".") {
            Ok(entries) => {
                let mut paths: Vec<PathBuf> = entries
                    .filter_map(|e| e.ok())
                    .map(|e| e.path())
                    .filter(|p| p.extension().map_or(false, |ext| ext == "mog"))
                    .collect();
                paths.sort();
                paths
            }
            Err(e) => {
                eprintln!("Error reading current directory: {}", e);
                process::exit(1);
            }
        }
    } else {
        file_args.iter().map(PathBuf::from).collect()
    };

    if files.is_empty() {
        eprintln!("No .mog files found.");
        process::exit(1);
    }

    let mut any_unformatted = false;

    for filepath in &files {
        match format_file(filepath, check_mode) {
            Ok(was_changed) => {
                if check_mode && was_changed {
                    any_unformatted = true;
                }
            }
            Err(e) => {
                eprintln!("Error formatting {}: {}", filepath.display(), e);
                process::exit(1);
            }
        }
    }

    if check_mode && any_unformatted {
        process::exit(1);
    }
}

fn format_file(filepath: &PathBuf, check_mode: bool) -> Result<bool, String> {
    let content = fs::read_to_string(filepath)
        .map_err(|e| format!("Failed to read {}: {}", filepath.display(), e))?;

    let formatted = format_mog(&content);

    if check_mode {
        if content == formatted {
            println!("{}: ok", filepath.display());
            return Ok(false);
        } else {
            println!("{}: needs formatting", filepath.display());
            print_diff(&content, &formatted);
            return Ok(true);
        }
    }

    fs::write(filepath, &formatted)
        .map_err(|e| format!("Failed to write {}: {}", filepath.display(), e))?;

    println!("Formatted {}", filepath.display());
    Ok(false)
}

/// Analyze braces in a line, ignoring braces inside string literals,
/// single-line comments, and multi-line comments.
///
/// Returns (min_balance, final_balance) where balance tracks the running
/// count of opens minus closes. min_balance is the lowest the balance goes
/// (used to determine how much to dedent this line), and final_balance is
/// the net change (used to set indent for the next line).
fn analyze_braces(line: &str, in_block_comment: &mut bool) -> (i32, i32) {
    let mut balance: i32 = 0;
    let mut min_balance: i32 = 0;
    let chars: Vec<char> = line.chars().collect();
    let len = chars.len();
    let mut i = 0;
    let mut in_string = false;

    while i < len {
        // Inside a block comment: look for */
        if *in_block_comment {
            if i + 1 < len && chars[i] == '*' && chars[i + 1] == '/' {
                *in_block_comment = false;
                i += 2;
            } else {
                i += 1;
            }
            continue;
        }

        let ch = chars[i];

        // String literal handling
        if in_string {
            if ch == '\\' {
                // Skip escaped character
                i += 2;
                continue;
            }
            if ch == '"' {
                in_string = false;
            }
            i += 1;
            continue;
        }

        // Start of single-line comment
        if ch == '/' && i + 1 < len && chars[i + 1] == '/' {
            // Rest of line is a comment, stop processing
            break;
        }

        // Start of block comment
        if ch == '/' && i + 1 < len && chars[i + 1] == '*' {
            *in_block_comment = true;
            i += 2;
            continue;
        }

        // Start of string (also handles f"...")
        if ch == '"' {
            in_string = true;
            i += 1;
            continue;
        }
        if ch == 'f' && i + 1 < len && chars[i + 1] == '"' {
            in_string = true;
            i += 2;
            continue;
        }

        // Track brace balance
        if ch == '{' {
            balance += 1;
        } else if ch == '}' {
            balance -= 1;
            if balance < min_balance {
                min_balance = balance;
            }
        }

        i += 1;
    }

    (min_balance, balance)
}

fn format_mog(content: &str) -> String {
    let lines: Vec<&str> = content.split('\n').collect();
    let mut indent_level: i32 = 0;
    let mut formatted: Vec<String> = Vec::new();
    let mut in_block_comment = false;

    for line in &lines {
        let stripped = line.trim();

        if stripped.is_empty() {
            formatted.push(String::new());
            continue;
        }

        let (min_balance, final_balance) = analyze_braces(stripped, &mut in_block_comment);

        // If line has leading closes (min_balance < 0), dedent this line
        // e.g., "}" has min=-1, final=-1; "} else {" has min=-1, final=0
        let dedent = if min_balance < 0 { -min_balance } else { 0 };
        let this_indent = (indent_level - dedent).max(0);

        // Output with indent
        let line_indent = (this_indent * 2) as usize;
        formatted.push(format!("{}{}", " ".repeat(line_indent), stripped));

        // Update indent for next line based on net brace change
        indent_level = (indent_level + final_balance).max(0);
    }

    // Post-process: remove trailing whitespace from each line
    let formatted: Vec<String> = formatted.iter().map(|l| l.trim_end().to_string()).collect();

    // Collapse consecutive empty lines to at most one
    let mut cleaned: Vec<String> = Vec::new();
    let mut prev_empty = false;
    for line in &formatted {
        if line.trim().is_empty() {
            if !prev_empty {
                cleaned.push(String::new());
            }
            prev_empty = true;
        } else {
            cleaned.push(line.clone());
            prev_empty = false;
        }
    }

    // Remove leading empty lines
    while !cleaned.is_empty() && cleaned[0].trim().is_empty() {
        cleaned.remove(0);
    }

    // Remove trailing empty lines
    while !cleaned.is_empty() && cleaned.last().unwrap().trim().is_empty() {
        cleaned.pop();
    }

    // Join with newline and add trailing newline
    if cleaned.is_empty() {
        String::new()
    } else {
        let mut result = cleaned.join("\n");
        result.push('\n');
        result
    }
}

fn print_diff(original: &str, formatted: &str) {
    let orig_lines: Vec<&str> = original.lines().collect();
    let fmt_lines: Vec<&str> = formatted.lines().collect();

    let max_lines = orig_lines.len().max(fmt_lines.len());
    let mut printed_header = false;

    for i in 0..max_lines {
        let orig = orig_lines.get(i).copied().unwrap_or("");
        let fmt = fmt_lines.get(i).copied().unwrap_or("");

        if orig != fmt {
            if !printed_header {
                println!("  Diff:");
                printed_header = true;
            }
            println!("  line {}: ", i + 1);
            println!("    - {}", orig);
            println!("    + {}", fmt);
        }
    }
}
