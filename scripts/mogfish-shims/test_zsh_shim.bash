#!/usr/bin/env bash
# Acceptance tests for the mogfish zsh shim.
#
# Reproduces the exact argument patterns Claude Code sends.
# Each test calls the shim the same way Claude Code does:
#   shim -c -l 'setopt ... && eval '"'"'ACTUAL_CMD'"'"' < /dev/null && pwd ...'
#   shim -c -l 'setopt ... && eval '"'"'ACTUAL_CMD'"'"' && pwd ...'  (no < /dev/null)
#
# Tests verify the shim extracts ACTUAL_CMD correctly and runs it in fish.

set -uo pipefail

SHIM="$(cd "$(dirname "$0")" && pwd)/zsh"
PASS=0
FAIL=0
CWD_FILE="/tmp/claude-test0-cwd"

fail() {
    echo "FAIL: $1"
    FAIL=$((FAIL + 1))
}

pass() {
    echo "PASS: $1"
    PASS=$((PASS + 1))
}

# Helper: invoke shim exactly as Claude Code does (with < /dev/null suffix)
run_with_devnull() {
    local cmd="$1"
    "$SHIM" -c -l "setopt NO_EXTENDED_GLOB 2>/dev/null || true && eval '$cmd' < /dev/null && pwd -P >| $CWD_FILE"
}

# Helper: invoke shim as Claude Code does (WITHOUT < /dev/null suffix)
run_without_devnull() {
    local cmd="$1"
    "$SHIM" -c -l "setopt NO_EXTENDED_GLOB 2>/dev/null || true && eval '$cmd' && pwd -P >| $CWD_FILE"
}

# --- Test 1: Simple command (with < /dev/null) ---
name="simple echo (with /dev/null)"
out=$(run_with_devnull "echo hello" 2>&1) || true
if echo "$out" | grep -q "hello"; then
    pass "$name"
else
    fail "$name — got: $out"
fi

# --- Test 2: Simple command (without < /dev/null) ---
name="simple echo (no /dev/null)"
out=$(run_without_devnull "echo hello" 2>&1) || true
if echo "$out" | grep -q "hello"; then
    pass "$name"
else
    fail "$name — got: $out"
fi

# --- Test 3: Command with parentheses (with < /dev/null) ---
name="parentheses in args (with /dev/null)"
out=$(run_with_devnull 'echo "Claude Opus 4.6 (1M context)"' 2>&1) || true
if echo "$out" | grep -q "(1M context)"; then
    pass "$name"
else
    fail "$name — got: $out"
fi

# --- Test 4: Command with parentheses (without < /dev/null) ---
name="parentheses in args (no /dev/null)"
out=$(run_without_devnull 'echo "Claude Opus 4.6 (1M context)"' 2>&1) || true
if echo "$out" | grep -q "(1M context)"; then
    pass "$name"
else
    fail "$name — got: $out"
fi

# --- Test 5: Multiple -m flags with special chars ---
name="git-style multiple -m with parens and angle brackets"
out=$(run_without_devnull 'echo first && echo "Co-Authored-By: Test (1M) <test@test.com>"' 2>&1) || true
if echo "$out" | grep -q "Co-Authored-By"; then
    pass "$name"
else
    fail "$name — got: $out"
fi

# --- Test 6: Command with double-quoted string containing special chars ---
name="double-quoted string with apostrophe and angle brackets"
# Claude Code uses double quotes to avoid single-quote escaping issues
out=$(run_without_devnull 'echo "it'\''s a test <user@host>"' 2>&1) || true
if echo "$out" | grep -q "it's a test"; then
    pass "$name"
else
    fail "$name — got: $out"
fi

# --- Test 6c: printf with single-quoted arg containing parens (eval escape) ---
name="printf with single-quoted arg via eval escape"
# Claude Code wraps: eval 'printf '"'"'(1M context)\n'"'"''
# The shim must un-escape '"'"' → ' before re-execution
out=$("$SHIM" -c -l "setopt NO_EXTENDED_GLOB 2>/dev/null || true && eval 'printf '\"'\"'(1M context)\n'\"'\"'' && pwd -P >| $CWD_FILE" 2>&1) || true
if echo "$out" | grep -q "(1M context)"; then
    pass "$name"
else
    fail "$name — got: $out"
fi

# --- Test 6b: Command with parentheses in single-quoted string ---
name="parentheses inside printf single-quoted arg"
out=$(run_without_devnull "printf '(1M context)\n'" 2>&1) || true
if echo "$out" | grep -q "(1M context)"; then
    pass "$name"
else
    fail "$name — got: $out"
fi

# --- Test 7: Exit code preservation ---
name="exit code preserved on failure"
rc=0
run_without_devnull "false" >/dev/null 2>&1 || rc=$?
if [ "$rc" -ne 0 ]; then
    pass "$name"
else
    fail "$name — expected nonzero exit, got $rc"
fi

# --- Test 8: Non-Claude invocation passes through ---
name="non-Claude args pass through to real zsh"
out=$("$SHIM" -c "echo zsh-passthrough" 2>&1) || true
if echo "$out" | grep -q "zsh-passthrough"; then
    pass "$name"
else
    fail "$name — got: $out"
fi

# --- Summary ---
echo ""
echo "Results: $PASS passed, $FAIL failed"
rm -f "$CWD_FILE"
[ "$FAIL" -eq 0 ]
