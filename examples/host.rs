/*
 * Mog Host Embedding Example — Pure Rust
 *
 * This Rust program acts as the "host" for a Mog program. It:
 * 1. Creates a MogVM and registers the "env" capability
 * 2. Sets the global VM pointer (so generated code can find it)
 * 3. The Mog-generated @main runs automatically, calling program_user()
 * 4. program_user() calls env.* functions which route through mog_cap_call
 *
 * Uses #[link_section] to run setup before main(), equivalent to
 * C's __attribute__((constructor)).
 */
#![allow(non_camel_case_types)]

use std::ptr;

// ---------------------------------------------------------------------------
// MogValue layout — 24 bytes, #[repr(C)]
// ---------------------------------------------------------------------------

const MOG_INT: i32 = 0;
const MOG_FLOAT: i32 = 1;
#[allow(dead_code)]
const MOG_BOOL: i32 = 2;
const MOG_STRING: i32 = 3;
const MOG_NONE: i32 = 4;

#[repr(C)]
#[derive(Copy, Clone)]
struct MogHandle {
    ptr: *mut u8,
    type_name: *const u8,
}

#[repr(C)]
#[derive(Copy, Clone)]
union MogValueData {
    i: i64,
    f: f64,
    b: i64,
    s: *const u8,
    handle: MogHandle, // 16 bytes — forces union to correct size
    error: *const u8,
}

#[repr(C)]
#[derive(Copy, Clone)]
struct MogValue {
    tag: i32,
    _pad: i32,
    data: MogValueData,
}

// ---------------------------------------------------------------------------
// MogCapEntry — capability registration table entry
// ---------------------------------------------------------------------------

type MogHostFn = extern "C" fn(*mut u8, *const MogValue, i32) -> MogValue;

#[repr(C)]
struct MogCapEntry {
    name: *const u8,
    func: MogHostFn,
}

// SAFETY: MogCapEntry is only used in static tables with constant data.
// The raw pointers point to static string literals and static functions.
unsafe impl Sync for MogCapEntry {}

// ---------------------------------------------------------------------------
// Value constructors (inline, avoid symbol conflicts with runtime)
// ---------------------------------------------------------------------------

fn mog_int(v: i64) -> MogValue {
    MogValue {
        tag: MOG_INT,
        _pad: 0,
        data: MogValueData { i: v },
    }
}

#[allow(dead_code)]
fn mog_float(v: f64) -> MogValue {
    MogValue {
        tag: MOG_FLOAT,
        _pad: 0,
        data: MogValueData { f: v },
    }
}

fn mog_string(s: &[u8]) -> MogValue {
    MogValue {
        tag: MOG_STRING,
        _pad: 0,
        data: MogValueData { s: s.as_ptr() },
    }
}

fn mog_none() -> MogValue {
    MogValue {
        tag: MOG_NONE,
        _pad: 0,
        data: MogValueData { i: 0 },
    }
}

// ---------------------------------------------------------------------------
// Arg extraction helpers — read directly from the MogValue array
// ---------------------------------------------------------------------------

unsafe fn arg_int(args: *const MogValue, index: i32) -> i64 {
    let v = unsafe { &*args.offset(index as isize) };
    unsafe { v.data.i }
}

unsafe fn arg_string(args: *const MogValue, index: i32) -> *const u8 {
    let v = unsafe { &*args.offset(index as isize) };
    unsafe { v.data.s }
}

// ---------------------------------------------------------------------------
// Extern "C" imports from the Mog runtime
// ---------------------------------------------------------------------------

unsafe extern "C" {
    fn mog_vm_new() -> *mut u8;
    fn mog_vm_free(vm: *mut u8);
    fn mog_register_capability(vm: *mut u8, name: *const u8, entries: *const MogCapEntry) -> i32;
    fn mog_vm_set_global(vm: *mut u8);
    fn mog_loop_get_global() -> *mut u8;
    fn mog_future_new() -> *mut u8;
    fn mog_loop_add_timer_with_value(loop_ptr: *mut u8, ms: i64, future: *mut u8, value: i64);
}

// ---------------------------------------------------------------------------
// Simple LCG random number generator (no external crate dependency)
// ---------------------------------------------------------------------------

static mut RNG_STATE: u64 = 0;

fn lcg_seed(seed: u64) {
    unsafe {
        RNG_STATE = seed;
    }
}

fn lcg_next() -> u64 {
    unsafe {
        RNG_STATE = RNG_STATE
            .wrapping_mul(6364136223846793005)
            .wrapping_add(1442695040888963407);
        RNG_STATE
    }
}

// ---------------------------------------------------------------------------
// libc imports for time and I/O
// ---------------------------------------------------------------------------

unsafe extern "C" {
    fn time(t: *mut i64) -> i64;
    fn printf(fmt: *const u8, ...) -> i32;
    fn exit(code: i32) -> !;
}

