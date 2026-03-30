complete -c "detox" -s "h" -l "help" -d "this message" # global
complete -c "detox" -s "L" -d "list available sequences and exit with -v ... dump sequence contents" # global
complete -c "detox" -s "n" -l "dry-run" -d "do a dry run (don't actually do anything)" # global
complete -c "detox" -s "r" -l "recursive" -d "be recursive (descend into subdirectories)" # global
complete -c "detox" -s "v" -l "verbose" -d "be verbose" # global
complete -c "detox" -l "inline" -d "run inline mode" # global
complete -c "detox" -l "special" -d "work on links and special files" # global
complete -c "detox" -o "f" -d "choose which config file to use" # global
complete -c "detox" -o "s" -d "choose which sequence to detox with" # global
complete -c "detox" -s "V" -d "show the current version" # global