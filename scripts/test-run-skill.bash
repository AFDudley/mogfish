#!/usr/bin/env bash
# Acceptance test: __mogfish_run_skill executes a cached Mog skill
#
# Creates a real skill cache, stores a real Mog program, calls
# __mogfish_run_skill in fish, asserts the compiled binary's stdout.
#
# Prerequisites: mogc on PATH, jq on PATH, fish with mogfish functions installed

set -uo pipefail

MOGC="${MOGC:-mogc}"
PASS=0
FAIL=0

fail() { echo "FAIL: $1"; FAIL=$((FAIL + 1)); }
pass() { echo "PASS: $1"; PASS=$((PASS + 1)); }

# --- Setup: create a skill cache with a trivial Mog program ---
TEST_DIR=$(mktemp -d)
SKILL_DIR="$TEST_DIR/skills"
mkdir -p "$SKILL_DIR"

# Write skill JSON matching Rust SkillCache format
# Slug of "test skill" = "test-skill"
cat > "$SKILL_DIR/test-skill.json" << 'SKILLJSON'
{
  "intent": "test skill",
  "mog_script": "fn main() { print_string(\"skill-executed-ok\"); println(); }",
  "dependencies": [],
  "stale": false
}
SKILLJSON

# --- Test 1: __mogfish_run_skill produces expected output ---
name="skill execution produces mog program output"
out=$(MOGFISH_DATA_DIR="$TEST_DIR" fish -c '__mogfish_run_skill "test skill"' 2>&1) || true
if echo "$out" | grep -q "skill-executed-ok"; then
    pass "$name"
else
    fail "$name — got: $out"
fi

# --- Test 2: exit code is 0 on success ---
name="skill execution exits 0"
MOGFISH_DATA_DIR="$TEST_DIR" fish -c '__mogfish_run_skill "test skill"' >/dev/null 2>&1
rc=$?
if [ "$rc" -eq 0 ]; then
    pass "$name"
else
    fail "$name — got exit code $rc"
fi

# --- Test 3: missing skill fails fast ---
name="missing skill fails with nonzero exit"
rc=0
MOGFISH_DATA_DIR="$TEST_DIR" fish -c '__mogfish_run_skill "nonexistent skill"' >/dev/null 2>&1 || rc=$?
if [ "$rc" -ne 0 ]; then
    pass "$name"
else
    fail "$name — expected nonzero exit"
fi

# --- Test 4: compiled binary is cached (second run skips compilation) ---
name="compiled binary is cached on disk"
MOGFISH_DATA_DIR="$TEST_DIR" fish -c '__mogfish_run_skill "test skill"' >/dev/null 2>&1 || true
if [ -f "$TEST_DIR/compiled/test-skill" ]; then
    pass "$name"
else
    fail "$name — no cached binary at $TEST_DIR/compiled/test-skill"
fi

# --- Cleanup ---
rm -rf "$TEST_DIR"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
