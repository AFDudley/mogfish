complete -c note -x -d 'note'     -a '(sh -c "cd $NOTE_ROOT_DIR; find . -regextype posix-extended -not -path \'*/\.*\' -type f -iregex \'$NOTE_COMPLETION_REGEX\' | cut -c 3-")'
complete -c note -x -d 'note-dir' -a '(sh -c "cd $NOTE_ROOT_DIR; find . -maxdepth 1               -not -path \'*/\.*\' -type d                                    | cut -c 3-")'
