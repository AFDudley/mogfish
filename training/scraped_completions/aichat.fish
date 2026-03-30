#!/usr/bin/env fish
# Fish completion script for Helix editor

set -l models (aichat --list-models|awk -F: { print \$2 })
set -m roles (aichat --list-roles|awk -F: { print \$2 })
set -m roles (aichat --list-roles|awk -F: { print \$2 })

complete -c aichat --no-files
complete -c aichat -s m -l model -x -a '(aichat --list-models)'
complete -c aichat -s r -l role -x -a '(aichat --list-roles)'
complete -c aichat -s s -l session -x -a '(aichat --list-sessions)'
complete -c aichat -s e -l execute -d 'Execute commands using natural language'
complete -c aichat --force-files -s f -l file -d 'Attach files to the message to be sent' -r
complete -c aichat -s c -l code -d 'Generate only code'
complete -c aichat -s H -l no-highlight -d 'Disable syntax highlighting'
complete -c aichat -s S -l no-stream -d 'No stream output'
complete -c aichat -s w -l wrap -d 'Specify the text-wrapping mode (no, auto, <max-width>)'
complete -c aichat -l light-theme -d 'Use light theme'
complete -c aichat -l dry-run -d 'Run in dry run mode'
complete -c aichat -l info -d 'Print related information'
complete -c aichat -l list-models -d 'List all available models'
complete -c aichat -l list-roles -d 'List all available roles'
complete -c aichat -l list-sessions -d 'List all available sessions'
complete -c aichat -s h -l help -d 'Print help'
