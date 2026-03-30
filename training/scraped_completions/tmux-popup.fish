# For ~/bin/tmux-popup
function __complete_terminal_x_position
    printf '%s\t%s\n' '1' 'Left'
    printf '%s\t%s\n' 'C' 'Center of the terminal'
    printf '%s\t%s\n' 'R' 'Right side of the terminal'
    printf '%s\t%s\n' 'P' 'Left of the pane'
    printf '%s\t%s\n' 'M' 'The mouse position'
    printf '%s\t%s\n' 'W' 'The window position on the status line'
end
function __complete_terminal_y_position
    printf '%s\t%s\n' '1' 'Top'
    printf '%s\t%s\n' 'C' 'Center of the terminal'
    printf '%s\t%s\n' 'P' 'Bottom of the pane'
    printf '%s\t%s\n' 'M' 'The mouse position'
    printf '%s\t%s\n' 'S' 'The line adobe or below the stauts line'
end
complete -c tmux-popup -s w -d 'Terminal Width'  -xa '50% 60% 70% 80% 90%'
complete -c tmux-popup -s h -d 'Terminal Height' -xa '50% 60% 70% 80% 90%'
complete -c tmux-popup -s x -d 'Terminal X Position (column number or special value)' -xa '(__complete_terminal_x_position)'
complete -c tmux-popup -s y -d 'Terminal Y Position (row number or special value)' -xa '(__complete_terminal_y_position)'
complete -c tmux-popup -s s -l session -d 'tmux session name' -xa 'popup'

