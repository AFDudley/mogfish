# Fish completion for nerd-font-manager
# Install: Copy to ~/.config/fish/completions/ or add completions directory to fish_complete_path

complete -c nerd-font-manager -f
complete -c nerd-font-manager -s c -l cli -d 'Run in CLI mode with fzf (default)'
complete -c nerd-font-manager -s g -l gui -d 'Run in GUI mode with macOS dialogs'
complete -c nerd-font-manager -s v -l version -d 'Show version'
complete -c nerd-font-manager -s l -l list-installed -d 'List installed Nerd Fonts'
complete -c nerd-font-manager -s a -l list-available -d 'List available Nerd Fonts'
complete -c nerd-font-manager -s h -l help -d 'Show help message'

# Also complete for the .sh version
complete -c nerd-font-manager.sh -f
complete -c nerd-font-manager.sh -s c -l cli -d 'Run in CLI mode with fzf (default)'
complete -c nerd-font-manager.sh -s g -l gui -d 'Run in GUI mode with macOS dialogs'
complete -c nerd-font-manager.sh -s v -l version -d 'Show version'
complete -c nerd-font-manager.sh -s l -l list-installed -d 'List installed Nerd Fonts'
complete -c nerd-font-manager.sh -s a -l list-available -d 'List available Nerd Fonts'
complete -c nerd-font-manager.sh -s h -l help -d 'Show help message'
