// Mog plugin system — dynamic loading via dlopen/dlsym/dlclose.
//
// Port of runtime/mog_plugin.c.  Loads compiled Mog plugins from .dylib/.so
// files, validates required capabilities, and provides a call interface.

use std::ffi::CStr;
use std::ptr;

use blake3;

// ---------------------------------------------------------------------------
// MogValue — 24-byte tagged union (same definition as posix.rs).
// We re-define it here so this module is self-contained.
// ---------------------------------------------------------------------------

#[repr(C)]
#[derive(Copy, Clone)]
pub struct MogValue {
    pub tag: i32,
    _pad: i32,
    pub data: [u8; 16],
}

const MOG_TAG_INT: i32 = 0;
const MOG_TAG_FLOAT: i32 = 1;
#[allow(dead_code)]
const MOG_TAG_STRING: i32 = 3;
const MOG_TAG_BOOL: i32 = 2;
const MOG_TAG_HANDLE: i32 = 5;
const MOG_TAG_ERROR: i32 = 6;

impl MogValue {
    fn int(v: i64) -> Self {
        let mut val = MogValue {
            tag: MOG_TAG_INT,
            _pad: 0,
            data: [0u8; 16],
        };
        unsafe {
            ptr::copy_nonoverlapping(&v as *const i64 as *const u8, val.data.as_mut_ptr(), 8);
        }
        val
    }

    fn error(msg: *const u8) -> Self {
        let mut val = MogValue {
            tag: MOG_TAG_ERROR,
            _pad: 0,
            data: [0u8; 16],
        };
        let p = msg as usize;
        unsafe {
            ptr::copy_nonoverlapping(
                &p as *const usize as *const u8,
                val.data.as_mut_ptr(),
                std::mem::size_of::<usize>(),
            );
        }
        val
    }

    fn as_int(&self) -> i64 {
        let mut v: i64 = 0;
        unsafe {
            ptr::copy_nonoverlapping(self.data.as_ptr(), &mut v as *mut i64 as *mut u8, 8);
        }
        v
    }

    fn as_float(&self) -> f64 {
        let mut v: f64 = 0.0;
        unsafe {
            ptr::copy_nonoverlapping(self.data.as_ptr(), &mut v as *mut f64 as *mut u8, 8);
        }
        v
    }

    fn as_ptr(&self) -> *const u8 {
        let mut p: usize = 0;
        unsafe {
            ptr::copy_nonoverlapping(
                self.data.as_ptr(),
                &mut p as *mut usize as *mut u8,
                std::mem::size_of::<usize>(),
            );
        }
        p as *const u8
    }

    fn as_bool(&self) -> bool {
        self.as_int() != 0
    }
}

// ---------------------------------------------------------------------------
// Plugin info and export structures — match C layout.
// ---------------------------------------------------------------------------

#[repr(C)]
pub struct MogPluginInfo {
    pub name: *const u8,
    pub version: *const u8,
    pub required_caps: *const *const u8, // NULL-terminated array
    pub num_exports: i64,
    pub export_names: *const *const u8, // NULL-terminated array
}

#[repr(C)]
pub struct MogPluginExport {
    pub name: *const u8,
    pub func_ptr: *const u8,
}

// ---------------------------------------------------------------------------
// MogPlugin — opaque handle returned to callers.
// ---------------------------------------------------------------------------

#[repr(C)]
struct MogPlugin {
    dl_handle: *mut libc::c_void,
    info: PluginInfoCached,
    exports: *mut MogPluginExport,
    export_count: i32,
    path: [u8; 512],
}

/// Cached copy of plugin info (owns nothing — pointers point into the .dylib).
#[repr(C)]
struct PluginInfoCached {
    name: *const u8,
    version: *const u8,
    required_caps: *const *const u8,
    num_exports: i64,
    export_names: *const *const u8,
}

// ---------------------------------------------------------------------------
// Thread-local error message buffer.
// ---------------------------------------------------------------------------

use std::cell::RefCell;

