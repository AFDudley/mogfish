// mogfish-skill-cache — skill storage and .fish completion stub generation
//
// See docs/plans/mogfish-outside-in-tdd.md, Layer 3
//
// A skill is an intent + mog script + list of command dependencies.
// The cache persists skills as JSON files on disk, one per intent.
// Fish completion stubs are generated on demand.

use std::fs;
use std::path::{Path, PathBuf};

/// A cached skill — an intent mapped to a mog script.
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct Skill {
    pub intent: String,
    pub mog_script: String,
    pub dependencies: Vec<String>,
    #[serde(default)]
    pub stale: bool,
}

/// File-backed skill cache. Each skill is a JSON file named by intent slug.
pub struct SkillCache {
    dir: PathBuf,
}

impl SkillCache {
    /// Open or create a skill cache at the given directory.
    pub fn open(dir: &Path) -> anyhow::Result<Self> {
        fs::create_dir_all(dir)?;
        Ok(Self {
            dir: dir.to_path_buf(),
        })
    }

    /// Store a skill. Overwrites if intent already exists.
    pub fn store(
        &self,
        intent: &str,
        mog_script: &str,
        dependencies: &[&str],
    ) -> anyhow::Result<()> {
        let skill = Skill {
            intent: intent.to_string(),
            mog_script: mog_script.to_string(),
            dependencies: dependencies.iter().map(|s| s.to_string()).collect(),
            stale: false,
        };
        let path = self.skill_path(intent);
        let json = serde_json::to_string_pretty(&skill)?;
        fs::write(path, json)?;
        Ok(())
    }

    /// Get a skill by intent. Returns None if not found.
    pub fn get(&self, intent: &str) -> anyhow::Result<Option<Skill>> {
        let path = self.skill_path(intent);
        if !path.exists() {
            return Ok(None);
        }
        let json = fs::read_to_string(path)?;
        let skill: Skill = serde_json::from_str(&json)?;
        Ok(Some(skill))
    }

    /// List all cached skills.
    pub fn list(&self) -> anyhow::Result<Vec<Skill>> {
        let mut skills = Vec::new();
        for entry in fs::read_dir(&self.dir)? {
            let entry = entry?;
            let path = entry.path();
            if path.extension().is_some_and(|ext| ext == "json") {
                let json = fs::read_to_string(&path)?;
                if let Ok(skill) = serde_json::from_str::<Skill>(&json) {
                    skills.push(skill);
                }
            }
        }
        Ok(skills)
    }

    /// Generate a .fish completion stub for a cached skill.
    /// Returns None if the skill doesn't exist.
    pub fn generate_fish_stub(&self, intent: &str) -> anyhow::Result<Option<String>> {
        let skill = match self.get(intent)? {
            Some(s) => s,
            None => return Ok(None),
        };

        let slug = slugify(intent);
        let mut stub = String::new();
        stub.push_str(&format!(
            "# Auto-generated fish completion stub for skill: {}\n",
            skill.intent
        ));
        stub.push_str(&format!(
            "# Intent: {}\n",
            skill.intent
        ));
        stub.push_str(&format!(
            "complete -c mogfish-run -n '__mogfish_skill {slug}' -d '{}'\n",
            skill.intent
        ));
        Ok(Some(stub))
    }

    /// Mark all skills depending on a command as stale.
    /// Returns the number of skills invalidated.
    pub fn invalidate_dependency(&self, dep: &str) -> anyhow::Result<usize> {
        let mut count = 0;
        for entry in fs::read_dir(&self.dir)? {
            let entry = entry?;
            let path = entry.path();
            if !path.extension().is_some_and(|ext| ext == "json") {
                continue;
            }
            let json = fs::read_to_string(&path)?;
            let mut skill: Skill = match serde_json::from_str(&json) {
                Ok(s) => s,
                Err(_) => continue,
            };
            if skill.dependencies.iter().any(|d| d == dep) && !skill.stale {
                skill.stale = true;
                let updated = serde_json::to_string_pretty(&skill)?;
                fs::write(&path, updated)?;
                count += 1;
            }
        }
        Ok(count)
    }

    fn skill_path(&self, intent: &str) -> PathBuf {
        self.dir.join(format!("{}.json", slugify(intent)))
    }
}

/// Convert an intent string to a filesystem-safe slug.
fn slugify(s: &str) -> String {
    s.chars()
        .map(|c| if c.is_alphanumeric() { c } else { '-' })
        .collect::<String>()
        .to_lowercase()
}
