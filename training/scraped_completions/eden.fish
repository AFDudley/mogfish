# Fish completion for eden

complete -c eden -f

# Global flags
complete -c eden -l force -s f -d "Bypass Syncthing sync safety check"

# add command
complete -c eden -n "__fish_use_subcommand" -a add -d "Add a new journal entry"
complete -c eden -n "__fish_seen_subcommand_from add" -l url -s u -d "URL associated with entry"
complete -c eden -n "__fish_seen_subcommand_from add" -l tag -s t -d "Tags for entry"
complete -c eden -n "__fish_seen_subcommand_from add" -l journal -s j -d "Journal name"
complete -c eden -n "__fish_seen_subcommand_from add" -l encrypt -s e -d "Encrypt entry with GPG"

# search command
complete -c eden -n "__fish_use_subcommand" -a search -d "Search journal entries"
complete -c eden -n "__fish_seen_subcommand_from search" -l journal -s j -d "Filter by journal name"
complete -c eden -n "__fish_seen_subcommand_from search" -l since -s s -d "Start date (YYYY-MM-DD)"
complete -c eden -n "__fish_seen_subcommand_from search" -l until -s u -d "End date (YYYY-MM-DD)"
complete -c eden -n "__fish_seen_subcommand_from search" -l interactive -d "Interactive mode for opening URLs"
complete -c eden -n "__fish_seen_subcommand_from search" -l format -s f -x -a "tabular compact minimal" -d "Output format"
complete -c eden -n "__fish_seen_subcommand_from search" -l export -s e -d "Export results in markdown/text format"
complete -c eden -n "__fish_seen_subcommand_from search" -l output -s o -d "Export results to file"
complete -c eden -n "__fish_seen_subcommand_from search" -l export-format -x -a "markdown text" -d "Export format"
complete -c eden -n "__fish_seen_subcommand_from search" -l notruncate -s n -d "Show full content without truncation"

# list command
complete -c eden -n "__fish_use_subcommand" -a list -d "List journal entries"
complete -c eden -n "__fish_seen_subcommand_from list" -l journal -s j -d "Filter by journal name"
complete -c eden -n "__fish_seen_subcommand_from list" -l all -s a -d "Show entries from all journals"
complete -c eden -n "__fish_seen_subcommand_from list" -l limit -s l -d "Limit number of entries"
complete -c eden -n "__fish_seen_subcommand_from list" -l since -s s -d "Start date (YYYY-MM-DD)"
complete -c eden -n "__fish_seen_subcommand_from list" -l until -s u -d "End date (YYYY-MM-DD)"
complete -c eden -n "__fish_seen_subcommand_from list" -l format -s f -x -a "tabular compact minimal" -d "Output format"
complete -c eden -n "__fish_seen_subcommand_from list" -l notruncate -s n -d "Show full content without truncation"

# tag command
complete -c eden -n "__fish_use_subcommand" -a tag -d "Tag operations"

# tag list
complete -c eden -n "__fish_seen_subcommand_from tag; and not __fish_seen_subcommand_from tag list show add delete" -a list -d "List all tags"

# tag show
complete -c eden -n "__fish_seen_subcommand_from tag; and not __fish_seen_subcommand_from tag list show add delete" -a show -d "Show entries for a tag"
complete -c eden -n "__fish_seen_subcommand_from tag show" -l format -s f -x -a "tabular compact minimal" -d "Output format"
complete -c eden -n "__fish_seen_subcommand_from tag show" -l export -s e -d "Export results in markdown/text format"
complete -c eden -n "__fish_seen_subcommand_from tag show" -l output -s o -d "Export results to file"
complete -c eden -n "__fish_seen_subcommand_from tag show" -l export-format -x -a "markdown text" -d "Export format"
complete -c eden -n "__fish_seen_subcommand_from tag show" -l notruncate -s n -d "Show full content without truncation"

# tag add
complete -c eden -n "__fish_seen_subcommand_from tag; and not __fish_seen_subcommand_from tag list show add delete" -a add -d "Add tags to an entry"
complete -c eden -n "__fish_seen_subcommand_from tag add" -l tag -s t -d "Tags to add"

