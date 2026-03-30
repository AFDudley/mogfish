complete -c "magika" -s "r" -l "recursive" -d "Identifies files within directories instead of identifying the directory itself" # global
complete -c "magika" -l "no-dereference" -d "Identifies symbolic links as is instead of identifying their content by following them" # global
complete -c "magika" -l "colors" -d "Prints with colors regardless of terminal support" # global
complete -c "magika" -l "no-colors" -d "Prints without colors regardless of terminal support" # global
complete -c "magika" -s "s" -l "output-score" -d "Prints the prediction score in addition to the content type" # global
complete -c "magika" -s "i" -l "mime-type" -d "Prints the MIME type instead of the content type description" # global
complete -c "magika" -s "l" -l "label" -d "Prints a simple label instead of the content type description" # global
complete -c "magika" -l "json" -d "Prints in JSON format" # global
complete -c "magika" -l "jsonl" -d "Prints in JSONL format" # global
complete -c "magika" -l "format" -d "Prints using a custom format (use --help for details)." # global
complete -c "magika" -s "h" -l "help" -d "Print help (see a summary with '-h')" # global
complete -c "magika" -s "V" -l "version" -d "Print version" # global