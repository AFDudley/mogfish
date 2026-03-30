function __fish_docflow_using_command
    set cmd (commandline -opc)
    if test (count $cmd) -ge 2
        return 0
    end
    return 1
end

function __fish_docflow_commands
    printf "%s\n" validate compliance scan plan recommend template-sets templates template-impact stats migrate-sections queue history health quickstart
end

complete -c docflow -f -n "not __fish_docflow_using_command" -a "(__fish_docflow_commands)"
