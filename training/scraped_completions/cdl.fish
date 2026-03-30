set -l cdl_commands init
complete -f -c cdl -n "not __fish_seen_subcommand_from $cdl_commands" -a cdl_commands -a init -d "create a new 🦑 cdl.fish"
