#!/usr/bin/env python3
"""Generate mogfish annotation training data from fish completion files.

Parses fish completion files to extract command descriptions, intents, and flags,
then generates instruction-tuning JSONL records.
"""

import json
import re
import sys
from pathlib import Path

# Directories
COMPLETIONS_DIR = Path("fish/share/completions")
OUTPUT_DIR = Path("training/scraped_annotations")

# Batch size for output files
BATCH_SIZE = 20


def parse_complete_line(line: str) -> dict[str, str] | None:
    """Parse a fish complete line to extract flag and description.

    Returns dict with 'flag' and 'description' keys, or None if not a complete line.
    """
    # Match: complete -c CMD [-s X] [-l LONGNAME] -d "description"
    # We want to extract the flag(s) and description

    short_match = re.search(r'-s\s+(\S+)', line)
    long_match = re.search(r'-l\s+(\S+)', line)
    desc_match = re.search(r'-d\s+["\']([^"\']+)["\']', line)

    if not desc_match:
        return None

    description = desc_match.group(1)

    # Build flag string
    flag_parts = []
    if short_match:
        flag_parts.append(f"-{short_match.group(1)}")
    if long_match:
        flag_parts.append(f"--{long_match.group(1)}")

    if not flag_parts:
        return None

    flag = "/".join(flag_parts)

    return {"flag": flag, "description": description}


def extract_flags_from_fish_file(content: str) -> list[dict[str, str]]:
    """Extract flags from fish completion file content."""
    flags = []
    seen = set()

    for line in content.split('\n'):
        line = line.strip()
        if not line or line.startswith('#'):
            continue

        if 'complete -c' in line:
            flag_info = parse_complete_line(line)
            if flag_info:
                # Deduplicate by flag name
                if flag_info['flag'] not in seen:
                    seen.add(flag_info['flag'])
                    flags.append(flag_info)

    return flags


def generate_description(command: str, flags: list[dict[str, str]]) -> str:
    """Generate a description for the command based on name and flags.

    This is a simple heuristic-based approach since we don't have access to
    man pages or the actual command documentation.
    """
    # Common command patterns
    command_descriptions = {
        'git': 'Distributed version control system',
        'ls': 'List directory contents',
        'grep': 'Search for patterns in files',
        'find': 'Search for files in a directory hierarchy',
        'cat': 'Concatenate and print files',
        'sed': 'Stream editor for filtering and transforming text',
        'awk': 'Pattern scanning and processing language',
        'tar': 'Archive files',
        'ssh': 'Secure shell remote login client',
        'scp': 'Secure copy files between hosts',
        'curl': 'Transfer data from or to a server',
        'wget': 'Download files from the web',
        'docker': 'Container platform for building and running applications',
        'npm': 'Node package manager',
        'pip': 'Python package installer',
        'apt': 'Package manager for Debian-based systems',
        'systemctl': 'Control the systemd system and service manager',
        'chmod': 'Change file mode bits',
        'chown': 'Change file owner and group',
        'ps': 'Report process status',
        'kill': 'Send signals to processes',
        'top': 'Display Linux processes',
        'df': 'Report file system disk space usage',
        'du': 'Estimate file space usage',
        'mount': 'Mount a filesystem',
        'umount': 'Unmount filesystems',
    }

    if command in command_descriptions:
        return command_descriptions[command]

    # Generic description based on command name
    return f"Command-line tool: {command}"


