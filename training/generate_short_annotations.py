#!/usr/bin/env python3
"""Generate synthetic short-input annotation training examples for mogfish.

Creates minimal-input variants of small .fish completion files to train the
model on short inputs that still produce complete JSON with all three fields.
"""

import json
import re
from pathlib import Path


def extract_command_name(file_path: Path) -> str:
    """Extract command name from .fish filename."""
    return file_path.stem


def parse_fish_file(content: str) -> dict | None:
    """Parse a fish completion file and extract structured data."""
    lines = content.strip().split('\n')

    # Find all complete -c lines
    complete_lines = [line for line in lines if line.strip().startswith('complete -c')]

    if not complete_lines:
        return None

    # Check if it's a wrapper completion (only -w flag, no other flags)
    first_line = complete_lines[0]
    if '-w ' in first_line and '-s ' not in first_line and '-l ' not in first_line and '-d ' not in first_line:
        return None  # Skip wrapper completions

    cmd_name = None
    flags = []
    descriptions = []

    for line in complete_lines:
        # Extract command name
        cmd_match = re.search(r'complete\s+-c\s+(\S+)', line)
        if cmd_match:
            cmd_name = cmd_match.group(1)

        # Extract short flag
        short_flag = None
        short_match = re.search(r'-s\s+(\S+)', line)
        if short_match:
            short_flag = short_match.group(1)

        # Extract long flag
        long_flag = None
        long_match = re.search(r'-l\s+(\S+)', line)
        if long_match:
            long_flag = long_match.group(1)

        # Extract description
        desc_match = re.search(r"-d\s+'([^']*)'", line)
        if not desc_match:
            desc_match = re.search(r'-d\s+"([^"]*)"', line)

        if desc_match:
            desc = desc_match.group(1)
            descriptions.append(desc)

            if short_flag or long_flag:
                flag_str = ""
                if short_flag and long_flag:
                    flag_str = f"-{short_flag}/--{long_flag}"
                elif short_flag:
                    flag_str = f"-{short_flag}"
                elif long_flag:
                    flag_str = f"--{long_flag}"

                if flag_str:
                    flags.append({"flag": flag_str, "description": desc})

    return {
        "cmd_name": cmd_name,
        "flags": flags,
        "descriptions": descriptions,
        "complete_lines": complete_lines
    }


def generate_description(cmd_name: str, parsed: dict) -> str:
    """Generate a plausible description for the command."""
    # Use the first description as a hint if available
    if parsed["descriptions"]:
        first_desc = parsed["descriptions"][0]
        # If it's a general description, use it
        if "help" not in first_desc.lower() and "version" not in first_desc.lower():
            return first_desc

    # Generate a generic description based on command name
    return f"{cmd_name} - command line utility"


def generate_intents(cmd_name: str, parsed: dict) -> list[str]:
    """Generate 3-5 plausible intents for the command."""
    intents = [f"use {cmd_name}"]

    # Add intents based on flags
    for flag_info in parsed["flags"][:4]:
        desc = flag_info["description"].lower()
        if "help" in desc:
            continue
        if "version" in desc:
            continue
        # Create intent from flag description
        intent = desc.replace("display ", "").replace("show ", "").replace("enable ", "").strip()
        if intent and intent not in intents:
            intents.append(intent)

    # Pad to at least 3 intents
    while len(intents) < 3:
        intents.append(f"run {cmd_name}")

    return intents[:5]


def create_variant_a(parsed: dict) -> str:
    """Variant A: stripped - only complete -c lines."""
    return '\n'.join(parsed["complete_lines"])


def create_variant_b(parsed: dict) -> str:
    r"""Variant B: help text only - Command: CMD\n\nCMD - DESCRIPTION."""
    cmd_name = parsed["cmd_name"]
    desc = generate_description(cmd_name, parsed)
    return f"Command: {cmd_name}\n\n{cmd_name} - {desc}"


def create_variant_c(parsed: dict) -> str:
    r"""Variant C: flags only - Command: CMD\n\nFlags:\n  -v/--verbose: ..."""
    cmd_name = parsed["cmd_name"]
    flags_text = f"Command: {cmd_name}\n\nFlags:\n"
    for flag_info in parsed["flags"]:
        flags_text += f"  {flag_info['flag']}: {flag_info['description']}\n"
    return flags_text.rstrip()


def create_annotation(input_text: str, parsed: dict) -> dict:
    """Create the annotation JSON output."""
    cmd_name = parsed["cmd_name"]
    description = generate_description(cmd_name, parsed)
    intents = generate_intents(cmd_name, parsed)
    flags = parsed["flags"]

    output = {
        "description": description,
        "intents": intents,
        "flags": flags
    }

    return {
        "instruction": "Generate a mogfish annotation for this command documentation",
        "input": input_text,
        "output": json.dumps(output)
    }


def process_fish_file(file_path: Path) -> list[dict]:
    """Process a single .fish file and generate all variants."""
    content = file_path.read_text()
    parsed = parse_fish_file(content)

    if not parsed:
        return []

    if not parsed["cmd_name"]:
        return []

    examples = []

    # Variant A: stripped
    variant_a = create_variant_a(parsed)
    if len(variant_a) < 500:
        examples.append(create_annotation(variant_a, parsed))

    # Variant B: help text only (only if we have descriptions)
    if parsed["descriptions"]:
        variant_b = create_variant_b(parsed)
        if len(variant_b) < 500:
            examples.append(create_annotation(variant_b, parsed))

    # Variant C: flags only (only if we have flags)
    if parsed["flags"]:
        variant_c = create_variant_c(parsed)
        if len(variant_c) < 500:
            examples.append(create_annotation(variant_c, parsed))

    return examples


def main():
    """Generate and write synthetic annotation examples."""
    # Find all .fish files under 1KB
    fish_dir = Path("fish/share/completions")
    output_file = Path("training/short_augmented_annotations.jsonl")

    all_examples = []

    # Get all .fish files under 1024 bytes
    for fish_file in sorted(fish_dir.glob("*.fish")):
        if fish_file.stat().st_size >= 1024:
            continue

        try:
            examples = process_fish_file(fish_file)
            all_examples.extend(examples)
        except Exception as e:
            print(f"Error processing {fish_file}: {e}")

    # Write to output file
    with output_file.open("w") as f:
        for example in all_examples:
            f.write(json.dumps(example) + "\n")

    print(f"Generated {len(all_examples)} examples")
    print(f"Output written to {output_file}")


if __name__ == "__main__":
    main()
