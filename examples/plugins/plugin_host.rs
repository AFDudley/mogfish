/*
 * Mog Plugin Host Example — Pure Rust
 *
 * Demonstrates loading a compiled Mog plugin (.dylib) at runtime and calling
 * its exported functions from Rust using raw dlopen/dlsym/dlclose.
 *
 * Build with:
 *   rustc --edition 2024 --crate-type bin -o plugin_host_rs plugin_host.rs -L. -lmogrt
 * Then run:
 *   ./plugin_host_rs ./math_plugin.dylib
 */
#![allow(non_camel_case_types)]

use std::ptr;

// ---------------------------------------------------------------------------
// MogValue layout — 24 bytes, #[repr(C)]
// ---------------------------------------------------------------------------

const MOG_INT: i32 = 0;
const MOG_ERROR: i32 = 6;

#[repr(C)]
#[derive(Copy, Clone)]
union MogValueData {
    i: i64,
    f: f64,
    b: i64,
    s: *const u8,
    handle_ptr: *mut u8,
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
// Plugin info structs (matches runtime-rs/src/plugin.rs)
// ---------------------------------------------------------------------------

#[repr(C)]
struct MogPluginInfo {
    name: *const u8,
    version: *const u8,
    num_exports: i64,
    export_names: *const *const u8,
}

// ---------------------------------------------------------------------------
// Value constructors (inline)
// ---------------------------------------------------------------------------

fn mog_int_val(v: i64) -> MogValue {
    MogValue {
        tag: MOG_INT,
        _pad: 0,
        data: MogValueData { i: v },
    }
}

// ---------------------------------------------------------------------------
// Extern "C" imports from the Mog runtime
// ---------------------------------------------------------------------------

unsafe extern "C" {
    fn mog_vm_new() -> *mut u8;
    fn mog_vm_free(vm: *mut u8);
    fn mog_vm_set_global(vm: *mut u8);
    fn mog_load_plugin(path: *const u8) -> *mut u8;
    fn mog_plugin_get_info(plugin: *const u8) -> *const u8;
    fn mog_plugin_call(
        plugin: *mut u8,
        name: *const u8,
        args: *const MogValue,
        nargs: i32,
    ) -> MogValue;
    fn mog_plugin_error() -> *const u8;
    fn mog_unload_plugin(plugin: *mut u8);
}

// ---------------------------------------------------------------------------
// libc imports
// ---------------------------------------------------------------------------

unsafe extern "C" {
    fn printf(fmt: *const u8, ...) -> i32;
    fn fprintf(stream: *mut u8, fmt: *const u8, ...) -> i32;
    static stderr: *mut u8;
}

// ---------------------------------------------------------------------------
// Helper: print a null-terminated C string length
// ---------------------------------------------------------------------------

unsafe fn cstr_len(s: *const u8) -> usize {
    let mut len = 0;
    while unsafe { *s.add(len) } != 0 {
        len += 1;
    }
    len
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

fn main() {
    let args: Vec<String> = std::env::args().collect();

    // Create a VM instance. The math plugin has no `requires` declarations
    // so it needs no registered capabilities — an empty VM suffices.
    let vm = unsafe { mog_vm_new() };
    if vm.is_null() {
        unsafe {
            fprintf(stderr, b"Failed to create MogVM\n\0".as_ptr());
        }
        std::process::exit(1);
    }
    unsafe {
        mog_vm_set_global(vm);
    }

    // Load the plugin from the path given on the command line, or a default.
    let default_path = String::from("./math_plugin.dylib\0");
    let plugin_path = if args.len() > 1 {
        let mut p = args[1].clone();
        if !p.ends_with('\0') {
            p.push('\0');
        }
        p
    } else {
        default_path
    };

    let plugin = unsafe { mog_load_plugin(plugin_path.as_ptr()) };
    if plugin.is_null() {
        let err = unsafe { mog_plugin_error() };
        unsafe {
            fprintf(stderr, b"Failed to load plugin: %s\n\0".as_ptr(), err);
            mog_vm_free(vm);
        }
        std::process::exit(1);
    }

    // Print plugin metadata.
    let info_ptr = unsafe { mog_plugin_get_info(plugin) };
    if !info_ptr.is_null() {
        let info = unsafe { &*(info_ptr as *const MogPluginInfo) };
        unsafe {
            printf(
                b"Loaded plugin: %s v%s\n\0".as_ptr(),
                info.name,
                info.version,
            );
            printf(b"Exports: %lld function(s)\n\0".as_ptr(), info.num_exports);
        }
        if !info.export_names.is_null() {
            let mut i = 0;
            loop {
                let name = unsafe { *info.export_names.add(i) };
                if name.is_null() {
                    break;
                }
                unsafe {
                    printf(b"  - %s\n\0".as_ptr(), name);
                }
                i += 1;
            }
        }
        unsafe {
            printf(b"\n\0".as_ptr());
        }
    }

    // --- Call exported functions ---

    // fibonacci(10) = 55
    let fib_args = [mog_int_val(10)];
    let fib_result =
        unsafe { mog_plugin_call(plugin, b"fibonacci\0".as_ptr(), fib_args.as_ptr(), 1) };
    unsafe {
        printf(b"fibonacci(10) = %lld\n\0".as_ptr(), fib_result.data.i);
    }

    // factorial(7) = 5040
    let fact_args = [mog_int_val(7)];
    let fact_result =
        unsafe { mog_plugin_call(plugin, b"factorial\0".as_ptr(), fact_args.as_ptr(), 1) };
    unsafe {
        printf(b"factorial(7) = %lld\n\0".as_ptr(), fact_result.data.i);
    }

    // sum_of_squares(3, 4) = 25
    let sos_args = [mog_int_val(3), mog_int_val(4)];
    let sos_result =
        unsafe { mog_plugin_call(plugin, b"sum_of_squares\0".as_ptr(), sos_args.as_ptr(), 2) };
    unsafe {
        printf(
            b"sum_of_squares(3, 4) = %lld\n\0".as_ptr(),
            sos_result.data.i,
        );
    }

    // gcd(48, 18) = 6
    let gcd_args = [mog_int_val(48), mog_int_val(18)];
    let gcd_result = unsafe { mog_plugin_call(plugin, b"gcd\0".as_ptr(), gcd_args.as_ptr(), 2) };
    unsafe {
        printf(b"gcd(48, 18) = %lld\n\0".as_ptr(), gcd_result.data.i);
    }

    // Attempting to call a function that doesn't exist returns MOG_ERROR.
    let bad = unsafe { mog_plugin_call(plugin, b"nonexistent\0".as_ptr(), ptr::null(), 0) };
    if bad.tag == MOG_ERROR {
        unsafe {
            printf(b"\nExpected error: %s\n\0".as_ptr(), bad.data.error);
        }
    }

    // Cleanup.
    unsafe {
        mog_unload_plugin(plugin);
        mog_vm_free(vm);
    }
}
