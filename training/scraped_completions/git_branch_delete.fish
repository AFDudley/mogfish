# Tab completion for git_branch_delete function

# Complete branch names from both local and remote branches
function __git_branch_delete_branches
    # Get local branches (excluding current branch)
    set -l current_branch (git branch --show-current 2>/dev/null)
    git branch --format='%(refname:short)' 2>/dev/null | while read -l branch
        if test "$branch" != "$current_branch"
            echo $branch
        end
    end

    # Get remote branches (strip origin/ prefix)
    git branch -r --format='%(refname:short)' 2>/dev/null | string replace 'origin/' '' | string match -v 'HEAD*'
end

# Complete flags for both function and alias
complete -c git_branch_delete -s r -l remote -d 'Delete remote branch only'
complete -c git_branch_delete -s a -l all -d 'Delete both local and remote branches'
complete -c git_branch_delete -s f -l force -d 'Force delete branch (even if not merged)'

complete -c gbd -s r -l remote -d 'Delete remote branch only'
complete -c gbd -s a -l all -d 'Delete both local and remote branches'
complete -c gbd -s f -l force -d 'Force delete branch (even if not merged)'

# Complete branch names for both function and alias
complete -c git_branch_delete -f -a '(__git_branch_delete_branches)' -d 'Branch name'
complete -c gbd -f -a '(__git_branch_delete_branches)' -d 'Branch name'
