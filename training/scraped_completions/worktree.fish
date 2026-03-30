set -g __worktree_commands clean create help init park switch reset

complete -c worktree --no-file
complete -c worktree --condition "not __fish_seen_subcommand_from $__worktree_commands" --arguments clean --description "Remove all non-dirty worktrees except main, review and work"
complete -c worktree --condition "not __fish_seen_subcommand_from $__worktree_commands" --arguments create --description "Create a new worktree"
complete -c worktree --condition "not __fish_seen_subcommand_from $__worktree_commands" --arguments help --description "Show help message"
complete -c worktree --condition "not __fish_seen_subcommand_from $__worktree_commands" --arguments init --description "Initialize worktree structure"
complete -c worktree --condition "not __fish_seen_subcommand_from $__worktree_commands" --arguments park --description "Resets to default branch on the special worktrees and updates them"
complete -c worktree --condition "not __fish_seen_subcommand_from $__worktree_commands" --arguments reset --description "Resets worktree structure"
complete -c worktree --condition "not __fish_seen_subcommand_from $__worktree_commands" --arguments switch --description "Switch between worktrees"
complete -c worktree --condition "__fish_seen_subcommand_from switch" --arguments "main review work"
