# Fish completions for GitHub Copilot CLI

# Disable file completion by default
complete -c copilot -f

# Options
complete -c copilot -l effort -xa 'low medium high xhigh' -d 'Set the reasoning effort level'
complete -c copilot -l acp -d 'Start as Agent Client Protocol server'
complete -c copilot -l add-dir -r -a '(__fish_complete_directories)' -d 'Add a directory to the allowed list for file access'
complete -c copilot -l add-github-mcp-tool -r -d 'Add a tool to enable for the GitHub MCP server instead of the default CLI subset'
complete -c copilot -l add-github-mcp-toolset -r -d 'Add a toolset to enable for the GitHub MCP server instead of the default CLI subset'
complete -c copilot -l additional-mcp-config -r -d 'Additional MCP servers configuration as JSON string or file path (prefix with @)'
complete -c copilot -l agent -x -a '(__fish_copilot_agents)' -d 'Specify a custom agent to use'
complete -c copilot -l allow-all -d 'Enable all permissions (equivalent to --allow-all-tools --allow-all-paths --allow-all-urls)'
complete -c copilot -l allow-all-paths -d 'Disable file path verification and allow access to any path'
complete -c copilot -l allow-all-tools -d 'Allow all tools to run automatically without confirmation; required for non-interactive mode'
complete -c copilot -l allow-all-urls -d 'Allow access to all URLs without confirmation'
complete -c copilot -l allow-tool -r -d 'Tools the CLI has permission to use; will not prompt for permission'
complete -c copilot -l allow-url -r -d 'Allow access to specific URLs or domains'
complete -c copilot -l autopilot -d 'Enable autopilot continuation in prompt mode'
complete -c copilot -l available-tools -r -d 'Only these tools will be available to the model'
complete -c copilot -l banner -d 'Show the startup banner'
complete -c copilot -l bash-env -xa 'on off' -d 'Enable BASH_ENV support for bash shells (on|off)'
complete -c copilot -l config-dir -r -a '(__fish_complete_directories)' -d 'Set the configuration directory'
complete -c copilot -l continue -d 'Resume the most recent session'
complete -c copilot -l deny-tool -r -d 'Tools the CLI does not have permission to use; will not prompt for permission'
complete -c copilot -l deny-url -r -d 'Deny access to specific URLs or domains'
complete -c copilot -l disable-builtin-mcps -d 'Disable all built-in MCP servers'
complete -c copilot -l disable-mcp-server -r -d 'Disable a specific MCP server'
complete -c copilot -l disallow-temp-dir -d 'Prevent automatic access to the system temporary directory'
complete -c copilot -l enable-all-github-mcp-tools -d 'Enable all GitHub MCP server tools instead of the default CLI subset'
complete -c copilot -l enable-reasoning-summaries -d 'Request reasoning summaries for OpenAI models'
complete -c copilot -l excluded-tools -r -d 'These tools will not be available to the model'
complete -c copilot -l experimental -d 'Enable experimental features'
complete -c copilot -l no-experimental -d 'Disable experimental features'
complete -c copilot -s h -l help -d 'display help for command'
complete -c copilot -s i -l interactive -r -d 'Start interactive mode and automatically execute this prompt'
complete -c copilot -l log-dir -r -a '(__fish_complete_directories)' -d 'Set log file directory'
complete -c copilot -l log-level -xa 'none error warning info debug all default' -d 'Set the log level'
complete -c copilot -l max-autopilot-continues -r -d 'Maximum number of continuation messages in autopilot mode (default: unlimited)'
complete -c copilot -l model -x -a '(__fish_copilot_models)' -d 'Set the AI model to use'
complete -c copilot -l mouse -xa 'on off' -d 'Enable mouse support in alt screen mode (on|off)'
complete -c copilot -l no-ask-user -d 'Disable the ask_user tool (agent works autonomously without asking questions)'
complete -c copilot -l no-auto-update -d 'Disable downloading CLI update automatically'
complete -c copilot -l no-bash-env -d 'Disable BASH_ENV support for bash shells'
complete -c copilot -l no-color -d 'Disable all color output'
complete -c copilot -l no-custom-instructions -d 'Disable loading of custom instructions from AGENTS.md and related files'
complete -c copilot -s p -l prompt -r -d 'Execute a prompt in non-interactive mode (exits after completion)'
complete -c copilot -l output-format -xa 'text json' -d 'Output format: ''text'' (default) or ''json'' (JSONL, one JSON object per line)'
complete -c copilot -l plain-diff -d 'Disable rich diff rendering'
complete -c copilot -l plugin-dir -r -a '(__fish_complete_directories)' -d 'Load a plugin from a local directory (can be used multiple times)'
complete -c copilot -l reasoning-effort -xa 'low medium high xhigh' -d 'Set the reasoning effort level'
complete -c copilot -l no-mouse -d 'Disable mouse support in alt screen mode'
complete -c copilot -l resume -d 'Resume from a previous session (optionally specify session ID or task ID)'
complete -c copilot -s s -l silent -d 'Output only the agent response (no stats), useful for scripting with -p'
complete -c copilot -l screen-reader -d 'Enable screen reader optimizations'
complete -c copilot -l secret-env-vars -r -d 'Environment variable names whose values are stripped from shell and MCP server environments and redacted from output'
complete -c copilot -l share -F -d 'Share session to markdown file after completion in non-interactive mode'
complete -c copilot -l share-gist -d 'Share session to a secret GitHub gist after completion in non-interactive mode'
complete -c copilot -l stream -xa 'on off' -d 'Enable or disable streaming mode'
complete -c copilot -s v -l version -d 'show version information'
complete -c copilot -l yolo -d 'Enable all permissions (equivalent to --allow-all-tools --allow-all-paths --allow-all-urls)'