thread_local! {
    static PLUGIN_ERROR: RefCell<[u8; 1024]> = const { RefCell::new([0u8; 1024]) };
}

fn set_plugin_error(msg: &str) {
    PLUGIN_ERROR.with(|buf| {
        let mut buf = buf.borrow_mut();
        let bytes = msg.as_bytes();
        let len = bytes.len().min(buf.len() - 1);
        buf[..len].copy_from_slice(&bytes[..len]);
        buf[len] = 0;
    });
}

fn set_plugin_error_fmt(parts: &[&str]) {
    PLUGIN_ERROR.with(|buf| {
        let mut buf = buf.borrow_mut();
        let mut offset = 0;
        for part in parts {
            let bytes = part.as_bytes();
            let avail = buf.len() - 1 - offset;
            let len = bytes.len().min(avail);
            buf[offset..offset + len].copy_from_slice(&bytes[..len]);
            offset += len;
            if avail == 0 {
                break;
            }
        }
        buf[offset] = 0;
    });
}

// ---------------------------------------------------------------------------
// Plugin type definitions for dlsym'd function pointers
// ---------------------------------------------------------------------------

type InfoFn = unsafe extern "C" fn() -> *const MogPluginInfo;
type InitFn = unsafe extern "C" fn(*mut u8) -> i32;
type ExportsFn = unsafe extern "C" fn(*mut i32) -> *mut MogPluginExport;

// ---------------------------------------------------------------------------
// Load plugin
// ---------------------------------------------------------------------------

#[unsafe(no_mangle)]
pub extern "C" fn mog_load_plugin(path: *const u8) -> *mut u8 {
    mog_load_plugin_sandboxed(path, ptr::null(), 0)
}

