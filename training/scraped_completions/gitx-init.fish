complete -c gitx-init -d 'Create a new gitx repo that can track files from anywhere on your system'
complete -c gitx-init -l dry-run -d 'Preview what would happen without making changes'

function __gitx_init_needs_repo
    set -l words (commandline -opc)
    set -e words[1]

    set -l positional
    for w in $words
        switch $w
            case --dry-run
                continue
            case '-*'
                continue
            case '*'
                set positional $positional $w
        end
    end

    if test (count $positional) -eq 0
        return 0
    end

    if test (count $positional) -eq 1
        set -l current (commandline -ct)
        if test -n "$current"
            return 0
        end
    end

    return 1
end

complete -c gitx-init -n '__gitx_init_needs_repo' -f -a '(for d in ~/.gitx/repos/*; test -d "$d"; and basename "$d"; end)' -d 'Repo name'
