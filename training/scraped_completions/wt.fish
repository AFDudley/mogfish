# Completions for wt command

# Main command completions
complete -c wt -f -n "__fish_is_first_token" -a "goto g" -d "Move to worktree"
complete -c wt -f -n "__fish_is_first_token" -a "add a" -d "Create new worktree"
complete -c wt -f -n "__fish_is_first_token" -a "list l" -d "List worktrees"
complete -c wt -f -n "__fish_is_first_token" -a "remove rm" -d "Remove worktree"
complete -c wt -f -n "__fish_is_first_token" -a "root r" -d "Go to repository root"
complete -c wt -f -n "__fish_is_first_token" -a "fzf f" -d "Select worktree with fzf"

# Worktree name completions for goto and remove
function __fish_wt_worktrees
    # Get worktree names excluding the main worktree
    git worktree list 2>/dev/null | awk '{print $1}' | xargs -I {} basename {} | grep -v "^"(basename (git rev-parse --show-toplevel 2>/dev/null))"$"
end

complete -c wt -f -n "__fish_seen_subcommand_from goto g remove rm" -a "(__fish_wt_worktrees)"

# Direct command completions
complete -c wtg -f -a "(__fish_wt_worktrees)" -d "Worktree name"