// ---------------------------------------------------------------------------
// Host function implementations for the "env" capability
// ---------------------------------------------------------------------------

#[unsafe(no_mangle)]
extern "C" fn host_env_get_name(_vm: *mut u8, _args: *const MogValue, _nargs: i32) -> MogValue {
    mog_string(b"MogShowcase\0")
}

#[unsafe(no_mangle)]
extern "C" fn host_env_get_version(_vm: *mut u8, _args: *const MogValue, _nargs: i32) -> MogValue {
    mog_int(1)
}

#[unsafe(no_mangle)]
extern "C" fn host_env_timestamp(_vm: *mut u8, _args: *const MogValue, _nargs: i32) -> MogValue {
    let t = unsafe { time(ptr::null_mut()) };
    mog_int(t)
}

#[unsafe(no_mangle)]
extern "C" fn host_env_random(_vm: *mut u8, args: *const MogValue, _nargs: i32) -> MogValue {
    let min_val = unsafe { arg_int(args, 0) };
    let max_val = unsafe { arg_int(args, 1) };
    if max_val <= min_val {
        return mog_int(min_val);
    }
    let range = (max_val - min_val + 1) as u64;
    let r = lcg_next() % range;
    mog_int(min_val + r as i64)
}

#[unsafe(no_mangle)]
extern "C" fn host_env_log(_vm: *mut u8, args: *const MogValue, _nargs: i32) -> MogValue {
    let msg = unsafe { arg_string(args, 0) };
    unsafe {
        printf(b"%s\n\0".as_ptr(), msg);
    }
    mog_none()
}

/// Async host function: delay_square(value, delay_ms)
/// Computes value * value, but delivers the result after delay_ms via the event loop.
#[unsafe(no_mangle)]
extern "C" fn host_env_delay_square(_vm: *mut u8, args: *const MogValue, _nargs: i32) -> MogValue {
    let value = unsafe { arg_int(args, 0) };
    let delay_ms = unsafe { arg_int(args, 1) };
    let result = value * value;

    let loop_ptr = unsafe { mog_loop_get_global() };
    if !loop_ptr.is_null() {
        // Async path: create a future, schedule timer to complete it with the result
        let future = unsafe { mog_future_new() };
        unsafe {
            mog_loop_add_timer_with_value(loop_ptr, delay_ms, future, result);
        }
        mog_int(future as i64)
    } else {
        // No event loop: synchronous fallback
        mog_int(result)
    }
}

// ---------------------------------------------------------------------------
// Capability registration table — NULL-sentinel terminated
// ---------------------------------------------------------------------------

static ENV_FUNCTIONS: [MogCapEntry; 7] = [
    MogCapEntry {
        name: b"get_name\0".as_ptr(),
        func: host_env_get_name,
    },
    MogCapEntry {
        name: b"get_version\0".as_ptr(),
        func: host_env_get_version,
    },
    MogCapEntry {
        name: b"timestamp\0".as_ptr(),
        func: host_env_timestamp,
    },
    MogCapEntry {
        name: b"random\0".as_ptr(),
        func: host_env_random,
    },
    MogCapEntry {
        name: b"log\0".as_ptr(),
        func: host_env_log,
    },
    MogCapEntry {
        name: b"delay_square\0".as_ptr(),
        func: host_env_delay_square,
    },
    MogCapEntry {
        name: ptr::null(),
        func: sentinel_fn,
    },
];

/// Dummy function for the sentinel entry (never called).
extern "C" fn sentinel_fn(_: *mut u8, _: *const MogValue, _: i32) -> MogValue {
    mog_none()
}

// ---------------------------------------------------------------------------
// Constructor: runs before main() to set up the VM
// ---------------------------------------------------------------------------

/// macOS equivalent of __attribute__((constructor)) — placed in __DATA,__mod_init_func.
#[unsafe(link_section = "__DATA,__mod_init_func")]
#[used]
static INIT: unsafe extern "C" fn() = setup_mog_vm;

unsafe extern "C" fn setup_mog_vm() {
    // Seed RNG with current time
    let seed = unsafe { time(ptr::null_mut()) } as u64;
    lcg_seed(seed);

    // Create and configure the VM
    let vm = unsafe { mog_vm_new() };
    if vm.is_null() {
        eprintln!("host: failed to create MogVM");
        unsafe {
            exit(1);
        }
    }

    // Register the "env" capability
    let rc = unsafe { mog_register_capability(vm, b"env\0".as_ptr(), ENV_FUNCTIONS.as_ptr()) };
    if rc != 0 {
        eprintln!("host: failed to register 'env' capability");
        unsafe {
            mog_vm_free(vm);
            exit(1);
        }
    }

    // Make it available globally for generated code
    unsafe {
        mog_vm_set_global(vm);
    }
}
