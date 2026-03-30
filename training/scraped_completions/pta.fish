function __find_file
    set -l cmd (commandline -xpc)
    set -l dir ""
    if set -q cmd[2]
        set dir $cmd[2]
    end
    if test -n "$dir" && test -d ~/Codes/CPP/C++/PTA/$dir
        ls ~/Codes/CPP/C++/PTA/$dir
    end
end

complete -c pta -n __fish_use_subcommand -a "(ls ~/Codes/CPP/C++/PTA)" -f
complete -c pta -n '__fish_seen_subcommand_from (ls ~/Codes/CPP/C++/PTA)' -a "(__find_file)" -f
