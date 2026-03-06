use mog::analyzer::SemanticAnalyzer;
use mog::lexer::tokenize;
use mog::parser::parse;
use mog::qbe_codegen::generate_qbe_ir;

fn qbe(src: &str) -> String {
    let tokens = tokenize(src);
    let ast = parse(&tokens);
    let mut analyzer = SemanticAnalyzer::new();
    let errors = analyzer.analyze(&ast);
    assert!(errors.is_empty(), "Analysis errors for `{src}`: {errors:?}");
    generate_qbe_ir(&ast)
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
    assert!(
        !ir.contains("call $malloc"),
        "runtime-generated IR must not call direct malloc"
    );
    assert!(
        !ir.contains("call $calloc"),
        "runtime-generated IR must not call direct calloc"
    );
    assert!(
        !ir.contains("call $realloc"),
        "runtime-generated IR must not call direct realloc"
    );
    assert!(
        !ir.contains("call $free"),
        "runtime-generated IR must not call direct free"
    );
}
