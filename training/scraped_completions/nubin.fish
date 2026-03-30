# Disable file completions by default
complete -c nubin -f

# Top-level commands
complete -c nubin -n __fish_use_subcommand -a build -d 'Bundle scripts into a self-contained binary'
complete -c nubin -n __fish_use_subcommand -a install -d 'Build and install to ~/.local/bin (or --dir)'
complete -c nubin -n __fish_use_subcommand -a extract -d 'Extract and inspect a nubin binary\'s bundle'
complete -c nubin -n __fish_use_subcommand -a info -d 'Show metadata of a nubin binary'
complete -c nubin -n __fish_use_subcommand -a completions -d 'Generate shell completions'
complete -c nubin -n __fish_use_subcommand -s h -l help -d 'Show help'
complete -c nubin -n __fish_use_subcommand -s V -l version -d 'Show version'

# targets
set -l __nubin_targets x86_64-unknown-linux-gnu aarch64-unknown-linux-gnu x86_64-apple-darwin aarch64-apple-darwin x86_64-pc-windows-msvc

# build
complete -c nubin -n '__fish_seen_subcommand_from build' -s o -l output -r -F -d 'Output binary path'
complete -c nubin -n '__fish_seen_subcommand_from build' -s t -l target -r -a "$__nubin_targets" -d 'Target platform target'
complete -c nubin -n '__fish_seen_subcommand_from build' -l stub -r -F -d 'Path to a pre-built nubin stub binary'
complete -c nubin -n '__fish_seen_subcommand_from build' -s h -l help -d 'Show help'

# install
complete -c nubin -n '__fish_seen_subcommand_from install' -s d -l dir -r -F -d 'Install directory'
complete -c nubin -n '__fish_seen_subcommand_from install' -s t -l target -r -a "$__nubin_targets" -d 'Target platform target'
complete -c nubin -n '__fish_seen_subcommand_from install' -l stub -r -F -d 'Path to a pre-built nubin stub binary'
complete -c nubin -n '__fish_seen_subcommand_from install' -s h -l help -d 'Show help'

# extract
complete -c nubin -n '__fish_seen_subcommand_from extract' -s o -l output -r -F -d 'Extraction directory'
complete -c nubin -n '__fish_seen_subcommand_from extract' -l no-download -d 'Skip nushell download'
complete -c nubin -n '__fish_seen_subcommand_from extract' -s h -l help -d 'Show help'
complete -c nubin -n '__fish_seen_subcommand_from extract' -F

# info
complete -c nubin -n '__fish_seen_subcommand_from info' -s h -l help -d 'Show help'
complete -c nubin -n '__fish_seen_subcommand_from info' -F

# completions
complete -c nubin -n '__fish_seen_subcommand_from completions' -a 'bash zsh fish nushell' -d 'Shell name'
complete -c nubin -n '__fish_seen_subcommand_from completions' -s h -l help -d 'Show help'
