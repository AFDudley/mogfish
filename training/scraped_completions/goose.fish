complete -c "goose" -s "h" -l "help" -d "Print help" # global
complete -c "goose" -s "V" -l "version" -d "Print version" # global
complete -f -c "goose" -n "__fish_use_subcommand" -a "configure" -d "Configure Goose settings" # sub
complete -f -c "goose" -n "__fish_use_subcommand" -a "info" -d "Display Goose information" # sub
complete -f -c "goose" -n "__fish_use_subcommand" -a "mcp" -d "Run one of the mcp servers bundled with goose" # sub
complete -f -c "goose" -n "__fish_use_subcommand" -a "session" -d "Start or resume interactive chat sessions" # sub
complete -f -c "goose" -n "__fish_use_subcommand" -a "project" -d "Open the last project directory" # sub
complete -f -c "goose" -n "__fish_use_subcommand" -a "projects" -d "List recent project directories" # sub
complete -f -c "goose" -n "__fish_use_subcommand" -a "run" -d "Execute commands from an instruction file or stdin" # sub
complete -f -c "goose" -n "__fish_use_subcommand" -a "recipe" -d "Recipe utilities for validation and deeplinking" # sub
complete -f -c "goose" -n "__fish_use_subcommand" -a "schedule" -d "Manage scheduled jobs" # sub
complete -f -c "goose" -n "__fish_use_subcommand" -a "update" -d "Update the goose CLI version" # sub
complete -f -c "goose" -n "__fish_use_subcommand" -a "bench" -d "Evaluate system configuration across a range of practical tasks" # sub
complete -f -c "goose" -n "__fish_use_subcommand" -a "web" -d "Experimental: Start a web server with a chat interface" # sub
complete -f -c "goose" -n "__fish_use_subcommand" -a "help" -d "Print this message or the help of the given subcommand(s)" # sub
complete -c "goose" -n "__fish_seen_subcommand_from 'configure'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'configure'" -s "V" -l "version" -d "Print version" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'info'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'info'" -s "V" -l "version" -d "Print version" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'mcp'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'mcp'" -s "V" -l "version" -d "Print version" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session'" -s "V" -l "version" -d "Print version" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'project'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'project'" -s "V" -l "version" -d "Print version" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'projects'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'projects'" -s "V" -l "version" -d "Print version" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -s "V" -l "version" -d "Print version" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'recipe'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'recipe'" -s "V" -l "version" -d "Print version" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule'" -s "V" -l "version" -d "Print version" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'update'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'update'" -s "V" -l "version" -d "Print version" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'bench'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'bench'" -s "V" -l "version" -d "Print version" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'web'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'web'" -s "V" -l "version" -d "Print version" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'help'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'help'" -s "V" -l "version" -d "Print version" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'configure'" -s "h" -l "help" -d "Print help" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'info'" -s "v" -l "verbose" -d "Show verbose information including config.yaml" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'info'" -s "h" -l "help" -d "Print help" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'mcp'" -s "h" -l "help" -d "Print help" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'session'" -s "n" -l "name" -d "Specify a name for your chat session. When used with --resume, will resume this specific session if it exists." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'session'" -s "p" -l "path" -d "Specify a path for your chat session. When used with --resume, will resume this specific session if it exists." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'session'" -s "r" -l "resume" -d "Continue from a previous chat session. If --name or --path is provided, resumes that specific session. Otherwise resumes the last used session." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'session'" -l "history" -d "Show previous messages when resuming a session" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'session'" -l "debug" -d "When enabled, shows complete tool responses without truncation and full paths." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'session'" -l "max-tool-repetitions" -d "Set a limit on how many times the same tool can be called consecutively with identical parameters. Helps prevent infinite loops." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'session'" -l "max-turns" -d "Set a limit on how many turns (iterations) the agent can take without asking for user input to continue." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'session'" -l "with-extension" -d "Add stdio extensions from full commands with environment variables. Can be specified multiple times. Format: 'ENV1=val1 ENV2=val2 command args...'" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'session'" -l "with-remote-extension" -d "Add remote extensions from a URL. Can be specified multiple times. Format: 'url...'" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'session'" -l "with-streamable-http-extension" -d "Add streamable HTTP extensions from a URL. Can be specified multiple times. Format: 'url...'" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'session'" -l "with-builtin" -d "Add one or more builtin extensions that are bundled with goose by specifying their names, comma-separated" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'session'" -s "h" -l "help" -d "Print help (see a summary with '-h')" # global
complete -f -c "goose" -n "__fish_seen_subcommand_from 'session'" -a "list" -d "List all available sessions" # sub
complete -f -c "goose" -n "__fish_seen_subcommand_from 'session'" -a "remove" -d "Remove sessions. Runs interactively if no ID or regex is provided." # sub
complete -f -c "goose" -n "__fish_seen_subcommand_from 'session'" -a "export" -d "Export a session to Markdown format" # sub
complete -f -c "goose" -n "__fish_seen_subcommand_from 'session'" -a "help" -d "Print this message or the help of the given subcommand(s)" # sub
complete -c "goose" -n "__fish_seen_subcommand_from 'session list'" -s "n" -l "name" -d "Specify a name for your chat session. When used with --resume, will resume this specific session if it exists." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session list'" -s "p" -l "path" -d "Specify a path for your chat session. When used with --resume, will resume this specific session if it exists." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session list'" -s "r" -l "resume" -d "Continue from a previous chat session. If --name or --path is provided, resumes that specific session. Otherwise resumes the last used session." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session list'" -l "history" -d "Show previous messages when resuming a session" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session list'" -l "debug" -d "When enabled, shows complete tool responses without truncation and full paths." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session list'" -l "max-tool-repetitions" -d "Set a limit on how many times the same tool can be called consecutively with identical parameters. Helps prevent infinite loops." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session list'" -l "max-turns" -d "Set a limit on how many turns (iterations) the agent can take without asking for user input to continue." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session list'" -l "with-extension" -d "Add stdio extensions from full commands with environment variables. Can be specified multiple times. Format: 'ENV1=val1 ENV2=val2 command args...'" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session list'" -l "with-remote-extension" -d "Add remote extensions from a URL. Can be specified multiple times. Format: 'url...'" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session list'" -l "with-streamable-http-extension" -d "Add streamable HTTP extensions from a URL. Can be specified multiple times. Format: 'url...'" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session list'" -l "with-builtin" -d "Add one or more builtin extensions that are bundled with goose by specifying their names, comma-separated" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session list'" -s "h" -l "help" -d "Print help (see a summary with '-h')" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session remove'" -s "n" -l "name" -d "Specify a name for your chat session. When used with --resume, will resume this specific session if it exists." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session remove'" -s "p" -l "path" -d "Specify a path for your chat session. When used with --resume, will resume this specific session if it exists." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session remove'" -s "r" -l "resume" -d "Continue from a previous chat session. If --name or --path is provided, resumes that specific session. Otherwise resumes the last used session." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session remove'" -l "history" -d "Show previous messages when resuming a session" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session remove'" -l "debug" -d "When enabled, shows complete tool responses without truncation and full paths." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session remove'" -l "max-tool-repetitions" -d "Set a limit on how many times the same tool can be called consecutively with identical parameters. Helps prevent infinite loops." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session remove'" -l "max-turns" -d "Set a limit on how many turns (iterations) the agent can take without asking for user input to continue." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session remove'" -l "with-extension" -d "Add stdio extensions from full commands with environment variables. Can be specified multiple times. Format: 'ENV1=val1 ENV2=val2 command args...'" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session remove'" -l "with-remote-extension" -d "Add remote extensions from a URL. Can be specified multiple times. Format: 'url...'" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session remove'" -l "with-streamable-http-extension" -d "Add streamable HTTP extensions from a URL. Can be specified multiple times. Format: 'url...'" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session remove'" -l "with-builtin" -d "Add one or more builtin extensions that are bundled with goose by specifying their names, comma-separated" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session remove'" -s "h" -l "help" -d "Print help (see a summary with '-h')" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session export'" -s "n" -l "name" -d "Specify a name for your chat session. When used with --resume, will resume this specific session if it exists." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session export'" -s "p" -l "path" -d "Specify a path for your chat session. When used with --resume, will resume this specific session if it exists." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session export'" -s "r" -l "resume" -d "Continue from a previous chat session. If --name or --path is provided, resumes that specific session. Otherwise resumes the last used session." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session export'" -l "history" -d "Show previous messages when resuming a session" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session export'" -l "debug" -d "When enabled, shows complete tool responses without truncation and full paths." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session export'" -l "max-tool-repetitions" -d "Set a limit on how many times the same tool can be called consecutively with identical parameters. Helps prevent infinite loops." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session export'" -l "max-turns" -d "Set a limit on how many turns (iterations) the agent can take without asking for user input to continue." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session export'" -l "with-extension" -d "Add stdio extensions from full commands with environment variables. Can be specified multiple times. Format: 'ENV1=val1 ENV2=val2 command args...'" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session export'" -l "with-remote-extension" -d "Add remote extensions from a URL. Can be specified multiple times. Format: 'url...'" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session export'" -l "with-streamable-http-extension" -d "Add streamable HTTP extensions from a URL. Can be specified multiple times. Format: 'url...'" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session export'" -l "with-builtin" -d "Add one or more builtin extensions that are bundled with goose by specifying their names, comma-separated" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session export'" -s "h" -l "help" -d "Print help (see a summary with '-h')" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session help'" -s "n" -l "name" -d "Specify a name for your chat session. When used with --resume, will resume this specific session if it exists." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session help'" -s "p" -l "path" -d "Specify a path for your chat session. When used with --resume, will resume this specific session if it exists." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session help'" -s "r" -l "resume" -d "Continue from a previous chat session. If --name or --path is provided, resumes that specific session. Otherwise resumes the last used session." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session help'" -l "history" -d "Show previous messages when resuming a session" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session help'" -l "debug" -d "When enabled, shows complete tool responses without truncation and full paths." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session help'" -l "max-tool-repetitions" -d "Set a limit on how many times the same tool can be called consecutively with identical parameters. Helps prevent infinite loops." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session help'" -l "max-turns" -d "Set a limit on how many turns (iterations) the agent can take without asking for user input to continue." # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session help'" -l "with-extension" -d "Add stdio extensions from full commands with environment variables. Can be specified multiple times. Format: 'ENV1=val1 ENV2=val2 command args...'" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session help'" -l "with-remote-extension" -d "Add remote extensions from a URL. Can be specified multiple times. Format: 'url...'" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session help'" -l "with-streamable-http-extension" -d "Add streamable HTTP extensions from a URL. Can be specified multiple times. Format: 'url...'" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session help'" -l "with-builtin" -d "Add one or more builtin extensions that are bundled with goose by specifying their names, comma-separated" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session help'" -s "h" -l "help" -d "Print help (see a summary with '-h')" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'session list'" -s "v" -l "verbose" -d "List all available sessions" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'session list'" -s "f" -l "format" -d "Output format" -xa "text json" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'session list'" -l "ascending" -d "Sort sessions by date in ascending order (oldest first). Default is descending order (newest first)." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'session list'" -s "h" -l "help" -d "Print help (see a summary with '-h')" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'session remove'" -s "i" -l "id" -d "Session ID to be removed (optional)" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'session remove'" -s "r" -l "regex" -d "Regex for removing matched sessions (optional)" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'session remove'" -s "h" -l "help" -d "Print help" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'session export'" -s "n" -l "name" -d "Specify a name for your chat session. When used with --resume, will resume this specific session if it exists." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'session export'" -s "p" -l "path" -d "Specify a path for your chat session. When used with --resume, will resume this specific session if it exists." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'session export'" -s "o" -l "output" -d "Path to save the exported Markdown. If not provided, output will be sent to stdout" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'session export'" -s "h" -l "help" -d "Print help (see a summary with '-h')" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'project'" -s "h" -l "help" -d "Print help" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'projects'" -s "h" -l "help" -d "Print help" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -s "i" -l "instructions" -d "Path to instruction file containing commands. Use - for stdin." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -s "t" -l "text" -d "Input text containing commands for Goose. Use this in lieu of the instructions argument." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -l "system" -d "Provide additional system instructions to customize the agent's behavior" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -l "recipe" -d "Recipe name to get recipe file or the full path of the recipe file that defines a custom agent configuration. Use --explain to see the recipe's title, description, and parameters." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -l "params" -d "Key-value parameters to pass to the recipe file. Can be specified multiple times." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -s "s" -l "interactive" -d "Continue in interactive mode after processing initial input" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -l "no-session" -d "Execute commands without creating or using a session file. Useful for automated runs." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -l "explain" -d "Show the recipe title, description, and parameters" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -l "render-recipe" -d "Print the rendered recipe instead of running it." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -l "max-tool-repetitions" -d "Set a limit on how many times the same tool can be called consecutively with identical parameters. Helps prevent infinite loops." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -l "max-turns" -d "Set a limit on how many turns (iterations) the agent can take without asking for user input to continue." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -s "n" -l "name" -d "Specify a name for your chat session. When used with --resume, will resume this specific session if it exists." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -s "p" -l "path" -d "Specify a path for your chat session. When used with --resume, will resume this specific session if it exists." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -s "r" -l "resume" -d "Continue from a previous run, maintaining the execution state and context." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -l "debug" -d "When enabled, shows complete tool responses without truncation and full paths." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -l "with-extension" -d "Add stdio extensions from full commands with environment variables. Can be specified multiple times. Format: 'ENV1=val1 ENV2=val2 command args...'" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -l "with-remote-extension" -d "Add remote extensions. Can be specified multiple times. Format: 'url...'" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -l "with-streamable-http-extension" -d "Add streamable HTTP extensions. Can be specified multiple times. Format: 'url...'" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -l "with-builtin" -d "Add one or more builtin extensions that are bundled with goose by specifying their names, comma-separated" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -s "q" -l "quiet" -d "Quiet mode. Suppress non-response output, printing only the model response to stdout" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -l "sub-recipe" -d "Specify sub-recipes to include alongside the main recipe. Can be:\n            - Recipe names from GitHub (if GOOSE_RECIPE_GITHUB_REPO is configured)\n            - Local file paths to YAML files\n          Can be specified multiple times to include multiple sub-recipes." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -l "provider" -d "Override the GOOSE_PROVIDER environment variable for this run. Available providers include openai, anthropic, ollama, databricks, gemini-cli, claude-code, and others." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -l "model" -d "Override the GOOSE_MODEL environment variable for this run. The model must be supported by the specified provider." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'run'" -s "h" -l "help" -d "Print help (see a summary with '-h')" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'recipe'" -s "h" -l "help" -d "Print help" # global
complete -f -c "goose" -n "__fish_seen_subcommand_from 'recipe'" -a "validate" -d "Validate a recipe" # sub
complete -f -c "goose" -n "__fish_seen_subcommand_from 'recipe'" -a "deeplink" -d "Generate a deeplink for a recipe" # sub
complete -f -c "goose" -n "__fish_seen_subcommand_from 'recipe'" -a "list" -d "List available recipes" # sub
complete -f -c "goose" -n "__fish_seen_subcommand_from 'recipe'" -a "help" -d "Print this message or the help of the given subcommand(s)" # sub
complete -c "goose" -n "__fish_seen_subcommand_from 'recipe validate'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'recipe deeplink'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'recipe list'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'recipe help'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'recipe validate'" -s "h" -l "help" -d "Print help" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'recipe deeplink'" -s "h" -l "help" -d "Print help" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'recipe list'" -s "v" -l "verbose" -d "Show verbose information including recipe descriptions" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'recipe list'" -s "h" -l "help" -d "Print help" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'recipe list'" -l "format" -d "Output format" -xa "text json" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule'" -s "h" -l "help" -d "Print help" # global
complete -f -c "goose" -n "__fish_seen_subcommand_from 'schedule'" -a "add" -d "Add a new scheduled job" # sub
complete -f -c "goose" -n "__fish_seen_subcommand_from 'schedule'" -a "list" -d "List all scheduled jobs" # sub
complete -f -c "goose" -n "__fish_seen_subcommand_from 'schedule'" -a "remove" -d "Remove a scheduled job by ID" # sub
complete -f -c "goose" -n "__fish_seen_subcommand_from 'schedule'" -a "sessions" -d "List sessions created by a specific schedule" # sub
complete -f -c "goose" -n "__fish_seen_subcommand_from 'schedule'" -a "run-now" -d "Run a scheduled job immediately" # sub
complete -f -c "goose" -n "__fish_seen_subcommand_from 'schedule'" -a "services-status" -d "Check status of Temporal services" # sub
complete -f -c "goose" -n "__fish_seen_subcommand_from 'schedule'" -a "services-stop" -d "Stop Temporal services" # sub
complete -f -c "goose" -n "__fish_seen_subcommand_from 'schedule'" -a "cron-help" -d "Show cron expression examples and help" # sub
complete -f -c "goose" -n "__fish_seen_subcommand_from 'schedule'" -a "help" -d "Print this message or the help of the given subcommand(s)" # sub
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule add'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule list'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule remove'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule sessions'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule run-now'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule services-status'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule services-stop'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule cron-help'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule help'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule add'" -l "id" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule add'" -l "cron" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule add'" -l "recipe-source" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule add'" -s "h" -l "help" -d "Print help (see a summary with '-h')" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule list'" -s "h" -l "help" -d "Print help" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule remove'" -l "id" -d "ID of the job to remove" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule remove'" -s "h" -l "help" -d "Print help" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule sessions'" -s "h" -l "help" -d "Print help" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule sessions'" -l "id" -d "ID of the schedule" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule sessions'" -l "limit" -d "Maximum number of sessions to return" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule run-now'" -s "h" -l "help" -d "Print help" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule run-now'" -l "id" -d "ID of the schedule to run" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule services-status'" -s "h" -l "help" -d "Print help" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule services-stop'" -s "h" -l "help" -d "Print help" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'schedule cron-help'" -s "h" -l "help" -d "Print help" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'update'" -s "c" -l "canary" -d "Update to the latest canary version of the goose CLI, otherwise updates to the latest stable version." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'update'" -s "r" -l "reconfigure" -d "Enforce to re-configure goose during update" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'update'" -s "h" -l "help" -d "Print help (see a summary with '-h')" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'bench'" -s "h" -l "help" -d "Print help" # global
complete -f -c "goose" -n "__fish_seen_subcommand_from 'bench'" -a "init-config" -d "Create a new starter-config" # sub
complete -f -c "goose" -n "__fish_seen_subcommand_from 'bench'" -a "run" -d "Run all benchmarks from a config" # sub
complete -f -c "goose" -n "__fish_seen_subcommand_from 'bench'" -a "selectors" -d "List all available selectors" # sub
complete -f -c "goose" -n "__fish_seen_subcommand_from 'bench'" -a "eval-model" -d "Run an eval of model" # sub
complete -f -c "goose" -n "__fish_seen_subcommand_from 'bench'" -a "exec-eval" -d "run a single eval" # sub
complete -f -c "goose" -n "__fish_seen_subcommand_from 'bench'" -a "generate-leaderboard" -d "Generate a leaderboard CSV from benchmark results" # sub
complete -f -c "goose" -n "__fish_seen_subcommand_from 'bench'" -a "help" -d "Print this message or the help of the given subcommand(s)" # sub
complete -c "goose" -n "__fish_seen_subcommand_from 'bench init-config'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'bench run'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'bench selectors'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'bench eval-model'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'bench exec-eval'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'bench generate-leaderboard'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'bench help'" -s "h" -l "help" -d "Print help" # subcommands flags
complete -c "goose" -n "__fish_seen_subcommand_from 'bench init-config'" -s "n" -l "name" -d "filename with extension for generated config" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'bench init-config'" -s "h" -l "help" -d "Print help" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'bench run'" -s "c" -l "config" -d "A config file generated by the config-init command" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'bench run'" -s "h" -l "help" -d "Print help" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'bench selectors'" -s "c" -l "config" -d "A config file generated by the config-init command" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'bench selectors'" -s "h" -l "help" -d "Print help" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'bench eval-model'" -s "c" -l "config" -d "A serialized config file for the model only." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'bench eval-model'" -s "h" -l "help" -d "Print help" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'bench exec-eval'" -s "c" -l "config" -d "A serialized config file for the eval only." # global
complete -c "goose" -n "__fish_seen_subcommand_from 'bench exec-eval'" -s "h" -l "help" -d "Print help" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'bench generate-leaderboard'" -s "b" -l "benchmark-dir" -d "Path to the benchmark directory containing model evaluation results" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'bench generate-leaderboard'" -s "h" -l "help" -d "Print help" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'web'" -s "p" -l "port" -d "Port to run the web server on" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'web'" -l "host" -d "Host to bind the web server to" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'web'" -l "open" -d "Open browser automatically when server starts" # global
complete -c "goose" -n "__fish_seen_subcommand_from 'web'" -s "h" -l "help" -d "Print help" # global