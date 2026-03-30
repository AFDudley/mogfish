#!/usr/bin/env python3
"""Scrape fish completion files from GitHub for training data expansion.

Uses GitHub Code Search API to find .fish completion files, deduplicates
against upstream fish/share/completions/, and downloads unique files.

Usage:
    export GITHUB_TOKEN=ghp_...
    python3 training/scrape_github_completions.py
"""

import json
import hashlib
import os
import subprocess
import sys
import time
from pathlib import Path
from urllib.parse import quote
from urllib.request import Request, urlopen
from urllib.error import HTTPError

UPSTREAM_DIR = Path("fish/share/completions")
OUTPUT_DIR = Path("training/scraped_completions")
MANIFEST = Path("training/scraped_manifest.jsonl")
PROGRESS = Path("training/scrape_progress.json")

# GitHub Code Search queries. Using extension:fish + keywords since
# filename: with quotes requires a different API scope.
# Split by content keywords to get diverse results past the 1000 cap.
QUERIES = [
    "complete extension:fish path:completions",
    "complete extension:fish path:share/completions",
    "complete extension:fish path:fish/completions",
    "complete extension:fish path:conf.d",
]

GITHUB_API = "https://api.github.com"
# Authenticated: 30 search requests/min. Unauthenticated: 10/min.
SEARCH_DELAY = 3.0  # seconds between search page requests
FETCH_DELAY = 0.1   # seconds between raw file fetches


def get_token() -> str:
    """Get GitHub token from gh CLI auth or GITHUB_TOKEN env var."""
    token = os.environ.get("GITHUB_TOKEN", "")
    if token:
        return token
    # Fall back to gh CLI token
    try:
        result = subprocess.run(
            ["gh", "auth", "token"],
            capture_output=True, text=True, check=True,
        )
        return result.stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("ERROR: No GITHUB_TOKEN and gh auth not available", file=sys.stderr)
        sys.exit(1)


def get_upstream_commands() -> set[str]:
    """Get command names from upstream fish completions."""
    commands = set()
    if UPSTREAM_DIR.exists():
        for f in UPSTREAM_DIR.glob("*.fish"):
            commands.add(f.stem)
    print(f"Upstream commands: {len(commands)}")
    return commands


def load_progress() -> dict:
    if PROGRESS.exists():
        with open(PROGRESS) as f:
            return json.load(f)
    return {"completed_queries": [], "seen_urls": []}


def save_progress(progress: dict):
    with open(PROGRESS, "w") as f:
        json.dump(progress, f)


def load_manifest() -> dict[str, dict]:
    """Load existing manifest keyed by command name."""
    manifest = {}
    if MANIFEST.exists():
        with open(MANIFEST) as f:
            for line in f:
                entry = json.loads(line)
                manifest[entry["command"]] = entry
    return manifest


def github_search(token: str, query: str, page: int = 1) -> dict:
    """Search GitHub code. Returns parsed JSON response."""
    url = f"{GITHUB_API}/search/code?q={quote(query)}&per_page=100&page={page}"
    req = Request(url)
    req.add_header("Authorization", f"token {token}")
    req.add_header("Accept", "application/vnd.github.v3+json")
    req.add_header("User-Agent", "mogfish-scraper")

    try:
        with urlopen(req) as resp:
            return json.loads(resp.read())
    except HTTPError as e:
        if e.code == 403:
            # Rate limited — wait and retry
            reset = int(e.headers.get("X-RateLimit-Reset", 0))
            wait = max(reset - int(time.time()), 60)
            print(f"  Rate limited, waiting {wait}s...")
            time.sleep(wait)
            return github_search(token, query, page)
        raise


def fetch_raw(url: str, token: str) -> str | None:
    """Fetch raw file content from GitHub."""
    req = Request(url)
    req.add_header("Authorization", f"token {token}")
    req.add_header("User-Agent", "mogfish-scraper")

    try:
        with urlopen(req) as resp:
            return resp.read().decode("utf-8", errors="replace")
    except HTTPError:
        return None


def extract_command_name(filename: str, content: str) -> str | None:
    """Extract the command name from a fish completion file."""
    # Prefer filename stem
    stem = Path(filename).stem
    if stem and stem != "completions":
        return stem

    # Fallback: parse first "complete -c CMD" line
    for line in content.split("\n"):
        line = line.strip()
        if line.startswith("complete") and " -c " in line:
            parts = line.split(" -c ")
            if len(parts) >= 2:
                cmd = parts[1].split()[0].strip('"').strip("'")
                if cmd:
                    return cmd
    return None


def main():
    token = get_token()
    upstream = get_upstream_commands()
    progress = load_progress()
    manifest = load_manifest()

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    total_new = 0
    total_skipped = 0
    total_dup = 0

    for query in QUERIES:
        if query in progress["completed_queries"]:
            print(f"Skipping completed query: {query}")
            continue

        print(f"\nQuery: {query}")

        page = 1
        while page <= 10:  # GitHub caps at 10 pages
            print(f"  Page {page}...", end=" ", flush=True)
            result = github_search(token, query, page)

            items = result.get("items", [])
            if not items:
                print("no results")
                break

            print(f"{len(items)} results (total: {result.get('total_count', '?')})")

            for item in items:
                html_url = item.get("html_url", "")
                raw_url = html_url.replace("github.com", "raw.githubusercontent.com").replace("/blob/", "/")

                if raw_url in progress["seen_urls"]:
                    total_skipped += 1
                    continue

                progress["seen_urls"].append(raw_url)

                # Fetch content
                time.sleep(FETCH_DELAY)
                content = fetch_raw(raw_url, token)
                if content is None:
                    continue

                # Extract command name
                filename = item.get("name", "")
                command = extract_command_name(filename, content)
                if not command:
                    continue

                # Dedup against upstream and already-scraped
                if command in upstream:
                    total_dup += 1
                    continue
                if command in manifest:
                    total_dup += 1
                    continue

                # Validate it's actually a fish completion
                if "complete " not in content and "complete\t" not in content:
                    continue

                # Save
                out_path = OUTPUT_DIR / f"{command}.fish"
                out_path.write_text(content)

                sha = hashlib.sha256(content.encode()).hexdigest()
                entry = {
                    "command": command,
                    "source_url": html_url,
                    "size_bytes": len(content.encode()),
                    "sha256": sha,
                    "short": len(content.encode()) < 1024,
                }
                manifest[command] = entry

                with open(MANIFEST, "a") as f:
                    f.write(json.dumps(entry) + "\n")

                total_new += 1

            page += 1
            time.sleep(SEARCH_DELAY)

            # Save progress after each page
            save_progress(progress)

        progress["completed_queries"].append(query)
        save_progress(progress)

    print(f"\nDone. New: {total_new}, Duplicates: {total_dup}, Skipped: {total_skipped}")
    print(f"Total in manifest: {len(manifest)}")

    # Print size distribution
    sizes = [e["size_bytes"] for e in manifest.values()]
    short = sum(1 for s in sizes if s < 1024)
    medium = sum(1 for s in sizes if 1024 <= s < 5000)
    large = sum(1 for s in sizes if s >= 5000)
    print(f"Size distribution: {short} short (<1KB), {medium} medium (1-5KB), {large} large (>5KB)")


if __name__ == "__main__":
    main()
