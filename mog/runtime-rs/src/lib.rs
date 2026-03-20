// Mog language runtime — Rust implementation.
//
// This is a staticlib that compiled Mog programs link against.  Every public
// function is `extern "C"` + `#[no_mangle]` so the QBE-generated assembly can
// call it directly.

mod array;
mod convert;
mod gc;
mod map;
mod math;
mod plugin;
mod posix;
mod print;
mod result_opt;
mod stack_guard;
mod string_ops;
mod tensor;
mod vm;
