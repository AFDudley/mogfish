//! Async Plugin Demo
//!
//! Demonstrates the full lifecycle:
//!   1. Compile a Mog program to a shared library (plugin) at runtime
//!   2. Load the compiled plugin via dlopen (libloading)
//!   3. Register a custom async host capability
//!   4. Call the plugin's exported async function
//!   5. Drive the event loop until the future completes
//!   6. Read the result
//!
//! The guest Mog code calls `compute.slow_square(x, delay_ms)` which is
//! provided by the host as an async capability backed by a timer.

use libloading::{Library, Symbol};
use std::path::Path;
use std::ptr;

// ---------------------------------------------------------------------------
// FFI: Mog runtime types
// ---------------------------------------------------------------------------

const MOG_INT: i32 = 0;
#[allow(dead_code)]
const MOG_FLOAT: i32 = 1;
#[allow(dead_code)]
const MOG_STRING: i32 = 3;
const MOG_ERROR: i32 = 6;
const MOG_FUTURE_READY: i32 = 1;

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
    s: *const u8,
    handle: MogHandle,
    error: *const u8,
}

#[repr(C)]
#[derive(Copy, Clone)]
struct MogValue {
    tag: i32,
    _pad: i32,
    data: MogValueData,
}

impl MogValue {
    fn int(v: i64) -> Self {
        MogValue {
            tag: MOG_INT,
            _pad: 0,
            data: MogValueData { i: v },
        }
    }
}

type MogHostFn = extern "C" fn(*mut u8, *const MogValue, i32) -> MogValue;

#[repr(C)]
struct MogCapEntry {
    name: *const u8,
    func: MogHostFn,
}
unsafe impl Sync for MogCapEntry {}

// ---------------------------------------------------------------------------
// FFI: Mog runtime functions
// ---------------------------------------------------------------------------

unsafe extern "C" {
    fn mog_vm_new() -> *mut u8;
    fn mog_vm_set_global(vm: *mut u8);
    fn mog_vm_free(vm: *mut u8);
    fn mog_register_capability(vm: *mut u8, name: *const u8, entries: *const MogCapEntry) -> i32;
    fn gc_init();

    // Event loop
    fn mog_loop_new() -> *mut u8;
    fn mog_loop_set_global(loop_ptr: *mut u8);
    fn mog_loop_run(loop_ptr: *mut u8);
    fn mog_loop_free(loop_ptr: *mut u8);

    // Futures & timers
    fn mog_future_new() -> *mut u8;
    fn mog_future_complete(f: *mut u8, value: i64);
    fn mog_loop_add_timer_with_value(loop_ptr: *mut u8, ms: i64, future: *mut u8, value: i64);
    fn mog_loop_get_global() -> *mut u8;
}

// ---------------------------------------------------------------------------
// Plugin protocol types (from the compiled .dylib)
// ---------------------------------------------------------------------------

/// Matches the QBE codegen layout: gc_alloc(24) with [name, version, num_exports]
#[repr(C)]
struct MogPluginInfo {
    name: *const u8,
    version: *const u8,
    num_exports: i64,
}

#[repr(C)]
struct MogPluginExport {
    name: *const u8,
    func_ptr: *mut u8,
}

// ---------------------------------------------------------------------------
// Host capability: compute.slow_square(x, delay_ms) -> int
//
// Creates a future, schedules a timer for `delay_ms` milliseconds,
// and when the timer fires the future completes with x * x.
// ---------------------------------------------------------------------------

extern "C" fn host_slow_square(_vm: *mut u8, args: *const MogValue, _nargs: i32) -> MogValue {
    let (x, delay_ms) = unsafe {
        let a0 = &*args.add(0);
        let a1 = &*args.add(1);
        (a0.data.i, a1.data.i)
    };

    let result = x * x;

    unsafe {
        let future = mog_future_new();
        let loop_ptr = mog_loop_get_global();
        if loop_ptr.is_null() {
            // No event loop — complete synchronously
            mog_future_complete(future, result);
        } else {
            // Schedule timer: after delay_ms, complete the future with x*x
            mog_loop_add_timer_with_value(loop_ptr, delay_ms, future, result);
        }
        // Return the future pointer as an int (Mog async convention)
        MogValue::int(future as i64)
    }
}

/// Sentinel — never called; name=null terminates the capability table.
extern "C" fn _sentinel(_: *mut u8, _: *const MogValue, _: i32) -> MogValue {
    MogValue::int(0)
}

static COMPUTE_CAP: [MogCapEntry; 2] = [
    MogCapEntry {
        name: b"slow_square\0".as_ptr(),
        func: host_slow_square,
    },
    MogCapEntry {
        name: ptr::null(),
        func: _sentinel,
    },
];

// ---------------------------------------------------------------------------
// MogFuture — just enough to read the result
// ---------------------------------------------------------------------------

#[repr(C)]
struct MogFuture {
    state: i32,
    _pad: i32,
    result: i64,
    // ... more fields we don't need to read
}

// ---------------------------------------------------------------------------
// main: compile → load → call → run event loop → read result
// ---------------------------------------------------------------------------

