complete -c "trae-cli" -l "version" -d "Show the version and exit." # global
complete -c "trae-cli" -l "help" -d "Show this message and exit." # global
complete -f -c "trae-cli" -n "__fish_use_subcommand" -a "interactive" -d "This function starts an interactive session with Trae Agent." # sub
complete -f -c "trae-cli" -n "__fish_use_subcommand" -a "run" -d "Run is the main function of trae." # sub
complete -f -c "trae-cli" -n "__fish_use_subcommand" -a "show-config" -d "Show current configuration settings." # sub
complete -f -c "trae-cli" -n "__fish_use_subcommand" -a "tools" -d "Show available tools and their descriptions." # sub
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'interactive'" -s "p" -l "provider" -d "LLM provider to use" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'interactive'" -s "m" -l "model" -d "Specific model to use" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'interactive'" -l "model-base-url" -d "Base URL for the model API" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'interactive'" -s "k" -l "api-key" -d "API key (or set via environment variable)" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'interactive'" -l "config-file" -d "Path to configuration file" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'interactive'" -l "max-steps" -d "Maximum number of execution steps" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'interactive'" -s "t" -l "trajectory-file" -d "Path to save trajectory file" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'interactive'" -s "ct" -l "console-type" -d "Type of console to use (simple or rich)" -xa "simple rich" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'interactive'" -s "at" -l "agent-type" -d "Type of agent to use (trae_agent)" -xa "trae_agent" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'interactive'" -l "help" -d "Show this message and exit." # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'run'" -s "f" -l "file" -d "Path to a file containing the task description." # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'run'" -s "p" -l "provider" -d "LLM provider to use" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'run'" -s "m" -l "model" -d "Specific model to use" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'run'" -l "model-base-url" -d "Base URL for the model API" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'run'" -s "k" -l "api-key" -d "API key (or set via environment variable)" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'run'" -l "max-steps" -d "Maximum number of execution steps" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'run'" -s "w" -l "working-dir" -d "Working directory for the agent" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'run'" -s "mp" -l "must-patch" -d "Whether to patch the code" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'run'" -l "config-file" -d "Path to configuration file" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'run'" -s "t" -l "trajectory-file" -d "Path to save trajectory file" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'run'" -s "pp" -l "patch-path" -d "Path to patch file" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'run'" -l "docker-image" -d "Specify a Docker image to run the task in a new container" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'run'" -l "docker-container-id" -d "Attach to an existing Docker container by ID" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'run'" -l "dockerfile-path" -d "Absolute path to a Dockerfile to build an environment" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'run'" -l "docker-image-file" -d "Path to a local Docker image file (tar archive) to load." # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'run'" -l "docker-keep" -d "Keep or remove the Docker container after finishing the task" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'run'" -s "ct" -l "console-type" -d "Type of console to use (simple or rich)" -xa "simple rich" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'run'" -s "at" -l "agent-type" -d "Type of agent to use (trae_agent)" -xa "trae_agent" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'run'" -l "help" -d "Show this message and exit." # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'show-config'" -l "config-file" -d "Path to configuration file" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'show-config'" -s "p" -l "provider" -d "LLM provider to use" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'show-config'" -s "m" -l "model" -d "Specific model to use" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'show-config'" -l "model-base-url" -d "Base URL for the model API" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'show-config'" -s "k" -l "api-key" -d "API key (or set via environment variable)" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'show-config'" -l "max-steps" -d "Maximum number of execution steps" # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'show-config'" -l "help" -d "Show this message and exit." # global
complete -c "trae-cli" -n "__fish_seen_subcommand_from 'tools'" -l "help" -d "Show this message and exit." # global