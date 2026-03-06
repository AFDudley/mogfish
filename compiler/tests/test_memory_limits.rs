use std::collections::HashMap;

use mog::analyzer::SemanticAnalyzer;
use mog::capability::parse_capability_decl;
use mog::capability::CapabilityDecl;
use mog::lexer::tokenize;
use mog::parser::parse;
use mog::qbe_codegen::{generate_qbe_ir, generate_qbe_ir_with_caps};

fn qbe(src: &str) -> String {
    let tokens = tokenize(src);
    let ast = parse(&tokens);
    let mut analyzer = SemanticAnalyzer::new();
    let errors = analyzer.analyze(&ast);
    assert!(errors.is_empty(), "Analysis errors for `{src}`: {errors:?}");
    generate_qbe_ir(&ast)
}

fn qbe_with_caps(src: &str, caps: HashMap<String, CapabilityDecl>) -> String {
    let tokens = tokenize(src);
    let ast = parse(&tokens);
    let mut analyzer = SemanticAnalyzer::new();
    analyzer.set_capability_decls(caps.clone());
    let errors = analyzer.analyze(&ast);
    assert!(errors.is_empty(), "Analysis errors for `{src}`: {errors:?}");
    generate_qbe_ir_with_caps(&ast, caps)
}

fn assert_no_system_allocator_symbols(ir: &str, context: &str) {
    for (line_no, line) in ir.lines().enumerate() {
        let call_idx = line.find("call $");
        if let Some(call_idx) = call_idx {
            let after = &line[call_idx + 6..];
            let target = after
                .split(|c: char| c.is_whitespace() || c == '(')
                .next()
                .unwrap_or("");

            let target = target.to_ascii_lowercase();
            for forbidden in ["malloc", "calloc", "realloc", "free"] {
                assert!(
                    !target.contains(forbidden),
                    "{context}: forbidden allocator symbol in line {}: `{}`",
                    line_no + 1,
                    line
                );
            }
        }
    }
}

fn assert_has_allocator_surface(ir: &str, context: &str) {
    let uses_allocator = ir.lines().any(|line| {
        let call_idx = line.find("call $");
        let Some(call_idx) = call_idx else {
            return false;
        };

        let after = &line[call_idx + 6..];
        let target = after
            .split(|c: char| c.is_whitespace() || c == '(')
            .next()
            .unwrap_or("");

        target.contains("gc_alloc")
            || target.contains("array_new")
            || target.contains("array_push")
            || target.contains("array_set")
            || target.contains("map_new")
    });

    assert!(uses_allocator, "{context}: expected runtime allocator call path");
}

#[test]
fn hostile_imported_library_calls_do_not_reference_system_allocator_symbols() {
    let mut math_caps = HashMap::new();
    let cap = parse_capability_decl(
        r#"
            capability math {
                fn random_seed() -> int;
            }
        "#,
    );
    math_caps.insert("math".to_string(), cap.unwrap_or_else(|| panic!("math capability parse failed")));
    let ir = qbe_with_caps(
        "requires math\n\
         fn main() -> int {\n\
             value := math.random_seed();\n\
             return value;\n\
         }",
        math_caps,
    );

    assert_no_system_allocator_symbols(&ir, "hostile imported calls");
    assert!(
        ir.contains("sin") || ir.contains("math") || ir.contains("random_seed"),
        "expected imported capability call surface in IR"
    );
}

fn assert_uses_gc_allocator_or_gc_helpers(ir: &str, context: &str) {
    assert_has_allocator_surface(ir, context);
}

#[test]
fn generated_code_uses_runtime_allocator_and_not_system_allocator_symbols() {
    let ir = qbe(
        "struct Blob { value: int }\n\
         fn main() -> int {\n\
             value := 123;\n\
             blob := Blob { value: value };\n\
             return blob.value;\n\
         }",
    );

    assert!(
        ir.contains("call $gc_alloc"),
        "memory-allocating Mog code should call gc_alloc"
    );
    assert_no_system_allocator_symbols(&ir, "struct allocation");
}

#[test]
fn array_allocations_stay_on_runtime_allocator_surface() {
    let ir = qbe(
        "fn main() -> int {\n\
            xs := [1, 2, 3, 4, 5];\n\
            xs.push(6);\n\
            return xs.len();\n\
        }",
    );

    assert_no_system_allocator_symbols(&ir, "array allocation");
    assert_uses_gc_allocator_or_gc_helpers(&ir, "array allocation");
}

#[test]
fn map_allocations_stay_on_runtime_allocator_surface() {
    let ir = qbe(
        "fn main() -> int {\n\
            x := ({a: 1, b: 2, c: 3});\n\
            return x.len();\n\
        }",
    );

    assert_no_system_allocator_symbols(&ir, "map allocation");
    assert_uses_gc_allocator_or_gc_helpers(&ir, "map allocation");
}

#[test]
fn hostile_string_and_bytes_paths_do_not_call_system_allocators() {
    let ir = qbe(
        "x := 42\n\
         s := f\"value: {x}\"\n\
         println(s)",
    );

    assert_no_system_allocator_symbols(&ir, "string concatenation");
    assert!(
        ir.contains("call $string_concat"),
        "string interpolation should use runtime string concat path"
    );
}

#[test]
fn no_system_allocator_calls_even_without_gc_allocation_sites() {
    let ir = qbe(
        "fn main() -> int {\n\
            x := 10;\n\
            y := 20;\n\
            z := x + y;\n\
            println_i64(z);\n\
            return z;\n\
        }",
    );

    assert_no_system_allocator_symbols(&ir, "non-allocating path");
}

#[test]
fn mixed_workload_features_stay_on_runtime_allocator_surface() {
    let mut math_caps = HashMap::new();
    let cap = parse_capability_decl(
        r#"
            capability math {
                fn sin(x: float) -> float;
            }
        "#,
    );
    math_caps.insert(
        "math".to_string(),
        cap.unwrap_or_else(|| panic!("math capability parse failed")),
    );
    let ir = qbe_with_caps(
         "requires math\n\
         fn main() -> int {\n\
            x := [1, 2, 3];\n\
            x.push(4);\n\
            x.push(5);\n\
            d := ({a: 10, b: 20});\n\
            s := f\"value={x.len()}\";\n\
            t := s + \"!\";\n\
            math.sin(0.5);\n\
            return d.len() + t.len();\n\
         }",
        math_caps,
    );

    assert_no_system_allocator_symbols(&ir, "mixed workload");
    assert_has_allocator_surface(&ir, "mixed workload");
}