fn main() {
    // -----------------------------------------------------------------------
    // Step 1: Compile the Mog source to a shared library
    // -----------------------------------------------------------------------
    let source_dir = Path::new(env!("CARGO_MANIFEST_DIR"));
    let mog_source = std::fs::read_to_string(source_dir.join("async_plugin.mog"))
        .expect("failed to read async_plugin.mog");

    // Copy the .mogdecl so the compiler can find it relative to the source
    let cap_dir = source_dir.join("capabilities");
    std::fs::create_dir_all(&cap_dir).ok();
    std::fs::copy(
        source_dir.join("compute.mogdecl"),
        cap_dir.join("compute.mogdecl"),
    )
    .expect("failed to copy mogdecl");

    println!("--- Step 1: Compiling async_plugin.mog to shared library ---");
    let dylib_path = mog::compiler::compile_plugin(&mog_source, "async_plugin", "1.0.0")
        .expect("compilation failed");
    println!("  compiled: {}", dylib_path.display());

    // -----------------------------------------------------------------------
    // Step 2: Load the plugin via dlopen (libloading)
    // -----------------------------------------------------------------------
    println!("\n--- Step 2: Loading plugin via dlopen ---");
    let lib = unsafe { Library::new(&dylib_path) }.expect("dlopen failed");

    // Look up plugin protocol symbols
    let info_fn: Symbol<unsafe extern "C" fn() -> *const MogPluginInfo> =
        unsafe { lib.get(b"mog_plugin_info") }.expect("missing mog_plugin_info");
    let init_fn: Symbol<unsafe extern "C" fn(*mut u8) -> i32> =
        unsafe { lib.get(b"mog_plugin_init") }.expect("missing mog_plugin_init");
    let exports_fn: Symbol<unsafe extern "C" fn(*mut i64) -> *const MogPluginExport> =
        unsafe { lib.get(b"mog_plugin_exports") }.expect("missing mog_plugin_exports");

    // Print plugin info
    let info = unsafe { &*info_fn() };
    let name = unsafe { std::ffi::CStr::from_ptr(info.name as *const i8) };
    let version = unsafe { std::ffi::CStr::from_ptr(info.version as *const i8) };
    println!(
        "  plugin: {} v{}",
        name.to_str().unwrap(),
        version.to_str().unwrap()
    );
    println!("  exports: {}", info.num_exports);

    // -----------------------------------------------------------------------
    // Step 3: Set up the runtime — VM, capability, event loop
    // -----------------------------------------------------------------------
    println!("\n--- Step 3: Setting up runtime (VM + async capability + event loop) ---");
    unsafe {
        gc_init();

        let vm = mog_vm_new();
        assert!(!vm.is_null(), "failed to create VM");
        mog_vm_set_global(vm);

        // Register our async capability
        let rc = mog_register_capability(vm, b"compute\0".as_ptr(), COMPUTE_CAP.as_ptr());
        assert_eq!(rc, 0, "failed to register compute capability");
        println!("  registered 'compute' capability");

        // Create and set the global event loop
        let event_loop = mog_loop_new();
        mog_loop_set_global(event_loop);
        println!("  event loop created");

        // Initialize the plugin (calls mog_plugin_init → sets VM in plugin)
        let init_rc = init_fn(vm);
        assert_eq!(init_rc, 0, "plugin init failed");
        println!("  plugin initialized");

        // -----------------------------------------------------------------------
        // Step 4: Look up and call the plugin's async function
        // -----------------------------------------------------------------------
        println!("\n--- Step 4: Calling plugin functions ---");

        // Get exports table
        let mut count: i64 = 0;
        let exports = exports_fn(&mut count);
        println!("  {} exports found", count);

        // Find functions by name
        let mut sum_of_squares_fn: Option<unsafe extern "C" fn(i64, i64) -> i64> = None;
        let mut add_fn: Option<unsafe extern "C" fn(i64, i64) -> i64> = None;
        for i in 0..count as usize {
            let export = &*exports.add(i);
            let fname = std::ffi::CStr::from_ptr(export.name as *const i8)
                .to_str()
                .unwrap();
            println!("    export[{}]: {}", i, fname);
            if fname == "sum_of_squares" {
                sum_of_squares_fn = Some(std::mem::transmute(export.func_ptr));
            } else if fname == "add" {
                add_fn = Some(std::mem::transmute(export.func_ptr));
            }
        }

        // Call sync function first (sanity check)
        let add = add_fn.expect("'add' not found in exports");
        let sync_result = add(3, 4);
        println!("\n  sync: add(3, 4) = {}", sync_result);
        assert_eq!(sync_result, 7);

        // Call async function — returns a future pointer
        let sum_sq = sum_of_squares_fn.expect("'sum_of_squares' not found in exports");
        println!("  async: calling sum_of_squares(3, 4)...");
        let future_ptr = sum_sq(3, 4);
        println!("  got future at {:p}", future_ptr as *const u8);

        // -----------------------------------------------------------------------
        // Step 5: Drive the event loop until the future completes
        // -----------------------------------------------------------------------
        println!("\n--- Step 5: Running event loop ---");
        mog_loop_run(event_loop);
        println!("  event loop finished");

        // -----------------------------------------------------------------------
        // Step 6: Read the result
        // -----------------------------------------------------------------------
        let future = &*(future_ptr as *const MogFuture);
        assert_eq!(
            future.state, MOG_FUTURE_READY,
            "future not ready after event loop"
        );
        let result = future.result;
        println!("\n--- Step 6: Result ---");
        println!(
            "  sum_of_squares(3, 4) = {} (expected {})",
            result,
            3 * 3 + 4 * 4
        );
        assert_eq!(result, 25, "3² + 4² should be 25");

        println!("\n=== All assertions passed ===");

        // Cleanup
        mog_loop_free(event_loop);
        mog_vm_free(vm);
    }
}