#[unsafe(no_mangle)]
pub extern "C" fn mog_load_plugin_sandboxed(
    path: *const u8,
    allowed_caps: *const *const u8,
    num_caps: i32,
) -> *mut u8 {
    // Clear previous error
    PLUGIN_ERROR.with(|buf| {
        buf.borrow_mut()[0] = 0;
    });

    if path.is_null() {
        set_plugin_error("null path");
        return ptr::null_mut();
    }

    unsafe {
        // Open the shared library
        let handle = libc::dlopen(
            path as *const libc::c_char,
            libc::RTLD_NOW | libc::RTLD_LOCAL,
        );
        if handle.is_null() {
            let err = libc::dlerror();
            if !err.is_null() {
                let msg = CStr::from_ptr(err)
                    .to_str()
                    .unwrap_or("unknown dlopen error");
                set_plugin_error_fmt(&["dlopen failed: ", msg]);
            } else {
                set_plugin_error("dlopen failed: unknown error");
            }
            return ptr::null_mut();
        }

        // Look up required symbols
        let info_sym = libc::dlsym(handle, b"mog_plugin_info\0".as_ptr() as *const libc::c_char);
        if info_sym.is_null() {
            set_plugin_error("plugin missing mog_plugin_info symbol");
            libc::dlclose(handle);
            return ptr::null_mut();
        }

        let init_sym = libc::dlsym(handle, b"mog_plugin_init\0".as_ptr() as *const libc::c_char);
        if init_sym.is_null() {
            set_plugin_error("plugin missing mog_plugin_init symbol");
            libc::dlclose(handle);
            return ptr::null_mut();
        }

        let exports_sym = libc::dlsym(
            handle,
            b"mog_plugin_exports\0".as_ptr() as *const libc::c_char,
        );
        if exports_sym.is_null() {
            set_plugin_error("plugin missing mog_plugin_exports symbol");
            libc::dlclose(handle);
            return ptr::null_mut();
        }

        let info_fn: InfoFn = std::mem::transmute(info_sym);
        let init_fn: InitFn = std::mem::transmute(init_sym);
        let exports_fn: ExportsFn = std::mem::transmute(exports_sym);

        // Get plugin info
        let info_ptr = info_fn();
        if info_ptr.is_null() {
            set_plugin_error("mog_plugin_info returned NULL");
            libc::dlclose(handle);
            return ptr::null_mut();
        }

        let info = &*info_ptr;

        // Validate required capabilities against allowlist
        if !info.required_caps.is_null() {
            let mut i = 0;
            loop {
                let cap = *info.required_caps.add(i);
                if cap.is_null() {
                    break;
                }

                // Check against explicit allowlist if provided
                if !allowed_caps.is_null() && num_caps > 0 {
                    let mut allowed = false;
                    for j in 0..num_caps as usize {
                        let acap = *allowed_caps.add(j);
                        if !acap.is_null()
                            && libc::strcmp(acap as *const libc::c_char, cap as *const libc::c_char)
                                == 0
                        {
                            allowed = true;
                            break;
                        }
                    }
                    if !allowed {
                        let cap_name = CStr::from_ptr(cap as *const libc::c_char)
                            .to_str()
                            .unwrap_or("?");
                        set_plugin_error_fmt(&[
                            "plugin requires capability '",
                            cap_name,
                            "' which is not in the allowlist",
                        ]);
                        libc::dlclose(handle);
                        return ptr::null_mut();
                    }
                }

                i += 1;
            }
        }

        // Get exports
        let mut export_count: i32 = 0;
        let exports = exports_fn(&mut export_count);

        // Allocate plugin structure
        let plugin = libc::calloc(1, std::mem::size_of::<MogPlugin>()) as *mut MogPlugin;
        if plugin.is_null() {
            set_plugin_error("out of memory");
            libc::dlclose(handle);
            return ptr::null_mut();
        }

        (*plugin).dl_handle = handle;
        (*plugin).info = PluginInfoCached {
            name: info.name,
            version: info.version,
            required_caps: info.required_caps,
            num_exports: info.num_exports,
            export_names: info.export_names,
        };
        (*plugin).exports = exports;
        (*plugin).export_count = export_count;

        // Copy path into fixed buffer
        let path_cstr = CStr::from_ptr(path as *const libc::c_char);
        let path_bytes = path_cstr.to_bytes_with_nul();
        let copy_len = path_bytes.len().min(511);
        ptr::copy_nonoverlapping(path_bytes.as_ptr(), (*plugin).path.as_mut_ptr(), copy_len);
        (*plugin).path[copy_len] = 0;

        // Initialize the plugin
        // Note: the C version passes a MogVM*, but the sandboxed API in the spec
        // doesn't take a VM. We pass null if not available; plugins that need the
        // VM should use the non-sandboxed mog_load_plugin.
        // For the sandboxed variant we skip init (plugin has no VM reference).
        // Actually — the C always inits. We'll pass a null VM and let the plugin
        // deal with it, or if a VM global is available, use that.
        //
        // The spec says mog_load_plugin_sandboxed takes (path, allowed_caps, num_caps)
        // without a VM. We call init with NULL; well-behaved plugins handle this.
        // Transmute to safe fn pointer — we're already in an unsafe block and the
        // plugin init function is being called with a valid (null) argument.
        let safe_init: extern "C" fn(*mut u8) -> i32 = std::mem::transmute(init_fn);
        let result = crate::stack_guard::mog_protected_call_void(safe_init, ptr::null_mut());
        if result < 0 {
            // Stack overflow during plugin init
            set_plugin_error_fmt(&["stack overflow during plugin init"]);
            libc::dlclose(handle);
            libc::free(plugin as *mut libc::c_void);
            return ptr::null_mut();
        }
        if result != 0 {
            set_plugin_error_fmt(&["plugin init returned error code"]);
            libc::dlclose(handle);
            libc::free(plugin as *mut libc::c_void);
            return ptr::null_mut();
        }

        plugin as *mut u8
    }
}

// ---------------------------------------------------------------------------
// Call an exported plugin function by name
// ---------------------------------------------------------------------------

