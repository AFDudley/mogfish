fn main() {
    // Link against the Mog Rust runtime for VM, GC, async, and capability symbols.
    let manifest = std::env::var("CARGO_MANIFEST_DIR").unwrap();
    let runtime_dir = format!("{manifest}/../../../runtime-rs/target/release");
    println!("cargo:rustc-link-search=native={runtime_dir}");
    println!("cargo:rustc-link-lib=static=mog_runtime");

    // Export all runtime symbols so that dynamically-loaded plugins can find
    // them at load time (via -undefined dynamic_lookup on macOS).
    println!("cargo:rustc-link-arg=-Wl,-export_dynamic");

    // System libraries needed by the runtime
    if cfg!(target_os = "macos") {
        println!("cargo:rustc-link-lib=framework=System");
    }
    println!("cargo:rustc-link-lib=m");
}