# Commands
complete -c copilot -n __fish_use_subcommand -a help -d 'Display help information'
complete -c copilot -n __fish_use_subcommand -a init -d 'Initialize Copilot instructions'
complete -c copilot -n __fish_use_subcommand -a login -d 'Authenticate with Copilot'
complete -c copilot -n __fish_use_subcommand -a plugin -d 'Manage plugins'
complete -c copilot -n __fish_use_subcommand -a update -d 'Download the latest version'
complete -c copilot -n __fish_use_subcommand -a version -d 'Display version information'

# init subcommand options
complete -c copilot -n '__fish_seen_subcommand_from init' -s h -l help -d 'display help for command'

# update subcommand options
complete -c copilot -n '__fish_seen_subcommand_from update' -s h -l help -d 'display help for command'

# version subcommand options
complete -c copilot -n '__fish_seen_subcommand_from version' -s h -l help -d 'display help for command'

# help subcommand options
complete -c copilot -n '__fish_seen_subcommand_from help' -s h -l help -d 'display help for command'

# login subcommand options
complete -c copilot -n '__fish_seen_subcommand_from login' -l host -r -d 'GitHub host URL'
complete -c copilot -n '__fish_seen_subcommand_from login' -l config-dir -r -a '(__fish_complete_directories)' -d 'Set the configuration directory'
complete -c copilot -n '__fish_seen_subcommand_from login' -s h -l help -d 'display help for command'

# plugin subcommand
complete -c copilot -n '__fish_seen_subcommand_from plugin; and not __fish_seen_subcommand_from install uninstall update list marketplace' -s h -l help -d 'display help for command'
complete -c copilot -n '__fish_seen_subcommand_from plugin; and not __fish_seen_subcommand_from install uninstall update list marketplace' -a install -d 'Install a plugin'
complete -c copilot -n '__fish_seen_subcommand_from plugin; and not __fish_seen_subcommand_from install uninstall update list marketplace' -a uninstall -d 'Uninstall a plugin'
complete -c copilot -n '__fish_seen_subcommand_from plugin; and not __fish_seen_subcommand_from install uninstall update list marketplace' -a update -d 'Update a plugin to the latest version'
complete -c copilot -n '__fish_seen_subcommand_from plugin; and not __fish_seen_subcommand_from install uninstall update list marketplace' -a list -d 'List installed plugins'
complete -c copilot -n '__fish_seen_subcommand_from plugin; and not __fish_seen_subcommand_from install uninstall update list marketplace' -a marketplace -d 'Manage plugin marketplaces'

