

### git checkout aliases completion
complete -f -c gco -a '(__fish_git_branches)' --description 'branch'
complete -f -c gco -a '(__fish_git_tags)' --description 'tag'
complete -f -c gco -s b -d 'Create a new branch'
complete -f -c gco -s t -l track -d 'Track a new branch'

### git pull aliases completion
complete -f -c gpull -s q -l quiet -d 'Be quiet'
complete -f -c gpull -s v -l verbose -d 'Be verbose'
complete -f -c gpull -l all -d 'Fetch all remotes'
complete -f -c gpull -s a -l append -d 'Append ref names and object names'
complete -f -c gpull -s f -l force -d 'Force update of local branches'
complete -f -c gpull -s k -l keep -d 'Keep downloaded pack'
complete -f -c gpull -l no-tags -d 'Disable automatic tag following'
complete -f -c gpull -l progress -d 'Force progress status'
complete -f -c gpull -a '(git remote)' -d 'Remote alias'
complete -f -c gpull -a '(__fish_git_branches)' -d 'Branch'
