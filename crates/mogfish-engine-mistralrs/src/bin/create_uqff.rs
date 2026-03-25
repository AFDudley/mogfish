// Create a UQFF (pre-quantized) file from a HuggingFace safetensors model.
//
// Loads the model on CPU, applies ISQ Q4K quantization, and writes the result
// to a .uqff file. Loading from UQFF skips the fp16 intermediate — tensors go
// directly to the target device at the quantized size.
//
// Usage: create-uqff <model_dir> <output.uqff>

use mistralrs::blocking::BlockingModel;
use mistralrs::{Device, IsqType, ModelBuilder};
use std::path::PathBuf;

fn main() -> anyhow::Result<()> {
    let model_path = std::env::args()
        .nth(1)
        .expect("Usage: create-uqff <model_dir> <output.uqff>");
    let output_path = std::env::args()
        .nth(2)
        .expect("Usage: create-uqff <model_dir> <output.uqff>");

    eprintln!("Loading model from {model_path}, quantizing Q4K, writing UQFF to {output_path}...");

    let builder = ModelBuilder::new(&model_path)
        .with_isq(IsqType::Q4K)
        .with_device(Device::Cpu)
        .write_uqff(PathBuf::from(&output_path))
        .with_logging();

    let _model = BlockingModel::from_auto_builder(builder)
        .map_err(|e| anyhow::anyhow!("model load/quantize failed: {e}"))?;

    eprintln!("UQFF written to {output_path}");
    Ok(())
}