# plugin install/uninstall/update/list options
complete -c copilot -n '__fish_seen_subcommand_from plugin; and __fish_seen_subcommand_from install uninstall update list' -l config-dir -r -a '(__fish_complete_directories)' -d 'Path to the configuration directory'
complete -c copilot -n '__fish_seen_subcommand_from plugin; and __fish_seen_subcommand_from install uninstall update list' -s h -l help -d 'display help for command'

# plugin install/uninstall/update arguments
complete -c copilot -n '__fish_seen_subcommand_from plugin; and __fish_seen_subcommand_from install' -xa '(__fish_copilot_marketplace_plugins)' -d 'Plugin source (plugin@marketplace, owner/repo, owner/repo:path, or URL)'
complete -c copilot -n '__fish_seen_subcommand_from plugin; and __fish_seen_subcommand_from uninstall' -xa '(__fish_copilot_installed_plugins)' -d 'Plugin name (plugin-name or plugin-name@marketplace-name)'
complete -c copilot -n '__fish_seen_subcommand_from plugin; and __fish_seen_subcommand_from update' -xa '(__fish_copilot_installed_plugins)' -d 'Plugin name (plugin-name@marketplace-name)'

# plugin marketplace subcommand
complete -c copilot -n '__fish_seen_subcommand_from plugin marketplace; and not __fish_seen_subcommand_from add remove list browse' -s h -l help -d 'display help for command'
complete -c copilot -n '__fish_seen_subcommand_from plugin; and __fish_seen_subcommand_from marketplace; and not __fish_seen_subcommand_from add remove list browse' -a add -d 'Add a marketplace'
complete -c copilot -n '__fish_seen_subcommand_from plugin; and __fish_seen_subcommand_from marketplace; and not __fish_seen_subcommand_from add remove list browse' -a remove -d 'Remove a marketplace'
complete -c copilot -n '__fish_seen_subcommand_from plugin; and __fish_seen_subcommand_from marketplace; and not __fish_seen_subcommand_from add remove list browse' -a list -d 'List registered marketplaces'
complete -c copilot -n '__fish_seen_subcommand_from plugin; and __fish_seen_subcommand_from marketplace; and not __fish_seen_subcommand_from add remove list browse' -a browse -d 'Browse plugins in a marketplace'

# plugin marketplace subcommand options
complete -c copilot -n '__fish_seen_subcommand_from plugin; and __fish_seen_subcommand_from marketplace; and __fish_seen_subcommand_from add remove list browse' -l config-dir -r -a '(__fish_complete_directories)' -d 'Path to the configuration directory'
complete -c copilot -n '__fish_seen_subcommand_from plugin; and __fish_seen_subcommand_from marketplace; and __fish_seen_subcommand_from add remove list browse' -s h -l help -d 'display help for command'
complete -c copilot -n '__fish_seen_subcommand_from plugin; and __fish_seen_subcommand_from marketplace; and __fish_seen_subcommand_from remove' -s f -l force -d 'Force removal even if plugins are installed'

# plugin marketplace arguments
complete -c copilot -n '__fish_seen_subcommand_from plugin; and __fish_seen_subcommand_from marketplace; and __fish_seen_subcommand_from add' -F -d 'Marketplace source (owner/repo, URL, or local path)'
complete -c copilot -n '__fish_seen_subcommand_from plugin; and __fish_seen_subcommand_from marketplace; and __fish_seen_subcommand_from browse' -xa '(__fish_copilot_marketplaces)' -d 'Marketplace name'
complete -c copilot -n '__fish_seen_subcommand_from plugin; and __fish_seen_subcommand_from marketplace; and __fish_seen_subcommand_from remove' -xa '(__fish_copilot_marketplaces)' -d 'Marketplace name'

# Help topics
complete -c copilot -n '__fish_seen_subcommand_from help' -a 'commands' -d 'Interactive Mode Commands'
complete -c copilot -n '__fish_seen_subcommand_from help' -a 'config' -d 'Configuration Settings'
complete -c copilot -n '__fish_seen_subcommand_from help' -a 'environment' -d 'Environment Variables'
complete -c copilot -n '__fish_seen_subcommand_from help' -a 'logging' -d 'Logging'
complete -c copilot -n '__fish_seen_subcommand_from help' -a 'permissions' -d 'Permissions'
complete -c copilot -n '__fish_seen_subcommand_from help' -a 'providers' -d 'Custom Model Providers (BYOK)'