# tag delete
complete -c eden -n "__fish_seen_subcommand_from tag; and not __fish_seen_subcommand_from tag list show add delete" -a delete -d "Delete tags from an entry"
complete -c eden -n "__fish_seen_subcommand_from tag delete" -l all -d "Remove all tags from the entry"

# open command
complete -c eden -n "__fish_use_subcommand" -a open -d "Open an entry's URL in browser"

# show command
complete -c eden -n "__fish_use_subcommand" -a show -d "Show a full journal entry"

# delete command
complete -c eden -n "__fish_use_subcommand" -a delete -d "Delete a journal entry"

# edit command
complete -c eden -n "__fish_use_subcommand" -a edit -d "Edit a journal entry in your editor"

# export command
complete -c eden -n "__fish_use_subcommand" -a export -d "Export entries by journal, search query, or date range"
complete -c eden -n "__fish_seen_subcommand_from export" -l format -s f -x -a "markdown text" -d "Export format"
complete -c eden -n "__fish_seen_subcommand_from export" -l output -s o -d "Output file path"
complete -c eden -n "__fish_seen_subcommand_from export" -l journal -s j -d "Filter by journal name"
complete -c eden -n "__fish_seen_subcommand_from export" -l start -s s -d "Start date for date range export (YYYY, YYYY-MM, or YYYY-MM-DD)"
complete -c eden -n "__fish_seen_subcommand_from export" -l end -s e -d "End date for date range export (YYYY, YYYY-MM, or YYYY-MM-DD)"

# journal command
complete -c eden -n "__fish_use_subcommand; and not __fish_seen_subcommand_from add search list tag open show delete edit export journal status" -a journal -d "Journal operations"

# journal list
complete -c eden -n "__fish_seen_subcommand_from journal; and not __fish_seen_subcommand_from journal list create set-default delete export import rename" -a list -d "List all journals"

# journal create
complete -c eden -n "__fish_seen_subcommand_from journal; and not __fish_seen_subcommand_from journal list create set-default delete export import rename" -a create -d "Create a new journal"

# journal set-default
complete -c eden -n "__fish_seen_subcommand_from journal; and not __fish_seen_subcommand_from journal list create set-default delete export import rename" -a set-default -d "Set default journal"

# journal delete
complete -c eden -n "__fish_seen_subcommand_from journal; and not __fish_seen_subcommand_from journal list create set-default delete export import rename" -a delete -d "Delete a journal and all its entries"
complete -c eden -n "__fish_seen_subcommand_from journal delete" -l confirm -d "Confirm deletion without prompting"
complete -c eden -n "__fish_seen_subcommand_from journal delete" -l dry-run -d "Show what would be deleted without doing it"

# journal export
complete -c eden -n "__fish_seen_subcommand_from journal; and not __fish_seen_subcommand_from journal list create set-default delete export import rename" -a export -d "Export a journal to a tgz archive"
complete -c eden -n "__fish_seen_subcommand_from journal export" -l output -s o -d "Output file path (default: NAME-YYYY-MM-DD.tgz)"
complete -c eden -n "__fish_seen_subcommand_from journal export" -l encrypt -s e -d "Encrypt the archive with GPG"
complete -c eden -n "__fish_seen_subcommand_from journal export" -l passphrase -s p -d "Passphrase for encryption"
complete -c eden -n "__fish_seen_subcommand_from journal export" -l keep-db -d "Keep journal in database after export"
complete -c eden -n "__fish_seen_subcommand_from journal export" -l dry-run -d "Show export plan without executing"

# journal import
complete -c eden -n "__fish_seen_subcommand_from journal; and not __fish_seen_subcommand_from journal list create set-default delete export import rename" -a import -d "Import a journal from a tgz archive"
complete -c eden -n "__fish_seen_subcommand_from journal import" -l journal -s j -d "Journal name to create (default: from archive)"
complete -c eden -n "__fish_seen_subcommand_from journal import" -l passphrase -s p -d "Passphrase for decryption (if encrypted)"
complete -c eden -n "__fish_seen_subcommand_from journal import" -l dry-run -d "Show import plan without executing"

# journal rename
complete -c eden -n "__fish_seen_subcommand_from journal; and not __fish_seen_subcommand_from journal list create set-default delete export import rename" -a rename -d "Rename a journal"

# status command
complete -c eden -n "__fish_use_subcommand" -a status -d "Show application status"