#[unsafe(no_mangle)]
pub extern "C" fn mog_plugin_call(
    plugin: *mut u8,
    func_name: *const u8,
    args: *const MogValue,
    nargs: i32,
) -> MogValue {
    if plugin.is_null() {
        return MogValue::error(b"null plugin\0".as_ptr());
    }
    if func_name.is_null() {
        return MogValue::error(b"null function name\0".as_ptr());
    }

    unsafe {
        let p = &*(plugin as *const MogPlugin);

        // Find the export
        for i in 0..p.export_count as usize {
            let export = &*p.exports.add(i);
            if libc::strcmp(
                export.name as *const libc::c_char,
                func_name as *const libc::c_char,
            ) == 0
            {
                // Convert MogValue args to raw i64 values for the Mog ABI
                let mut raw_args = [0i64; 16];
                let n = (nargs as usize).min(16);
                for j in 0..n {
                    let arg = &*args.add(j);
                    raw_args[j] = match arg.tag {
                        MOG_TAG_INT => arg.as_int(),
                        MOG_TAG_FLOAT => {
                            let d = arg.as_float();
                            let mut bits: i64 = 0;
                            ptr::copy_nonoverlapping(
                                &d as *const f64 as *const u8,
                                &mut bits as *mut i64 as *mut u8,
                                8,
                            );
                            bits
                        }
                        MOG_TAG_STRING => arg.as_ptr() as i64,
                        MOG_TAG_BOOL => {
                            if arg.as_bool() {
                                1
                            } else {
                                0
                            }
                        }
                        MOG_TAG_HANDLE => arg.as_ptr() as i64,
                        _ => 0,
                    };
                }

                // Call with the appropriate number of arguments, routed through
                // the stack guard's protected call mechanism.
                let fp = export.func_ptr;

                // Pack function pointer, args, and arity into a stack struct
                // so we can route through mog_protected_call via a trampoline.
                #[repr(C)]
                struct PluginCallPack {
                    func_ptr: *const u8,
                    args: [i64; 4],
                    nargs: i32,
                }

                let pack = PluginCallPack {
                    func_ptr: fp,
                    args: [raw_args[0], raw_args[1], raw_args[2], raw_args[3]],
                    nargs,
                };

                extern "C" fn plugin_call_trampoline(pack_ptr: i64) -> i64 {
                    unsafe {
                        let pack = &*(pack_ptr as *const PluginCallPack);
                        type Fn0 = unsafe extern "C" fn() -> i64;
                        type Fn1 = unsafe extern "C" fn(i64) -> i64;
                        type Fn2 = unsafe extern "C" fn(i64, i64) -> i64;
                        type Fn3 = unsafe extern "C" fn(i64, i64, i64) -> i64;
                        type Fn4 = unsafe extern "C" fn(i64, i64, i64, i64) -> i64;

                        match pack.nargs {
                            0 => {
                                let f: Fn0 = std::mem::transmute(pack.func_ptr);
                                f()
                            }
                            1 => {
                                let f: Fn1 = std::mem::transmute(pack.func_ptr);
                                f(pack.args[0])
                            }
                            2 => {
                                let f: Fn2 = std::mem::transmute(pack.func_ptr);
                                f(pack.args[0], pack.args[1])
                            }
                            3 => {
                                let f: Fn3 = std::mem::transmute(pack.func_ptr);
                                f(pack.args[0], pack.args[1], pack.args[2])
                            }
                            4 => {
                                let f: Fn4 = std::mem::transmute(pack.func_ptr);
                                f(pack.args[0], pack.args[1], pack.args[2], pack.args[3])
                            }
                            _ => 0, // unreachable — checked before
                        }
                    }
                }

                if nargs > 4 {
                    return MogValue::error(b"too many arguments (max 4)\0".as_ptr());
                }

                let result = crate::stack_guard::mog_protected_call(
                    plugin_call_trampoline,
                    &pack as *const PluginCallPack as i64,
                );

                // Check for stack overflow sentinel
                if result == i64::MIN && crate::stack_guard::mog_stack_overflow_occurred() != 0 {
                    return MogValue::error(b"stack overflow in plugin call\0".as_ptr());
                }

                return MogValue::int(result);
            }
        }

        // Not found
        let name_str = CStr::from_ptr(func_name as *const libc::c_char)
            .to_str()
            .unwrap_or("?");
        set_plugin_error_fmt(&["function '", name_str, "' not found in plugin"]);

        PLUGIN_ERROR.with(|buf| MogValue::error(buf.borrow().as_ptr()))
    }
}

