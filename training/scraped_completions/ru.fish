# Fish completion for ru (Repo Updater)
# Generated for homebrew-tap distribution

# Disable file completion by default
complete -c ru -f

# Commands
complete -c ru -n __fish_use_subcommand -a sync -d 'Clone missing repos and pull updates'
complete -c ru -n __fish_use_subcommand -a status -d 'Show repository status'
complete -c ru -n __fish_use_subcommand -a init -d 'Initialize configuration'
complete -c ru -n __fish_use_subcommand -a add -d 'Add a repository'
complete -c ru -n __fish_use_subcommand -a remove -d 'Remove a repository'
complete -c ru -n __fish_use_subcommand -a list -d 'Show configured repositories'
complete -c ru -n __fish_use_subcommand -a doctor -d 'Run system diagnostics'
complete -c ru -n __fish_use_subcommand -a self-update -d 'Update ru'
complete -c ru -n __fish_use_subcommand -a config -d 'Show or set configuration'
complete -c ru -n __fish_use_subcommand -a prune -d 'Manage orphan repositories'
complete -c ru -n __fish_use_subcommand -a import -d 'Import repos from file'
complete -c ru -n __fish_use_subcommand -a review -d 'Review GitHub issues and PRs'

# Global options
complete -c ru -s h -l help -d 'Show help message'
complete -c ru -s v -l version -d 'Show version'
complete -c ru -l json -d 'Output JSON to stdout'
complete -c ru -s q -l quiet -d 'Minimal output'
complete -c ru -l verbose -d 'Detailed output'
complete -c ru -l non-interactive -d 'Never prompt'

# sync options
complete -c ru -n '__fish_seen_subcommand_from sync' -l clone-only -d 'Only clone missing repos'
complete -c ru -n '__fish_seen_subcommand_from sync' -l pull-only -d 'Only pull existing repos'
complete -c ru -n '__fish_seen_subcommand_from sync' -l autostash -d 'Stash changes before pull'
complete -c ru -n '__fish_seen_subcommand_from sync' -l rebase -d 'Use git pull --rebase'
complete -c ru -n '__fish_seen_subcommand_from sync' -l dry-run -d 'Show what would happen'
complete -c ru -n '__fish_seen_subcommand_from sync' -l dir -r -d 'Override projects directory'
complete -c ru -n '__fish_seen_subcommand_from sync' -s j -l parallel -r -d 'Sync N repos concurrently'
complete -c ru -n '__fish_seen_subcommand_from sync' -l resume -d 'Resume interrupted sync'
complete -c ru -n '__fish_seen_subcommand_from sync' -l restart -d 'Start fresh'
complete -c ru -n '__fish_seen_subcommand_from sync' -l timeout -r -d 'Network timeout'

# status options
complete -c ru -n '__fish_seen_subcommand_from status' -l fetch -d 'Fetch remotes first'
complete -c ru -n '__fish_seen_subcommand_from status' -l no-fetch -d 'Skip fetch'

# init options
complete -c ru -n '__fish_seen_subcommand_from init' -l example -d 'Include example repos'

# add options
complete -c ru -n '__fish_seen_subcommand_from add' -l private -d 'Add to private.txt'

# import - complete with files
complete -c ru -n '__fish_seen_subcommand_from import' -F

# review options
complete -c ru -n '__fish_seen_subcommand_from review' -l plan -d 'Generate review plans'
complete -c ru -n '__fish_seen_subcommand_from review' -l apply -d 'Execute approved plans'
complete -c ru -n '__fish_seen_subcommand_from review' -l dry-run -d 'Show what would happen'
complete -c ru -n '__fish_seen_subcommand_from review' -l mode -r -a 'local ntm' -d 'Review mode'
complete -c ru -n '__fish_seen_subcommand_from review' -l max-repos -r -d 'Limit repos'
complete -c ru -n '__fish_seen_subcommand_from review' -l repos -r -d 'Filter pattern'
complete -c ru -n '__fish_seen_subcommand_from review' -l skip-days -r -d 'Skip recently reviewed'
complete -c ru -n '__fish_seen_subcommand_from review' -l parallel -r -d 'Concurrent sessions'
complete -c ru -n '__fish_seen_subcommand_from review' -l push -d 'Allow pushing'
