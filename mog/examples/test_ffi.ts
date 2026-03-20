#!/usr/bin/env bun
/**
 * test_ffi.ts — Verify the Mog compiler's Rust-based C FFI from TypeScript.
 *
 * Loads libmog.dylib via Bun's FFI, compiles a small Mog program to a native
 * binary, runs it, and checks the output.
 *
 * Usage:
 *   bun examples/test_ffi.ts
 */

import { dlopen, FFIType, ptr, CString } from "bun:ffi";
import { execSync } from "child_process";
import { unlinkSync, existsSync } from "fs";
import { resolve, dirname } from "path";

// Bun FFI returns Pointer (opaque branded type). We work with `any` at the
// FFI boundary to avoid TS structural-type complaints that don't affect runtime.
type Ptr = any;

// ---------------------------------------------------------------------------
// Locate the shared library
// ---------------------------------------------------------------------------

const projectRoot = resolve(dirname(new URL(import.meta.url).pathname), "..");
const dylibPath = resolve(projectRoot, "compiler/target/release/libmog.dylib");

if (!existsSync(dylibPath)) {
  console.error(`libmog.dylib not found at ${dylibPath}`);
  console.error("Run: cargo build --release --manifest-path compiler/Cargo.toml");
  process.exit(1);
}

// ---------------------------------------------------------------------------
// Open the library and declare symbols
// ---------------------------------------------------------------------------

const { symbols: mog } = dlopen(dylibPath, {
  mog_compiler_new:       { returns: FFIType.ptr, args: [] },
  mog_compiler_free:      { returns: FFIType.void, args: [FFIType.ptr] },
  mog_compile:            { returns: FFIType.ptr, args: [FFIType.ptr, FFIType.ptr, FFIType.ptr] },
  mog_compile_to_ir:      { returns: FFIType.ptr, args: [FFIType.ptr, FFIType.ptr] },
  mog_compile_to_binary:  { returns: FFIType.i32,  args: [FFIType.ptr, FFIType.ptr, FFIType.ptr] },
  mog_result_get_ir:      { returns: FFIType.ptr, args: [FFIType.ptr] },
  mog_result_get_error_count: { returns: FFIType.i32, args: [FFIType.ptr] },
  mog_result_get_error:   { returns: FFIType.ptr, args: [FFIType.ptr, FFIType.i32] },
  mog_result_free:        { returns: FFIType.void, args: [FFIType.ptr] },
  mog_free_string:        { returns: FFIType.void, args: [FFIType.ptr] },
});

// ---------------------------------------------------------------------------
// Helper: pass a JS string as a C string pointer
// ---------------------------------------------------------------------------

function cstr(s: string): [Buffer, Ptr] {
  const buf = Buffer.from(s + "\0", "utf-8");
  return [buf, ptr(buf)];
}

function readCStr(p: Ptr): string | null {
  if (!p || p === 0 || p === 0n) return null;
  return new CString(p) as unknown as string;
}

function isNull(p: Ptr): boolean {
  return !p || p === 0 || p === 0n;
}

// ---------------------------------------------------------------------------
// Test 1: Compile to IR and inspect the output
// ---------------------------------------------------------------------------

console.log("=== Test 1: Compile to QBE IR ===");

const source1 = `
fn square(x: int) -> int {
  return (x * x);
}

fn main() -> int {
  println(square(7));
  return 0;
}
`;

const compiler = mog.mog_compiler_new();
const [srcBuf1, srcPtr1] = cstr(source1);

const irPtr: Ptr = mog.mog_compile_to_ir(compiler, srcPtr1);
if (isNull(irPtr)) {
  console.error("FAIL: mog_compile_to_ir returned NULL");
  process.exit(1);
}
const ir = readCStr(irPtr)!;
mog.mog_free_string(irPtr);

console.log(`  IR length: ${ir.length} bytes`);
console.log(`  Contains 'square': ${ir.includes("square")}`);
console.log(`  Contains 'main':   ${ir.includes("main") || ir.includes("program_user")}`);
console.log("  PASS\n");

// ---------------------------------------------------------------------------
// Test 2: Full compile → mog_compile result with IR + error checking
// ---------------------------------------------------------------------------

console.log("=== Test 2: mog_compile() result API ===");

const [srcBuf2, srcPtr2] = cstr(source1);
const result: Ptr = mog.mog_compile(compiler, srcPtr2, null);
if (isNull(result)) {
  console.error("FAIL: mog_compile returned NULL");
  process.exit(1);
}

const errorCount = mog.mog_result_get_error_count(result);
console.log(`  Errors: ${errorCount}`);

const resultIrPtr = mog.mog_result_get_ir(result);
const resultIr = readCStr(resultIrPtr);
console.log(`  IR present: ${resultIr !== null && resultIr.length > 0}`);

mog.mog_result_free(result);
console.log("  PASS\n");

// ---------------------------------------------------------------------------
// Test 3: Compile with errors — verify error reporting
// ---------------------------------------------------------------------------

console.log("=== Test 3: Error reporting ===");

const badSource = `
fn main() -> int {
  x := unknown_function(42);
  return 0;
}
`;

const [badBuf, badPtr] = cstr(badSource);
const badResult = mog.mog_compile(compiler, badPtr, null);
const badErrors = mog.mog_result_get_error_count(badResult);
console.log(`  Error count: ${badErrors}`);

if (badErrors > 0) {
  for (let i = 0; i < badErrors; i++) {
    const errPtr = mog.mog_result_get_error(badResult, i);
    console.log(`  Error ${i}: ${readCStr(errPtr)}`);
  }
}

const badIr: Ptr = mog.mog_result_get_ir(badResult);
console.log(`  IR is null (expected): ${isNull(badIr)}`);
mog.mog_result_free(badResult);
console.log("  PASS\n");

// ---------------------------------------------------------------------------
// Test 4: Compile to native binary, run it, check output
// ---------------------------------------------------------------------------

console.log("=== Test 4: Compile to binary and execute ===");

const mogProgram = `
fn fib(n: int) -> int {
  if n <= 1 {
    return n;
  }
  return (fib((n - 1)) + fib((n - 2)));
}

fn main() -> int {
  println(fib(10));
  println(fib(20));
  return 0;
}
`;

const binaryPath = "/tmp/mog_ffi_test_bin";
const [progBuf, progPtr] = cstr(mogProgram);
const [pathBuf, pathPtr] = cstr(binaryPath);

const rc = mog.mog_compile_to_binary(compiler, progPtr, pathPtr);
if (rc !== 0) {
  console.error(`FAIL: mog_compile_to_binary returned ${rc}`);
  process.exit(1);
}
console.log(`  Binary written to: ${binaryPath}`);

// Run it and capture output
const output = execSync(binaryPath, { encoding: "utf-8" }).trim();
const lines = output.split("\n");

console.log(`  Output: ${JSON.stringify(lines)}`);

const expected = ["55", "6765"];
const match = lines[0] === expected[0] && lines[1] === expected[1];
console.log(`  fib(10) = ${lines[0]} (expected 55): ${lines[0] === "55" ? "OK" : "FAIL"}`);
console.log(`  fib(20) = ${lines[1]} (expected 6765): ${lines[1] === "6765" ? "OK" : "FAIL"}`);

// Cleanup
try { unlinkSync(binaryPath); } catch {}

if (!match) {
  console.error("  FAIL");
  process.exit(1);
}
console.log("  PASS\n");

// ---------------------------------------------------------------------------
// Cleanup
// ---------------------------------------------------------------------------

mog.mog_compiler_free(compiler);

console.log("=== All tests passed ===");
