complete -c "interpreter" -s "h" -l "help" -d "show this help message and exit" # global
complete -c "interpreter" -s "p" -l "profile" -d "name of profile. run `--profiles` to open profile directory" # global
complete -c "interpreter" -s "ci" -l "custom_instructions" -d "custom instructions for the language model. will be appended to the system_message" # global
complete -c "interpreter" -s "sm" -l "system_message" -d "(we don't recommend changing this) base prompt for the language model" # global
complete -c "interpreter" -s "y" -l "auto_run" -d "automatically run generated code" # global
complete -c "interpreter" -s "nhl" -l "no_highlight_active_line" -d "turn off active line highlighting in code blocks" # global
complete -c "interpreter" -s "v" -l "verbose" -d "print detailed logs" # global
complete -c "interpreter" -s "m" -l "model" -d "language model to use" # global
complete -c "interpreter" -s "t" -l "temperature" -d "optional temperature setting for the language model" # global
complete -c "interpreter" -s "lsv" -o "llm_supports_vision" -d "inform OI that your model supports vision, and can receive vision inputs" # global
complete -c "interpreter" -s "lsf" -o "llm_supports_functions" -d "inform OI that your model supports OpenAI-style functions, and can make function calls" # global
complete -c "interpreter" -s "cw" -l "context_window" -d "optional context window size for the language model" # global
complete -c "interpreter" -s "x" -l "max_tokens" -d "optional maximum number of tokens for the language model" # global
complete -c "interpreter" -s "b" -l "max_budget" -d "optionally set the max budget (in USD) for your llm calls" # global
complete -c "interpreter" -s "ab" -l "api_base" -d "optionally set the API base URL for your llm calls (this will override environment variables)" # global
complete -c "interpreter" -s "ak" -l "api_key" -d "optionally set the API key for your llm calls (this will override environment variables)" # global
complete -c "interpreter" -s "av" -l "api_version" -d "optionally set the API version for your llm calls (this will override environment variables)" # global
complete -c "interpreter" -s "xo" -l "max_output" -d "optional maximum number of characters for code outputs" # global
complete -c "interpreter" -l "loop" -d "runs OI in a loop, requiring it to admit to completing/failing task" # global
complete -c "interpreter" -s "dt" -l "disable_telemetry" -d "disables sending of basic anonymous usage stats" # global
complete -c "interpreter" -s "o" -l "offline" -d "turns off all online features (except the language model, if it's hosted)" # global
complete -c "interpreter" -s "sp" -l "speak_messages" -d "(Mac only, experimental) use the applescript `say` command to read messages aloud" # global
complete -c "interpreter" -l "safe_mode" -d "optionally enable safety mechanisms like code scanning; valid options are off, ask, and auto" -xa "off ask auto" # global
complete -c "interpreter" -o "debug" -d "debug mode for open interpreter developers" # global
complete -c "interpreter" -s "f" -l "fast" -d "runs `interpreter --model gpt-4o-mini` and asks OI to be extremely concise (shortcut for `interpreter --profile fast`)" # global
complete -c "interpreter" -s "ml" -l "multi_line" -d "enable multi-line inputs starting and ending with ```" # global
complete -c "interpreter" -s "l" -l "local" -d "setup a local model (shortcut for `interpreter --profile local`)" # global
complete -c "interpreter" -l "codestral" -d "shortcut for `interpreter --profile codestral`" # global
complete -c "interpreter" -l "assistant" -d "shortcut for `interpreter --profile assistant.py`" # global
complete -c "interpreter" -l "llama3" -d "shortcut for `interpreter --profile llama3`" # global
complete -c "interpreter" -l "groq" -d "shortcut for `interpreter --profile groq`" # global
complete -c "interpreter" -s "vi" -l "vision" -d "experimentally use vision for supported languages (shortcut for `interpreter --profile vision`)" # global
complete -c "interpreter" -s "os" -l "os" -d "experimentally let Open Interpreter control your mouse and keyboard (shortcut for `interpreter --profile os`)" # global
complete -c "interpreter" -l "reset_profile" -d "reset a profile file. run `--reset_profile` without an argument to reset all default profiles" # global
complete -c "interpreter" -l "profiles" -d "opens profiles directory" # global
complete -c "interpreter" -l "local_models" -d "opens local models directory" # global
complete -c "interpreter" -l "conversations" -d "list conversations to resume" # global
complete -c "interpreter" -l "server" -d "start open interpreter as a server" # global
complete -c "interpreter" -l "version" -d "get Open Interpreter's version number" # global
complete -c "interpreter" -l "contribute_conversation" -d "let Open Interpreter use the current conversation to train an Open-Source LLM" # global
complete -c "interpreter" -s "pl" -l "plain" -d "set output to plain text" # global
complete -c "interpreter" -s "s" -l "stdin" -d "Run OI in stdin mode" # global