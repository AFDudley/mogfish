complete -c "rnr" -s "h" -l "help" -d "Print help" # global
complete -c "rnr" -s "V" -l "version" -d "Print version" # global
complete -f -c "rnr" -n "__fish_use_subcommand" -a "regex" -d "Rename files and directories using a regular expression" # sub
complete -f -c "rnr" -n "__fish_use_subcommand" -a "from-file" -d "Read operations from a dump file" # sub
complete -f -c "rnr" -n "__fish_use_subcommand" -a "to-ascii" -d "Replace file name UTF-8 chars with ASCII chars representation" # sub
complete -f -c "rnr" -n "__fish_use_subcommand" -a "help" -d "Print this message or the help of the given subcommand(s)" # sub
complete -c "rnr" -n "__fish_seen_subcommand_from 'regex'" -s "n" -l "dry-run" -d "Only show what would be done (default mode)" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'regex'" -s "f" -l "force" -d "Make actual changes to files" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'regex'" -s "b" -l "backup" -d "Generate file backups before renaming" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'regex'" -s "s" -l "silent" -d "Do not print any information" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'regex'" -l "color" -d "Set color output mode" -xa "always never auto" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'regex'" -l "dump" -d "Force dumping operations into a file even in dry-run mode" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'regex'" -l "dump-prefix" -d "Set the dump file prefix" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'regex'" -l "no-dump" -d "Do not dump operations into a file" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'regex'" -s "l" -l "replace-limit" -d "Limit of replacements, all matches if set to 0" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'regex'" -s "t" -l "replace-transform" -d "Apply a transformation to replacements including captured groups" -xa "upper lower ascii" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'regex'" -s "D" -l "include-dirs" -d "Rename matching directories" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'regex'" -s "r" -l "recursive" -d "Recursive mode" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'regex'" -s "d" -l "max-depth" -d "Set max depth in recursive mode" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'regex'" -s "x" -l "hidden" -d "Include hidden files and directories" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'regex'" -s "h" -l "help" -d "Print help" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'from-file'" -s "n" -l "dry-run" -d "Only show what would be done (default mode)" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'from-file'" -s "f" -l "force" -d "Make actual changes to files" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'from-file'" -s "b" -l "backup" -d "Generate file backups before renaming" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'from-file'" -s "s" -l "silent" -d "Do not print any information" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'from-file'" -l "color" -d "Set color output mode" -xa "always never auto" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'from-file'" -l "dump" -d "Force dumping operations into a file even in dry-run mode" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'from-file'" -l "dump-prefix" -d "Set the dump file prefix" -xa "{}" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'from-file'" -l "no-dump" -d "Do not dump operations into a file" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'from-file'" -s "u" -l "undo" -d "Undo the operations from the dump file" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'from-file'" -s "h" -l "help" -d "Print help" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'to-ascii'" -s "n" -l "dry-run" -d "Only show what would be done (default mode)" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'to-ascii'" -s "f" -l "force" -d "Make actual changes to files" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'to-ascii'" -s "b" -l "backup" -d "Generate file backups before renaming" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'to-ascii'" -s "s" -l "silent" -d "Do not print any information" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'to-ascii'" -l "color" -d "Set color output mode" -xa "always never auto" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'to-ascii'" -l "dump" -d "Force dumping operations into a file even in dry-run mode" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'to-ascii'" -l "dump-prefix" -d "Set the dump file prefix" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'to-ascii'" -l "no-dump" -d "Do not dump operations into a file" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'to-ascii'" -s "D" -l "include-dirs" -d "Rename matching directories" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'to-ascii'" -s "r" -l "recursive" -d "Recursive mode" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'to-ascii'" -s "d" -l "max-depth" -d "Set max depth in recursive mode" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'to-ascii'" -s "x" -l "hidden" -d "Include hidden files and directories" # global
complete -c "rnr" -n "__fish_seen_subcommand_from 'to-ascii'" -s "h" -l "help" -d "Print help" # global