complete -c "extract_msg" -s "h" -l "help" -d "show this help message and exit" # global
complete -c "extract_msg" -o "cid" -d "Save attachments by their Content ID, if they have one. Useful when working with the HTML body." # global
complete -c "extract_msg" -l "json" -d "Changes to write output files as json." # global
complete -c "extract_msg" -l "file-logging" -d "Enables file logging. Implies --verbose level 1." # global
complete -c "extract_msg" -s "v" -l "verbose" -d "Turns on console logging. Specify more than once for higher verbosity." # global
complete -c "extract_msg" -l "log" -d "Set the path to write the file log to." # global
complete -c "extract_msg" -l "config" -d "Set the path to load the logging config from." # global
complete -c "extract_msg" -l "out" -d "Set the folder to use for the program output. (Default: Current directory)" # global
complete -c "extract_msg" -l "use-filename" -d "Sets whether the name of each output is based on the MSG filename." # global
complete -c "extract_msg" -l "dump-stdout" -d "Tells the program to dump the message body (plain text) to stdout. Overrides saving arguments." # global
complete -c "extract_msg" -l "html" -d "Sets whether the output should be HTML. If this is not possible, will error." # global
complete -c "extract_msg" -l "pdf" -d "Saves the body as a PDF. If this is not possible, will error." # global
complete -c "extract_msg" -l "wk-path" -d "Overrides the path for finding wkhtmltopdf." # global
complete -c "extract_msg" -l "wk-options" -d "Sets additional options to be used in wkhtmltopdf. Should be a series of options and values, replacing the - or -- in the beginning with + or ++, respectively. For example: --wk-options \"+O Landscape\"" # global
complete -c "extract_msg" -l "prepared-html" -d "When used in conjunction with --html, sets whether the HTML output should be prepared for embedded attachments." # global
complete -c "extract_msg" -l "charset" -d "Character set to use for the prepared HTML in the added tag. (Default: utf-8)" # global
complete -c "extract_msg" -l "raw" -d "Sets whether the output should be raw. If this is not possible, will error." # global
complete -c "extract_msg" -l "rtf" -d "Sets whether the output should be RTF. If this is not possible, will error." # global
complete -c "extract_msg" -l "allow-fallback" -d "Tells the program to fallback to a different save type if the selected one is not possible." # global
complete -c "extract_msg" -l "skip-body-not-found" -d "Skips saving the body if the body cannot be found, rather than throwing an error." # global
complete -c "extract_msg" -l "zip" -d "Path to use for saving to a zip file." # global
complete -c "extract_msg" -l "save-header" -d "Store the header in a separate file." # global
complete -c "extract_msg" -l "attachments-only" -d "Specify to only save attachments from an MSG file." # global
complete -c "extract_msg" -l "skip-hidden" -d "Skips any attachment marked as hidden (usually ones embedded in the body)." # global
complete -c "extract_msg" -l "no-folders" -d "Stores everything in the location specified by --out. Requires --attachments-only and is incompatible with --out-name." # global
complete -c "extract_msg" -l "skip-embedded" -d "Skips all embedded MSG files when saving attachments." # global
complete -c "extract_msg" -l "extract-embedded" -d "Extracts the embedded MSG files as MSG files instead of running their save functions." # global
complete -c "extract_msg" -l "overwrite-existing" -d "Disables filename conflict resolution code for attachments when saving a file, causing files to be overwriten if two attachments with the same filename are on an MSG file." # global
complete -c "extract_msg" -o "skip-ni" -d "Skips any attachments that are not implemented, allowing saving of the rest of the message." # global
complete -c "extract_msg" -l "out-name" -d "Name to be used with saving the file output. Cannot be used if you are saving more than one file." # global
complete -c "extract_msg" -o "wildcard" -d "Interpret all paths as having wildcards. Incompatible with --out-name." # global
complete -c "extract_msg" -l "ignore-rtfde" -d "Ignores all errors thrown from RTFDE when trying to save. Useful for allowing fallback to continue when an exception happens." # global
complete -c "extract_msg" -l "progress" -d "Shows what file the program is currently working on during it's progress." # global
complete -c "extract_msg" -s "s" -l "stdin" -d "Read file from stdin (only works with one file at a time)." # global