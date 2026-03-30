complete -c "kit" -l "version" -d "Show version and exit." # global
complete -c "kit" -l "install-completion" -d "Install completion for the current shell." # global
complete -c "kit" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # global
complete -c "kit" -l "help" -d "Show this message and exit." # global
complete -f -c "kit" -n "__fish_use_subcommand" -a "cache" -d "Manage incremental analysis cache." # sub
complete -f -c "kit" -n "__fish_use_subcommand" -a "chunk-lines" -d "Chunk a file's content by line count." # sub
complete -f -c "kit" -n "__fish_use_subcommand" -a "chunk-symbols" -d "Chunk a file's content by symbols (functions, classes)." # sub
complete -f -c "kit" -n "__fish_use_subcommand" -a "commit" -d "Generate intelligent commit messages and commit staged changes." # sub
complete -f -c "kit" -n "__fish_use_subcommand" -a "context" -d "Extract surrounding code context for a specific line." # sub
complete -f -c "kit" -n "__fish_use_subcommand" -a "dependencies" -d "Analyze and visualize code dependencies within a repository." # sub
complete -f -c "kit" -n "__fish_use_subcommand" -a "export" -d "Export repository data to JSON files." # sub
complete -f -c "kit" -n "__fish_use_subcommand" -a "file-content" -d "Get the content of one or more files in the repository." # sub
complete -f -c "kit" -n "__fish_use_subcommand" -a "file-tree" -d "Get the file tree structure of a repository or subdirectory." # sub
complete -f -c "kit" -n "__fish_use_subcommand" -a "git-info" -d "Show git repository metadata (current SHA, branch, remote URL)." # sub
complete -f -c "kit" -n "__fish_use_subcommand" -a "grep" -d "Perform literal grep search on repository files." # sub
complete -f -c "kit" -n "__fish_use_subcommand" -a "index" -d "Build and return a comprehensive index of the repository." # sub
complete -f -c "kit" -n "__fish_use_subcommand" -a "review" -d "Review a GitHub PR or local diff using kit's repository intelligence and AI analysis." # sub
complete -f -c "kit" -n "__fish_use_subcommand" -a "review-cache" -d "Manage repository cache for PR reviews." # sub
complete -f -c "kit" -n "__fish_use_subcommand" -a "review-profile" -d "Manage custom context profiles for PR reviews." # sub
complete -f -c "kit" -n "__fish_use_subcommand" -a "search" -d "Perform a textual search in a local repository." # sub
complete -f -c "kit" -n "__fish_use_subcommand" -a "serve" -d "Run the kit REST API server." # sub
complete -f -c "kit" -n "__fish_use_subcommand" -a "summarize" -d "Generate a concise summary of a GitHub PR using kit's repository intelligence." # sub
complete -f -c "kit" -n "__fish_use_subcommand" -a "symbols" -d "Extract code symbols (functions, classes, etc.) from the repository." # sub
complete -f -c "kit" -n "__fish_use_subcommand" -a "usages" -d "Find definitions and references of a specific symbol." # sub
complete -f -c "kit" -n "__fish_use_subcommand" -a "search-semantic" -d "Perform semantic search using vector embeddings and natural language queries." # sub
complete -f -c "kit" -n "__fish_use_subcommand" -a "package-search-grep" -d "Search package source code using regex patterns (outputs plain text like grep by default)." # sub
complete -f -c "kit" -n "__fish_use_subcommand" -a "package-search-hybrid" -d "Semantic search with optional regex filtering in package source code (outputs plain text by default)." # sub
complete -f -c "kit" -n "__fish_use_subcommand" -a "package-search-read" -d "Read a specific file from a package." # sub
complete -c "kit" -n "__fish_seen_subcommand_from 'cache'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'cache'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'chunk-lines'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'chunk-lines'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'chunk-symbols'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'chunk-symbols'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'commit'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'commit'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'context'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'context'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'dependencies'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'dependencies'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'export'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'export'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'file-content'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'file-content'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'file-tree'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'file-tree'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'git-info'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'git-info'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'grep'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'grep'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'index'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'index'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-cache'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-cache'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'search'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'search'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'serve'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'serve'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'summarize'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'summarize'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'symbols'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'symbols'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'usages'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'usages'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'search-semantic'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'search-semantic'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-grep'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-grep'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-hybrid'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-hybrid'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-read'" -l "install-completion" -d "Install completion for the current shell." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-read'" -l "show-completion" -d "Show completion for the current shell, to copy it or customize the installation." # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'cache'" -s "r" -l "repo" -d "Repository path" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'cache'" -l "help" -d "Show this message and exit." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'chunk-lines'" -s "n" -l "max-lines" -d "Maximum lines per chunk." -xa "{}" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'chunk-lines'" -s "o" -l "output" -d "Output to JSON file instead of stdout." -xa "{}" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'chunk-lines'" -l "help" -d "Show this message and exit." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'chunk-symbols'" -s "o" -l "output" -d "Output to JSON file instead of stdout." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'chunk-symbols'" -l "help" -d "Show this message and exit." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'commit'" -s "c" -l "config" -d "Path to config file (default: ~/.kit/review-config.yaml)" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'commit'" -s "m" -l "model" -d "Override LLM model (e.g., gpt-4.1-nano, claude-sonnet-4-20250514)" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'commit'" -s "n" -l "dry-run" -d "Show generated message without committing" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'commit'" -l "help" -d "Show this message and exit." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'context'" -s "o" -l "output" -d "Output to JSON file instead of stdout." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'context'" -l "help" -d "Show this message and exit." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'dependencies'" -s "l" -l "language" -d "Language to analyze" -xa "python terraform" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'dependencies'" -s "o" -l "output" -d "Output to file instead of stdout." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'dependencies'" -s "f" -l "format" -d "Output format" -xa "json dot graphml adjacency" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'dependencies'" -s "v" -l "visualize" -d "Generate visualization (requires Graphviz)" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'dependencies'" -l "viz-format" -d "Visualization format" -xa "png svg pdf" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'dependencies'" -s "c" -l "cycles" -d "Show only circular dependencies" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'dependencies'" -l "llm-context" -d "Generate LLM-friendly context description" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'dependencies'" -s "m" -l "module" -d "Analyze specific module/resource" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'dependencies'" -s "i" -l "include-indirect" -d "Include indirect dependencies (for module analysis)" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'dependencies'" -l "ref" -d "Git ref (SHA, tag, or branch) to checkout for remote repositories." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'dependencies'" -l "help" -d "Show this message and exit." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'export'" -l "symbol" -d "Symbol name (required for symbol-usages export)." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'export'" -l "symbol-type" -d "Symbol type filter (for symbol-usages export)." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'export'" -l "ref" -d "Git ref (SHA, tag, or branch) to checkout for remote repositories." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'export'" -l "help" -d "Show this message and exit." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'file-content'" -l "help" -d "Show this message and exit." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'file-tree'" -s "o" -l "output" -d "Output to JSON file instead of stdout." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'file-tree'" -s "p" -l "path" -d "Subdirectory path to show tree for (relative to repo root)." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'file-tree'" -l "ref" -d "Git ref (SHA, tag, or branch) to checkout for remote repositories." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'file-tree'" -l "help" -d "Show this message and exit." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'git-info'" -s "o" -l "output" -d "Output to JSON file instead of stdout." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'git-info'" -l "ref" -d "Git ref (SHA, tag, or branch) to checkout for remote repositories." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'git-info'" -l "help" -d "Show this message and exit." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'grep'" -s "c" -l "case-sensitive" -d "Case sensitive search. [default: case-sensitive]" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'grep'" -s "i" -l "ignore-case" -d "Case sensitive search. [default: case-sensitive]" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'grep'" -l "include" -d "Include files matching pattern (e.g., '*.py'). [default: None]" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'grep'" -l "exclude" -d "Exclude files matching pattern. [default: None]" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'grep'" -s "n" -l "max-results" -d "Maximum number of results to return. [default: 1000]" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'grep'" -s "d" -l "directory" -d "Limit search to specific directory. [default: None]" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'grep'" -l "include-hidden" -d "Include hidden directories in search." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'grep'" -s "o" -l "output" -d "Output to JSON file instead of stdout. [default: None]" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'grep'" -l "ref" -d "Git ref (SHA, tag, or branch) to checkout for remote repositories. [default: None]" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'grep'" -l "help" -d "Show this message and exit." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'index'" -s "o" -l "output" -d "Output to JSON file instead of stdout." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'index'" -l "help" -d "Show this message and exit." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'review'" -l "init-config" -d "Create a default configuration file and exit" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'review'" -l "staged" -d "Review staged changes" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'review'" -s "c" -l "config" -d "Path to config file (default: ~/.kit/review-config.yaml)" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'review'" -s "m" -l "model" -d "Override LLM model (validated against supported models: e.g., gpt-4.1-nano, gpt-4.1, claude-sonnet-4-20250514)" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'review'" -s "P" -l "priority" -d "Filter by priority level (comma-separated): high, medium, low. Default: all" -xa "high medium low" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'review'" -l "profile" -d "Custom context profile to use for review guidelines" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'review'" -s "p" -l "plain" -d "Output raw review content for piping (no formatting)" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'review'" -s "n" -l "dry-run" -d "Don't post comment, just show what would be posted" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'review'" -l "agentic" -d "Use multi-turn agentic analysis (more thorough but expensive)" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'review'" -l "agentic-turns" -d "Number of analysis turns for agentic mode (default: 15)" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'review'" -l "repo-path" -d "Path to existing repository (skips cloning, uses current state)" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'review'" -l "help" -d "Show this message and exit." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'review-cache'" -l "max-size" -d "Maximum cache size in GB (for cleanup)" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'review-cache'" -s "c" -l "config" -d "Path to config file" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'review-cache'" -l "help" -d "Show this message and exit." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile'" -s "n" -l "name" -d "Profile name" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile'" -s "d" -l "description" -d "Profile description" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile'" -s "f" -l "file" -d "File to read context from or export to" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile'" -s "t" -l "tags" -d "Comma-separated tags" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile'" -l "target" -d "Target name for copy operation" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile'" -l "format" -d "Output format" -xa "table json names" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile'" -l "help" -d "Show this message and exit." # global
complete -f -c "kit" -n "__fish_seen_subcommand_from 'review-profile'" -a "create" # sub
complete -f -c "kit" -n "__fish_seen_subcommand_from 'review-profile'" -a "list" # sub
complete -f -c "kit" -n "__fish_seen_subcommand_from 'review-profile'" -a "show" # sub
complete -f -c "kit" -n "__fish_seen_subcommand_from 'review-profile'" -a "edit" # sub
complete -f -c "kit" -n "__fish_seen_subcommand_from 'review-profile'" -a "delete" # sub
complete -f -c "kit" -n "__fish_seen_subcommand_from 'review-profile'" -a "copy" # sub
complete -f -c "kit" -n "__fish_seen_subcommand_from 'review-profile'" -a "export" # sub
complete -f -c "kit" -n "__fish_seen_subcommand_from 'review-profile'" -a "import" # sub
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile create'" -s "n" -l "name" -d "Profile name" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile create'" -s "d" -l "description" -d "Profile description" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile create'" -s "f" -l "file" -d "File to read context from or export to" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile create'" -s "t" -l "tags" -d "Comma-separated tags" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile create'" -l "target" -d "Target name for copy operation" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile create'" -l "format" -d "Output format" -xa "table json names" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile list'" -s "n" -l "name" -d "Profile name" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile list'" -s "d" -l "description" -d "Profile description" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile list'" -s "f" -l "file" -d "File to read context from or export to" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile list'" -s "t" -l "tags" -d "Comma-separated tags" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile list'" -l "target" -d "Target name for copy operation" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile list'" -l "format" -d "Output format" -xa "table json names" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile show'" -s "n" -l "name" -d "Profile name" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile show'" -s "d" -l "description" -d "Profile description" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile show'" -s "f" -l "file" -d "File to read context from or export to" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile show'" -s "t" -l "tags" -d "Comma-separated tags" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile show'" -l "target" -d "Target name for copy operation" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile show'" -l "format" -d "Output format" -xa "table json names" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile edit'" -s "n" -l "name" -d "Profile name" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile edit'" -s "d" -l "description" -d "Profile description" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile edit'" -s "f" -l "file" -d "File to read context from or export to" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile edit'" -s "t" -l "tags" -d "Comma-separated tags" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile edit'" -l "target" -d "Target name for copy operation" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile edit'" -l "format" -d "Output format" -xa "table json names" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile delete'" -s "n" -l "name" -d "Profile name" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile delete'" -s "d" -l "description" -d "Profile description" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile delete'" -s "f" -l "file" -d "File to read context from or export to" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile delete'" -s "t" -l "tags" -d "Comma-separated tags" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile delete'" -l "target" -d "Target name for copy operation" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile delete'" -l "format" -d "Output format" -xa "table json names" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile copy'" -s "n" -l "name" -d "Profile name" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile copy'" -s "d" -l "description" -d "Profile description" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile copy'" -s "f" -l "file" -d "File to read context from or export to" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile copy'" -s "t" -l "tags" -d "Comma-separated tags" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile copy'" -l "target" -d "Target name for copy operation" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile copy'" -l "format" -d "Output format" -xa "table json names" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile export'" -s "n" -l "name" -d "Profile name" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile export'" -s "d" -l "description" -d "Profile description" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile export'" -s "f" -l "file" -d "File to read context from or export to" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile export'" -s "t" -l "tags" -d "Comma-separated tags" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile export'" -l "target" -d "Target name for copy operation" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile export'" -l "format" -d "Output format" -xa "table json names" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile import'" -s "n" -l "name" -d "Profile name" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile import'" -s "d" -l "description" -d "Profile description" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile import'" -s "f" -l "file" -d "File to read context from or export to" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile import'" -s "t" -l "tags" -d "Comma-separated tags" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile import'" -l "target" -d "Target name for copy operation" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'review-profile import'" -l "format" -d "Output format" -xa "table json names" # subcommands flags
complete -c "kit" -n "__fish_seen_subcommand_from 'search'" -s "p" -l "pattern" -d "Glob pattern for files to search." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'search'" -s "o" -l "output" -d "Output to JSON file instead of stdout." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'search'" -l "ref" -d "Git ref (SHA, tag, or branch) to checkout for remote repositories." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'search'" -l "help" -d "Show this message and exit." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'serve'" -l "host" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'serve'" -l "port" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'serve'" -l "reload" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'serve'" -l "no-reload" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'serve'" -l "help" -d "Show this message and exit." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'summarize'" -s "c" -l "config" -d "Path to config file (default: ~/.kit/review-config.yaml)" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'summarize'" -s "m" -l "model" -d "Override LLM model (e.g., gpt-4.1-nano, claude-sonnet-4-20250514)" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'summarize'" -s "p" -l "plain" -d "Output raw summary content for piping (no formatting)" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'summarize'" -s "o" -l "output" -d "Output to file instead of stdout" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'summarize'" -s "u" -l "update-pr-body" -d "Update the PR description with the summary" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'summarize'" -l "repo-path" -d "Path to existing repository (skips cloning, uses current state)" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'summarize'" -l "help" -d "Show this message and exit." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'symbols'" -s "f" -l "file" -d "Extract symbols from specific file only." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'symbols'" -s "o" -l "output" -d "Output to JSON file instead of stdout." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'symbols'" -l "format" -d "Output format: table, json, or names" -xa "table json names" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'symbols'" -l "ref" -d "Git ref (SHA, tag, or branch) to checkout for remote repositories." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'symbols'" -l "help" -d "Show this message and exit." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'usages'" -s "t" -l "type" -d "Symbol type filter" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'usages'" -s "o" -l "output" -d "Output to JSON file instead of stdout." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'usages'" -l "ref" -d "Git ref (SHA, tag, or branch) to checkout for remote repositories." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'usages'" -l "help" -d "Show this message and exit." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'search-semantic'" -s "k" -l "top-k" -d "Maximum number of results to return." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'search-semantic'" -s "o" -l "output" -d "Output to JSON file instead of stdout." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'search-semantic'" -s "e" -l "embedding-model" -d "SentenceTransformers model name for embeddings." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'search-semantic'" -s "c" -l "chunk-by" -d "Chunking strategy: 'symbols' or 'lines'." -xa "symbols lines" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'search-semantic'" -l "build-index" -d "Force rebuild of vector index (default: false)." -xa "build-index no-build-index" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'search-semantic'" -s "p" -l "persist-dir" -d "Directory to persist vector index." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'search-semantic'" -s "f" -l "format" -d "Output format: table, json, plain" -xa "table json plain" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'search-semantic'" -l "ref" -d "Git ref (SHA, tag, or branch) to checkout for remote repositories." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'search-semantic'" -l "help" -d "Show this message and exit." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-grep'" -s "m" -l "max-results" -d "Maximum number of results" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-grep'" -s "f" -l "file-pattern" -d "Filter files by glob pattern (e.g., '*.py')" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-grep'" -s "c" -l "case-sensitive" -d "Case sensitivity [default: case-sensitive]" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-grep'" -s "i" -l "ignore-case" -d "Case sensitivity [default: case-sensitive]" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-grep'" -s "j" -l "json" -d "Output as JSON" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-grep'" -s "F" -l "formatted" -d "Output with formatting and emojis (default is plain like grep)" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-grep'" -l "help" -d "Show this message and exit." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-hybrid'" -s "r" -l "regex" -d "Optional regex filter" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-hybrid'" -s "m" -l "max-results" -d "Maximum number of results" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-hybrid'" -s "f" -l "file-pattern" -d "Filter files by glob pattern" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-hybrid'" -s "j" -l "json" -d "Output as JSON" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-hybrid'" -s "F" -l "formatted" -d "Output with formatting and emojis (default is plain)" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-hybrid'" -l "help" -d "Show this message and exit." # global
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-read'" -s "s" -l "start" -d "Starting line number" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-read'" -s "e" -l "end" -d "Ending line number" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-read'" -s "j" -l "json" -d "Output as JSON" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-read'" -s "p" -l "plain" -d "Output plain text without formatting" # global
complete -c "kit" -n "__fish_seen_subcommand_from 'package-search-read'" -l "help" -d "Show this message and exit." # global