def generate_intents(command: str, description: str) -> list[str]:
    """Generate natural language intents for the command."""
    # Base intents on the command name and description
    intents = [
        f"run {command}",
        f"use {command}",
        f"{command}",
    ]

    # Add description-based intents
    desc_lower = description.lower()

    # Extract key verbs/actions from description
    if 'list' in desc_lower:
        intents.append(f"list with {command}")
    if 'search' in desc_lower or 'find' in desc_lower:
        intents.append(f"search using {command}")
    if 'display' in desc_lower or 'show' in desc_lower:
        intents.append(f"display using {command}")
    if 'download' in desc_lower or 'fetch' in desc_lower or 'get' in desc_lower:
        intents.append(f"download with {command}")
    if 'install' in desc_lower:
        intents.append(f"install using {command}")
    if 'manage' in desc_lower or 'control' in desc_lower:
        intents.append(f"manage with {command}")
    if 'edit' in desc_lower or 'modify' in desc_lower:
        intents.append(f"edit using {command}")
    if 'copy' in desc_lower:
        intents.append(f"copy with {command}")
    if 'transfer' in desc_lower:
        intents.append(f"transfer using {command}")
    if 'archive' in desc_lower:
        intents.append(f"archive with {command}")

    # Ensure we have between 3-10 intents
    if len(intents) < 3:
        intents.extend([
            f"execute {command}",
            f"{command} command",
            f"invoke {command}",
        ])

    # Return up to 10 unique intents
    return list(dict.fromkeys(intents))[:10]


def create_annotation(command: str, content: str) -> dict | None:
    """Create a mogfish annotation from a fish completion file."""
    # Skip very small files (likely empty or trivial)
    if len(content.strip()) < 20:
        return None

    # Extract flags
    flags = extract_flags_from_fish_file(content)

    # Generate description
    description = generate_description(command, flags)

    # Generate intents
    intents = generate_intents(command, description)

    # Ensure we have at least 3 intents
    if len(intents) < 3:
        return None

    # Limit to top 10 most common flags
    flags = flags[:10]

    # Build the annotation object
    annotation = {
        "description": description,
        "intents": intents,
        "flags": flags,
    }

    return annotation


def validate_annotation(ann: dict) -> bool:
    """Validate an annotation matches the required schema."""
    if not isinstance(ann.get("description"), str) or not ann["description"]:
        return False
    if not isinstance(ann.get("intents"), list) or len(ann["intents"]) < 3:
        return False
    if not isinstance(ann.get("flags"), list):
        return False
    for flag in ann["flags"]:
        if not isinstance(flag, dict) or "flag" not in flag or "description" not in flag:
            return False
    return True


def main() -> int:
    """Generate annotations and write to batch files."""
    # Find all fish completion files
    fish_files = sorted(COMPLETIONS_DIR.glob("*.fish"))
    print(f"Found {len(fish_files)} fish completion files")

    # Create output directory
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Process files and generate annotations
    examples = []
    skipped = 0
    invalid = 0

    for filepath in fish_files:
        command = filepath.stem
        try:
            content = filepath.read_text(errors='replace')

            # Create annotation
            annotation = create_annotation(command, content)

            if annotation is None:
                skipped += 1
                continue

            # Validate annotation
            if not validate_annotation(annotation):
                invalid += 1
                print(f"  INVALID: {command}", file=sys.stderr)
                continue

            # Create instruction-tuning example
            example = {
                "instruction": "Generate a mogfish annotation for this command documentation",
                "input": f"Command: {command}\n\n{content}",
                "output": json.dumps(annotation, ensure_ascii=False),
            }

            examples.append(example)

        except Exception as e:
            print(f"  ERROR processing {command}: {e}", file=sys.stderr)
            skipped += 1

    print(f"\nGenerated {len(examples)} valid examples ({invalid} invalid, {skipped} skipped)")

    # Write examples to batch files
    batch_num = 1
    for i in range(0, len(examples), BATCH_SIZE):
        batch = examples[i:i + BATCH_SIZE]
        output_file = OUTPUT_DIR / f"batch_{batch_num:03d}.jsonl"

        with open(output_file, 'w') as f:
            for example in batch:
                f.write(json.dumps(example, ensure_ascii=False) + '\n')

        print(f"Wrote {len(batch)} examples to {output_file}")
        batch_num += 1

    print(f"\nTotal: {len(examples)} annotations written to {batch_num - 1} batch files")
    return 0


if __name__ == "__main__":
    sys.exit(main())
