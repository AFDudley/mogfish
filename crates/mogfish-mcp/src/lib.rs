// mogfish-mcp — MCP server exposing mogfish capabilities
//
// See docs/plans/mogfish-outside-in-tdd.md, Layer 5
//
// Exposes tools over JSON-RPC (MCP protocol):
// - classify_input: classify user input via fast paths + engine
// - store_skill / get_skill: skill cache operations
// - annotate_completions: batch annotate .fish files

use std::path::{Path, PathBuf};

use mogfish_classifier::Classifier;
use mogfish_skill_cache::SkillCache;
use mogfish_traits::{InferenceEngine, MockInferenceEngine};
use serde_json::Value;

/// Tool descriptor for MCP tool listing.
pub struct ToolDescriptor {
    pub name: String,
    pub description: String,
}

/// MCP server wrapping mogfish capabilities.
pub struct MogfishMcp {
    cache: SkillCache,
    engine: Box<dyn InferenceEngine>,
    known_commands: Vec<String>,
}

impl MogfishMcp {
    /// Create a new MCP server instance.
    ///
    /// `data_dir` is used for skill cache storage.
    /// `known_commands` is the list of commands for the classifier fast path.
    pub fn new(data_dir: &Path, known_commands: &[&str]) -> anyhow::Result<Self> {
        Self::with_engine(data_dir, known_commands, Box::new(MockInferenceEngine::new()))
    }

    /// Create a new MCP server instance with a specific inference engine.
    pub fn with_engine(
        data_dir: &Path,
        known_commands: &[&str],
        engine: Box<dyn InferenceEngine>,
    ) -> anyhow::Result<Self> {
        let cache_dir = data_dir.join("skills");
        let cache = SkillCache::open(&cache_dir)?;
        Ok(Self {
            cache,
            engine,
            known_commands: known_commands.iter().map(|s| s.to_string()).collect(),
        })
    }

    /// List available tools.
    pub fn list_tools(&self) -> Vec<ToolDescriptor> {
        vec![
            ToolDescriptor {
                name: "classify_input".to_string(),
                description: "Classify user input into KnownCommand, CachedSkill, or Passthrough"
                    .to_string(),
            },
            ToolDescriptor {
                name: "store_skill".to_string(),
                description: "Store a skill (intent + mog script + dependencies)".to_string(),
            },
            ToolDescriptor {
                name: "get_skill".to_string(),
                description: "Retrieve a cached skill by intent".to_string(),
            },
            ToolDescriptor {
                name: "annotate_completions".to_string(),
                description: "Annotate .fish completion files in a directory".to_string(),
            },
        ]
    }

    /// Call a tool by name with JSON arguments.
    pub fn call_tool(&self, name: &str, args: Value) -> anyhow::Result<Value> {
        match name {
            "classify_input" => self.tool_classify_input(args),
            "store_skill" => self.tool_store_skill(args),
            "get_skill" => self.tool_get_skill(args),
            "annotate_completions" => self.tool_annotate_completions(args),
            other => anyhow::bail!("unknown tool: {other}"),
        }
    }

    fn tool_classify_input(&self, args: Value) -> anyhow::Result<Value> {
        let input = args["input"]
            .as_str()
            .ok_or_else(|| anyhow::anyhow!("missing 'input' field"))?;

        let cmd_refs: Vec<&str> = self.known_commands.iter().map(|s| s.as_str()).collect();
        let classifier = Classifier::new(&cmd_refs, &self.cache, self.engine.as_ref());
        let result = classifier.classify(input)?;

        Ok(serde_json::to_value(&result)?)
    }

    fn tool_store_skill(&self, args: Value) -> anyhow::Result<Value> {
        let intent = args["intent"]
            .as_str()
            .ok_or_else(|| anyhow::anyhow!("missing 'intent'"))?;
        let mog_script = args["mog_script"]
            .as_str()
            .ok_or_else(|| anyhow::anyhow!("missing 'mog_script'"))?;
        let deps: Vec<&str> = args["dependencies"]
            .as_array()
            .map(|arr| arr.iter().filter_map(|v| v.as_str()).collect())
            .unwrap_or_default();

        self.cache.store(intent, mog_script, &deps)?;
        Ok(serde_json::json!({"status": "stored", "intent": intent}))
    }

    fn tool_get_skill(&self, args: Value) -> anyhow::Result<Value> {
        let intent = args["intent"]
            .as_str()
            .ok_or_else(|| anyhow::anyhow!("missing 'intent'"))?;

        match self.cache.get(intent)? {
            Some(skill) => Ok(serde_json::to_value(&skill)?),
            None => Ok(serde_json::json!({"error": "not found", "intent": intent})),
        }
    }

    fn tool_annotate_completions(&self, args: Value) -> anyhow::Result<Value> {
        let dir = args["dir"]
            .as_str()
            .ok_or_else(|| anyhow::anyhow!("missing 'dir'"))?;
        let dir = PathBuf::from(dir);

        let results = mogfish_annotator::annotate_directory(&dir, self.engine.as_ref(), false)?;
        let annotated = results.iter().filter(|r| r.annotated).count();
        let skipped = results.iter().filter(|r| r.error.is_some()).count();

        Ok(serde_json::json!({
            "annotated": annotated,
            "skipped": skipped,
            "total": results.len(),
        }))
    }
}