// ---------------------------------------------------------------------------
// Get plugin info
// ---------------------------------------------------------------------------

#[unsafe(no_mangle)]
pub extern "C" fn mog_plugin_get_info(plugin: *const u8) -> *const u8 {
    if plugin.is_null() {
        return ptr::null();
    }
    unsafe {
        let p = &*(plugin as *const MogPlugin);
        &p.info as *const PluginInfoCached as *const u8
    }
}

// ---------------------------------------------------------------------------
// Get last error message
// ---------------------------------------------------------------------------

#[unsafe(no_mangle)]
pub extern "C" fn mog_plugin_error() -> *const u8 {
    PLUGIN_ERROR.with(|buf| {
        let buf = buf.borrow();
        if buf[0] == 0 {
            ptr::null()
        } else {
            buf.as_ptr()
        }
    })
}

// ---------------------------------------------------------------------------
// Unload plugin
// ---------------------------------------------------------------------------

#[unsafe(no_mangle)]
pub extern "C" fn mog_unload_plugin(plugin: *mut u8) {
    if plugin.is_null() {
        return;
    }
    unsafe {
        let p = plugin as *mut MogPlugin;
        if !(*p).dl_handle.is_null() {
            libc::dlclose((*p).dl_handle);
        }
        libc::free(plugin as *mut libc::c_void);
    }
}

// ---------------------------------------------------------------------------
// Hash-verified plugin loading
// ---------------------------------------------------------------------------

/// Load a plugin after verifying its BLAKE3 hash matches `expected_hash`.
///
/// `expected_hash` must be a NUL-terminated hex-encoded BLAKE3 string (64 hex
/// chars + NUL).  If the file's computed hash does not match, the plugin is
/// **not** loaded and `NULL` is returned (with an error in `mog_plugin_error`).
#[unsafe(no_mangle)]
pub extern "C" fn mog_load_plugin_verified(path: *const u8, expected_hash: *const u8) -> *mut u8 {
    // Clear previous error
    PLUGIN_ERROR.with(|buf| {
        buf.borrow_mut()[0] = 0;
    });

    if path.is_null() {
        set_plugin_error("null path");
        return ptr::null_mut();
    }
    if expected_hash.is_null() {
        set_plugin_error("null expected hash");
        return ptr::null_mut();
    }

    // Read the expected hash string
    let expected = unsafe {
        match CStr::from_ptr(expected_hash as *const libc::c_char).to_str() {
            Ok(s) => s,
            Err(_) => {
                set_plugin_error("expected hash is not valid UTF-8");
                return ptr::null_mut();
            }
        }
    };

    // Read the path string
    let path_str = unsafe {
        match CStr::from_ptr(path as *const libc::c_char).to_str() {
            Ok(s) => s,
            Err(_) => {
                set_plugin_error("path is not valid UTF-8");
                return ptr::null_mut();
            }
        }
    };

    // Read the binary and compute its BLAKE3 hash
    let binary_bytes = match std::fs::read(path_str) {
        Ok(bytes) => bytes,
        Err(_) => {
            set_plugin_error_fmt(&["failed to read plugin file: ", path_str]);
            return ptr::null_mut();
        }
    };

    let computed = blake3::hash(&binary_bytes).to_hex().to_string();

    if computed != expected {
        set_plugin_error_fmt(&["hash mismatch: expected ", expected, " but got ", &computed]);
        return ptr::null_mut();
    }

    // Hash verified — delegate to the standard loader
    mog_load_plugin(path)
}
