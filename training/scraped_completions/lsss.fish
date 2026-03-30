complete -c lsss -f
complete -c lsss -n "__fish_is_first_arg" -xa "(__fish_complete_directories)"
complete -c lsss -n "not __fish_is_first_arg; and not string match -r -- '^-' (commandline -ct)" \
       -xa "-a 5 10 20 50 100"
