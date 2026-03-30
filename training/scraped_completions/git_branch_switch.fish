# Tab completion for git_branch_switch function

# Complete branch names from both local and remote branches
function __git_branch_switch_branches
    # Get local branches
    git branch --format='%(refname:short)' 2>/dev/null

    # Get remote branches (strip origin/ prefix)
    git branch -r --format='%(refname:short)' 2>/dev/null | string replace 'origin/' '' | string match -v 'HEAD*'
end

# Complete flags for both function and alias
complete -c git_branch_switch -s b -l new -d 'Force create new branch'

complete -c gbs -s b -l new -d 'Force create new branch'

# Complete branch names for both function and alias
complete -c git_branch_switch -f -a '(__git_branch_switch_branches)' -d 'Branch name'
complete -c gbs -f -a '(__git_branch_switch_branches)' -d 'Branch name'
