# Fish completion for sshh

complete -c sshh -f

complete -c sshh -n "__fish_use_subcommand" -a "list" -d "List all configured hosts"
complete -c sshh -n "__fish_use_subcommand" -a "edit" -d "Edit config file"
complete -c sshh -n "__fish_use_subcommand" -a "add" -d "Add a new host"
complete -c sshh -n "__fish_use_subcommand" -a "remove rm" -d "Remove a host by number"
complete -c sshh -n "__fish_use_subcommand" -a "config" -d "Show config file path"
complete -c sshh -n "__fish_use_subcommand" -a "version" -d "Show version"
complete -c sshh -n "__fish_use_subcommand" -a "help" -d "Show help"

# Complete host numbers
function __sshh_hosts
    set -l config "$HOME/.sshh"
    if test -n "$SSHH_CONFIG"
        set config "$SSHH_CONFIG"
    end

    if test -f "$config"
        set -l i 1
        while read -l line
            if not string match -q "#*" -- "$line"; and test -n "$line"
                set -l name (string split "|" -- "$line")[1]
                set name (string trim -- "$name")
                echo "$i\t$name"
                set i (math $i + 1)
            end
        end < "$config"
    end
end

complete -c sshh -n "__fish_use_subcommand" -a "(__sshh_hosts)"
complete -c sshh -n "__fish_seen_subcommand_from remove rm" -a "(__sshh_hosts)"
