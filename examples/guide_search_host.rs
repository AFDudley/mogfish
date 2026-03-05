/*
 * Host for the guide search example — Pure Rust
 * Provides stub http + log capabilities.
 */
#![allow(non_camel_case_types)]

use std::ptr;

// ---------------------------------------------------------------------------
// MogValue layout — 24 bytes, #[repr(C)]
// ---------------------------------------------------------------------------

const MOG_INT: i32 = 0;
#[allow(dead_code)]
const MOG_FLOAT: i32 = 1;
const MOG_STRING: i32 = 3;
const MOG_NONE: i32 = 4;

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

type MogHostFn = extern "C" fn(*mut u8, *const MogValue, i32) -> MogValue;

#[repr(C)]
struct MogCapEntry {
    name: *const u8,
    func: MogHostFn,
}

// SAFETY: MogCapEntry is only used in static tables with constant data.
unsafe impl Sync for MogCapEntry {}

// ---------------------------------------------------------------------------
// Value constructors (inline)
// ---------------------------------------------------------------------------

fn mog_int(v: i64) -> MogValue {
    MogValue {
        tag: MOG_INT,
        _pad: 0,
        data: MogValueData { i: v },
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
// Arg extraction helpers
// ---------------------------------------------------------------------------

unsafe fn arg_string(args: *const MogValue, index: i32) -> *const u8 {
    let v = unsafe { &*args.offset(index as isize) };
    unsafe { v.data.s }
}

// ---------------------------------------------------------------------------
// Extern "C" imports from the Mog runtime
// ---------------------------------------------------------------------------

unsafe extern "C" {
    fn mog_vm_new() -> *mut u8;
    fn mog_register_capability(vm: *mut u8, name: *const u8, entries: *const MogCapEntry) -> i32;
    fn mog_vm_set_global(vm: *mut u8);
    fn mog_loop_get_global() -> *mut u8;
    fn mog_future_new() -> *mut u8;
    fn mog_future_complete(f: *mut u8, value: i64);
}

// ---------------------------------------------------------------------------
// libc imports
// ---------------------------------------------------------------------------

unsafe extern "C" {
    fn printf(fmt: *const u8, ...) -> i32;
    fn fprintf(stream: *mut u8, fmt: *const u8, ...) -> i32;
    fn exit(code: i32) -> !;
    static stderr: *mut u8;
}

// ---------------------------------------------------------------------------
// http capability (stub)
// ---------------------------------------------------------------------------

#[unsafe(no_mangle)]
extern "C" fn host_http_get(_vm: *mut u8, args: *const MogValue, _nargs: i32) -> MogValue {
    let url = unsafe { arg_string(args, 0) };
    unsafe {
        printf(b"[http.get] %s\n\0".as_ptr(), url);
    }

    let loop_ptr = unsafe { mog_loop_get_global() };
    if !loop_ptr.is_null() {
        let future = unsafe { mog_future_new() };
        // Complete immediately with a mock response
        unsafe {
            mog_future_complete(future, b"{\"results\": []}\0".as_ptr() as i64);
        }
        return mog_int(future as i64);
    }
    mog_string(b"{\"results\": []}\0")
}

#[unsafe(no_mangle)]
extern "C" fn host_http_post(_vm: *mut u8, args: *const MogValue, _nargs: i32) -> MogValue {
    let url = unsafe { arg_string(args, 0) };
    unsafe {
        printf(b"[http.post] %s\n\0".as_ptr(), url);
    }

    let loop_ptr = unsafe { mog_loop_get_global() };
    if !loop_ptr.is_null() {
        let future = unsafe { mog_future_new() };
        unsafe {
            mog_future_complete(future, b"{\"ok\": true}\0".as_ptr() as i64);
        }
        return mog_int(future as i64);
    }
    mog_string(b"{\"ok\": true}\0")
}

// ---------------------------------------------------------------------------
// log capability
// ---------------------------------------------------------------------------

#[unsafe(no_mangle)]
extern "C" fn host_log_info(_vm: *mut u8, args: *const MogValue, _nargs: i32) -> MogValue {
    let msg = unsafe { arg_string(args, 0) };
    unsafe {
        printf(b"[INFO] %s\n\0".as_ptr(), msg);
    }
    mog_none()
}

#[unsafe(no_mangle)]
extern "C" fn host_log_warn(_vm: *mut u8, args: *const MogValue, _nargs: i32) -> MogValue {
    let msg = unsafe { arg_string(args, 0) };
    unsafe {
        printf(b"[WARN] %s\n\0".as_ptr(), msg);
    }
    mog_none()
}

#[unsafe(no_mangle)]
extern "C" fn host_log_error(_vm: *mut u8, args: *const MogValue, _nargs: i32) -> MogValue {
    let msg = unsafe { arg_string(args, 0) };
    unsafe {
        printf(b"[ERROR] %s\n\0".as_ptr(), msg);
    }
    mog_none()
}

#[unsafe(no_mangle)]
extern "C" fn host_log_debug(_vm: *mut u8, args: *const MogValue, _nargs: i32) -> MogValue {
    let msg = unsafe { arg_string(args, 0) };
    unsafe {
        printf(b"[DEBUG] %s\n\0".as_ptr(), msg);
    }
    mog_none()
}

// ---------------------------------------------------------------------------
// Capability registration tables — NULL-sentinel terminated
// ---------------------------------------------------------------------------

extern "C" fn sentinel_fn(_: *mut u8, _: *const MogValue, _: i32) -> MogValue {
    mog_none()
}

static HTTP_FUNCTIONS: [MogCapEntry; 3] = [
    MogCapEntry {
        name: b"get\0".as_ptr(),
        func: host_http_get,
    },
    MogCapEntry {
        name: b"post\0".as_ptr(),
        func: host_http_post,
    },
    MogCapEntry {
        name: ptr::null(),
        func: sentinel_fn,
    },
];

static LOG_FUNCTIONS: [MogCapEntry; 5] = [
    MogCapEntry {
        name: b"info\0".as_ptr(),
        func: host_log_info,
    },
    MogCapEntry {
        name: b"warn\0".as_ptr(),
        func: host_log_warn,
    },
    MogCapEntry {
        name: b"error\0".as_ptr(),
        func: host_log_error,
    },
    MogCapEntry {
        name: b"debug\0".as_ptr(),
        func: host_log_debug,
    },
    MogCapEntry {
        name: ptr::null(),
        func: sentinel_fn,
    },
];

// ---------------------------------------------------------------------------
// Constructor: runs before main() to set up the VM
// ---------------------------------------------------------------------------

#[unsafe(link_section = "__DATA,__mod_init_func")]
#[used]
static INIT: unsafe extern "C" fn() = setup_mog_vm;

unsafe extern "C" fn setup_mog_vm() {
    let vm = unsafe { mog_vm_new() };
    if vm.is_null() {
        unsafe {
            fprintf(stderr, b"host: failed to create MogVM\n\0".as_ptr());
            exit(1);
        }
    }

    unsafe {
        mog_register_capability(vm, b"http\0".as_ptr(), HTTP_FUNCTIONS.as_ptr());
        mog_register_capability(vm, b"log\0".as_ptr(), LOG_FUNCTIONS.as_ptr());
        mog_vm_set_global(vm);
    }
}
