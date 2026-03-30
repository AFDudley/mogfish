function __find_file
    set -l cmd (commandline -xpc)
    set -l dir ""
    if set -q cmd[2]
        set dir $cmd[2]
    end
    if test -n "$dir"
        if test -d ~/Codes/CPP/C/OJ/$dir
            ls ~/Codes/CPP/C/OJ/$dir
        end
    end
end

complete -c Oj -n __fish_use_subcommand -a "(ls ~/Codes/CPP/C/OJ)" -f
complete -c Oj -n '__fish_seen_subcommand_from (ls ~/Codes/CPP/C/OJ)' -a "(__find_file)" -f
