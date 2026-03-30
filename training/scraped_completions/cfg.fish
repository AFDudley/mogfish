# Disable file completions
complete -c cfg -f

function __fish_cfg_complete_no_subcommand
    for i in (commandline -opc)
        if contains -- $i (ls -d ~/dotfiles/*/)
            return 1
        end
    end
    return 0
end

for dir in (ls -d ~/dotfiles/*/ | xargs -n 1 basename)
    complete -c cfg -n __fish_cfg_complete_no_subcommand -a $dir -d "Change directory to ~/dotfiles/$dir"
end
