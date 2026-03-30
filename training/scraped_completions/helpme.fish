
function __help_keybind
    # REFACTOR: do we need this?
    set -l reset (set_color normal)

    # https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797#cursor-controls
    printf "\x1b[0G" # Move cursor to the start of the line (0'th column).
    # NOTE: assumes prompt only takes up one line. could probably be checked by running `fish_prompt`
    printf "\x1b[2K" # Clear the current line, to erase the leftover (partial) prompt.

    set -l tokens (commandline --current-process --tokenize)
    if test (count $tokens) -eq 0
        printf "%shint%s: this keybind, i.e. %s%s%s, only does something, if (%s%s) has one or more tokens in it ;)\n" (set_color cyan) $reset (set_color $fish_color_command) (status function) $reset (printf "commandline --current-process" | fish_indent --ansi) $reset
    else
        # TODO: if function, check if description points to an alias, and if so the recursively expand to the inner command
        set -l program $tokens[1]
        if functions --query $program
            type $program
        else
            printf '%serror%s: %s is not a %sfish%s function\n' (set_color red) $reset $program (set_color blue) $reset
            if command --query $program
                printf '%shint%s:  %s is a command at %s%s%s\n' (set_color magenta) $reset $program (set_color cyan) (command --search $program) $reset
            else if builtin --query $program
                printf '%shint%s:  %s is a builtin %sfish%s command\n' (set_color magenta) $reset $program (set_color blue) $reset
            end
        end
    end

    echo todo

    commandline --function repaint
end

bind \eh __help_keybind

if command -q bat
    # if not type -q bathelp
    function bathelp
        command bat --plain --language=help
    end
    # end

    function __helpme_bathelp_abbr
        # FIXME: only expand if the buffer is not empty, and a valid program is typed
        # TODO: use the output of `complete $command` to see if the program accepts
        # (-h|--help) for help information. The vast majority of programs do, but not all
        # Some use (-H|--help) example needed ...
        set -l buf (commandline)
        set -l cursor (commandline --cursor)
        set -l buf_after_cursor (string sub --start=$cursor -- $buf)
        if string match --regex --quiet '^\s*$' -- $buf_after_cursor
            # There is no text after the cursor so it is safe to append the pipe "&| bathelp"
            echo "--help &| bathelp"
        else
            echo --help
        end
    end

    abbr -a bathelp --regex '(-h|--help)' --position anywhere --function __helpme_bathelp_abbr
end


# TODO: overload the `help` function distributed with fish
