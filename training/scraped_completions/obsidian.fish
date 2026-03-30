# Fish completions for Obsidian CLI (https://obsidian.md/help/cli)
# Requires Obsidian 1.12+

# Disable file completions by default
complete -c obsidian -f

# Helper: check if a subcommand is already given
function __obsidian_no_subcommand
    set -l cmd (commandline -opc)
    for c in $cmd[2..]
        switch $c
            case 'vault=*' --copy
                continue
            case '*'
                return 1
        end
    end
    return 0
end

function __obsidian_using_subcommand
    set -l cmd (commandline -opc)
    for c in $cmd[2..]
        switch $c
            case 'vault=*' --copy
                continue
            case $argv[1]
                return 0
        end
    end
    return 1
end

# Global options
complete -c obsidian -l copy -d 'Copy output to clipboard'

# ── Subcommands ──

# aliases
complete -c obsidian -n __obsidian_no_subcommand -a aliases -d 'List aliases in the vault'
complete -c obsidian -n '__obsidian_using_subcommand aliases' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand aliases' -a 'path=' -d 'File path'
complete -c obsidian -n '__obsidian_using_subcommand aliases' -a total -d 'Return alias count'
complete -c obsidian -n '__obsidian_using_subcommand aliases' -a verbose -d 'Include file paths'
complete -c obsidian -n '__obsidian_using_subcommand aliases' -a active -d 'Show aliases for active file'

# append
complete -c obsidian -n __obsidian_no_subcommand -a append -d 'Append content to a file'
complete -c obsidian -n '__obsidian_using_subcommand append' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand append' -a 'path=' -d 'File path'
complete -c obsidian -n '__obsidian_using_subcommand append' -a 'content=' -d 'Content to append (required)'
complete -c obsidian -n '__obsidian_using_subcommand append' -a inline -d 'Append without newline'

# backlinks
complete -c obsidian -n __obsidian_no_subcommand -a backlinks -d 'List backlinks to a file'
complete -c obsidian -n '__obsidian_using_subcommand backlinks' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand backlinks' -a 'path=' -d 'File path'
complete -c obsidian -n '__obsidian_using_subcommand backlinks' -a counts -d 'Include link counts'
complete -c obsidian -n '__obsidian_using_subcommand backlinks' -a total -d 'Return backlink count'
complete -c obsidian -n '__obsidian_using_subcommand backlinks' -a 'format=json' -d 'JSON format'
complete -c obsidian -n '__obsidian_using_subcommand backlinks' -a 'format=tsv' -d 'TSV format'
complete -c obsidian -n '__obsidian_using_subcommand backlinks' -a 'format=csv' -d 'CSV format'

# base:create
complete -c obsidian -n __obsidian_no_subcommand -a 'base:create' -d 'Create new item in a base'
complete -c obsidian -n '__obsidian_using_subcommand base:create' -a 'file=' -d 'Base file name'
complete -c obsidian -n '__obsidian_using_subcommand base:create' -a 'path=' -d 'Base file path'
complete -c obsidian -n '__obsidian_using_subcommand base:create' -a 'view=' -d 'View name'
complete -c obsidian -n '__obsidian_using_subcommand base:create' -a 'name=' -d 'New file name'
complete -c obsidian -n '__obsidian_using_subcommand base:create' -a 'content=' -d 'Initial content'
complete -c obsidian -n '__obsidian_using_subcommand base:create' -a open -d 'Open file after creating'
complete -c obsidian -n '__obsidian_using_subcommand base:create' -a newtab -d 'Open in new tab'

# base:query
complete -c obsidian -n __obsidian_no_subcommand -a 'base:query' -d 'Query a base'
complete -c obsidian -n '__obsidian_using_subcommand base:query' -a 'file=' -d 'Base file name'
complete -c obsidian -n '__obsidian_using_subcommand base:query' -a 'path=' -d 'Base file path'
complete -c obsidian -n '__obsidian_using_subcommand base:query' -a 'view=' -d 'View name'
complete -c obsidian -n '__obsidian_using_subcommand base:query' -a 'format=json' -d JSON
complete -c obsidian -n '__obsidian_using_subcommand base:query' -a 'format=csv' -d CSV
complete -c obsidian -n '__obsidian_using_subcommand base:query' -a 'format=tsv' -d TSV
complete -c obsidian -n '__obsidian_using_subcommand base:query' -a 'format=md' -d Markdown
complete -c obsidian -n '__obsidian_using_subcommand base:query' -a 'format=paths' -d 'File paths'

# base:views / bases
complete -c obsidian -n __obsidian_no_subcommand -a 'base:views' -d 'List views in current base'
complete -c obsidian -n __obsidian_no_subcommand -a bases -d 'List all base files'

# bookmark
complete -c obsidian -n __obsidian_no_subcommand -a bookmark -d 'Add a bookmark'
complete -c obsidian -n '__obsidian_using_subcommand bookmark' -a 'file=' -d 'File to bookmark'
complete -c obsidian -n '__obsidian_using_subcommand bookmark' -a 'subpath=' -d 'Subpath within file'
complete -c obsidian -n '__obsidian_using_subcommand bookmark' -a 'folder=' -d 'Folder to bookmark'
complete -c obsidian -n '__obsidian_using_subcommand bookmark' -a 'search=' -d 'Search query to bookmark'
complete -c obsidian -n '__obsidian_using_subcommand bookmark' -a 'url=' -d 'URL to bookmark'
complete -c obsidian -n '__obsidian_using_subcommand bookmark' -a 'title=' -d 'Bookmark title'

# bookmarks
complete -c obsidian -n __obsidian_no_subcommand -a bookmarks -d 'List bookmarks'
complete -c obsidian -n '__obsidian_using_subcommand bookmarks' -a total -d 'Return bookmark count'
complete -c obsidian -n '__obsidian_using_subcommand bookmarks' -a verbose -d 'Include bookmark types'
complete -c obsidian -n '__obsidian_using_subcommand bookmarks' -a 'format=json' -d JSON
complete -c obsidian -n '__obsidian_using_subcommand bookmarks' -a 'format=tsv' -d TSV
complete -c obsidian -n '__obsidian_using_subcommand bookmarks' -a 'format=csv' -d CSV

# command / commands
complete -c obsidian -n __obsidian_no_subcommand -a command -d 'Execute an Obsidian command'
complete -c obsidian -n '__obsidian_using_subcommand command' -a 'id=' -d 'Command ID (required)'
complete -c obsidian -n __obsidian_no_subcommand -a commands -d 'List available commands'
complete -c obsidian -n '__obsidian_using_subcommand commands' -a 'filter=' -d 'Filter by ID prefix'

# create
complete -c obsidian -n __obsidian_no_subcommand -a create -d 'Create a new file'
complete -c obsidian -n '__obsidian_using_subcommand create' -a 'name=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand create' -a 'path=' -d 'File path'
complete -c obsidian -n '__obsidian_using_subcommand create' -a 'content=' -d 'Initial content'
complete -c obsidian -n '__obsidian_using_subcommand create' -a 'template=' -d 'Template to use'
complete -c obsidian -n '__obsidian_using_subcommand create' -a overwrite -d 'Overwrite if exists'
complete -c obsidian -n '__obsidian_using_subcommand create' -a open -d 'Open after creating'
complete -c obsidian -n '__obsidian_using_subcommand create' -a newtab -d 'Open in new tab'

# daily
complete -c obsidian -n __obsidian_no_subcommand -a daily -d 'Open daily note'
complete -c obsidian -n '__obsidian_using_subcommand daily' -a 'paneType=tab' -d 'Open in tab'
complete -c obsidian -n '__obsidian_using_subcommand daily' -a 'paneType=split' -d 'Open in split'
complete -c obsidian -n '__obsidian_using_subcommand daily' -a 'paneType=window' -d 'Open in window'

# daily:append
complete -c obsidian -n __obsidian_no_subcommand -a 'daily:append' -d 'Append to daily note'
complete -c obsidian -n '__obsidian_using_subcommand daily:append' -a 'content=' -d 'Content (required)'
complete -c obsidian -n '__obsidian_using_subcommand daily:append' -a inline -d 'Without newline'
complete -c obsidian -n '__obsidian_using_subcommand daily:append' -a open -d 'Open after'
complete -c obsidian -n '__obsidian_using_subcommand daily:append' -a 'paneType=tab' -d Tab
complete -c obsidian -n '__obsidian_using_subcommand daily:append' -a 'paneType=split' -d Split
complete -c obsidian -n '__obsidian_using_subcommand daily:append' -a 'paneType=window' -d Window

# daily:path / daily:prepend / daily:read
complete -c obsidian -n __obsidian_no_subcommand -a 'daily:path' -d 'Get daily note path'
complete -c obsidian -n __obsidian_no_subcommand -a 'daily:prepend' -d 'Prepend to daily note'
complete -c obsidian -n '__obsidian_using_subcommand daily:prepend' -a 'content=' -d 'Content (required)'
complete -c obsidian -n '__obsidian_using_subcommand daily:prepend' -a inline -d 'Without newline'
complete -c obsidian -n '__obsidian_using_subcommand daily:prepend' -a open -d 'Open after'
complete -c obsidian -n '__obsidian_using_subcommand daily:prepend' -a 'paneType=tab' -d Tab
complete -c obsidian -n '__obsidian_using_subcommand daily:prepend' -a 'paneType=split' -d Split
complete -c obsidian -n '__obsidian_using_subcommand daily:prepend' -a 'paneType=window' -d Window
complete -c obsidian -n __obsidian_no_subcommand -a 'daily:read' -d 'Read daily note'

# deadends
complete -c obsidian -n __obsidian_no_subcommand -a deadends -d 'Files with no outgoing links'
complete -c obsidian -n '__obsidian_using_subcommand deadends' -a total -d 'Return count'
complete -c obsidian -n '__obsidian_using_subcommand deadends' -a all -d 'Include non-markdown'

# delete
complete -c obsidian -n __obsidian_no_subcommand -a delete -d 'Delete a file'
complete -c obsidian -n '__obsidian_using_subcommand delete' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand delete' -a 'path=' -d 'File path'
complete -c obsidian -n '__obsidian_using_subcommand delete' -a permanent -d 'Skip trash'

# diff
complete -c obsidian -n __obsidian_no_subcommand -a diff -d 'List/diff versions'
complete -c obsidian -n '__obsidian_using_subcommand diff' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand diff' -a 'path=' -d 'File path'
complete -c obsidian -n '__obsidian_using_subcommand diff' -a 'from=' -d 'Version from'
complete -c obsidian -n '__obsidian_using_subcommand diff' -a 'to=' -d 'Version to'
complete -c obsidian -n '__obsidian_using_subcommand diff' -a 'filter=local' -d 'Local versions'
complete -c obsidian -n '__obsidian_using_subcommand diff' -a 'filter=sync' -d 'Sync versions'

# file / files
complete -c obsidian -n __obsidian_no_subcommand -a file -d 'Show file info'
complete -c obsidian -n '__obsidian_using_subcommand file' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand file' -a 'path=' -d 'File path'
complete -c obsidian -n __obsidian_no_subcommand -a files -d 'List files'
complete -c obsidian -n '__obsidian_using_subcommand files' -a 'folder=' -d 'Filter by folder'
complete -c obsidian -n '__obsidian_using_subcommand files' -a 'ext=' -d 'Filter by extension'
complete -c obsidian -n '__obsidian_using_subcommand files' -a total -d 'Return count'

# folder / folders
complete -c obsidian -n __obsidian_no_subcommand -a folder -d 'Show folder info'
complete -c obsidian -n '__obsidian_using_subcommand folder' -a 'path=' -d 'Folder path (required)'
complete -c obsidian -n '__obsidian_using_subcommand folder' -a 'info=files' -d 'File count'
complete -c obsidian -n '__obsidian_using_subcommand folder' -a 'info=folders' -d 'Folder count'
complete -c obsidian -n '__obsidian_using_subcommand folder' -a 'info=size' -d Size
complete -c obsidian -n __obsidian_no_subcommand -a folders -d 'List folders'
complete -c obsidian -n '__obsidian_using_subcommand folders' -a 'folder=' -d 'Parent folder'
complete -c obsidian -n '__obsidian_using_subcommand folders' -a total -d 'Return count'

# help
complete -c obsidian -n __obsidian_no_subcommand -a help -d 'Show help'

# history
complete -c obsidian -n __obsidian_no_subcommand -a history -d 'List file history'
complete -c obsidian -n '__obsidian_using_subcommand history' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand history' -a 'path=' -d 'File path'
complete -c obsidian -n __obsidian_no_subcommand -a 'history:list' -d 'List files with history'
complete -c obsidian -n __obsidian_no_subcommand -a 'history:open' -d 'Open file recovery'
complete -c obsidian -n '__obsidian_using_subcommand history:open' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand history:open' -a 'path=' -d 'File path'
complete -c obsidian -n __obsidian_no_subcommand -a 'history:read' -d 'Read history version'
complete -c obsidian -n '__obsidian_using_subcommand history:read' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand history:read' -a 'path=' -d 'File path'
complete -c obsidian -n '__obsidian_using_subcommand history:read' -a 'version=' -d 'Version number'
complete -c obsidian -n __obsidian_no_subcommand -a 'history:restore' -d 'Restore history version'
complete -c obsidian -n '__obsidian_using_subcommand history:restore' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand history:restore' -a 'path=' -d 'File path'
complete -c obsidian -n '__obsidian_using_subcommand history:restore' -a 'version=' -d 'Version (required)'

# hotkey / hotkeys
complete -c obsidian -n __obsidian_no_subcommand -a hotkey -d 'Get hotkey for command'
complete -c obsidian -n '__obsidian_using_subcommand hotkey' -a 'id=' -d 'Command ID (required)'
complete -c obsidian -n '__obsidian_using_subcommand hotkey' -a verbose -d 'Show custom/default'
complete -c obsidian -n __obsidian_no_subcommand -a hotkeys -d 'List hotkeys'
complete -c obsidian -n '__obsidian_using_subcommand hotkeys' -a total -d 'Return count'
complete -c obsidian -n '__obsidian_using_subcommand hotkeys' -a verbose -d 'Show custom/default'
complete -c obsidian -n '__obsidian_using_subcommand hotkeys' -a all -d 'Include unbound commands'
complete -c obsidian -n '__obsidian_using_subcommand hotkeys' -a 'format=json' -d JSON
complete -c obsidian -n '__obsidian_using_subcommand hotkeys' -a 'format=tsv' -d TSV
complete -c obsidian -n '__obsidian_using_subcommand hotkeys' -a 'format=csv' -d CSV

# links
complete -c obsidian -n __obsidian_no_subcommand -a links -d 'List outgoing links'
complete -c obsidian -n '__obsidian_using_subcommand links' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand links' -a 'path=' -d 'File path'
complete -c obsidian -n '__obsidian_using_subcommand links' -a total -d 'Return count'

# move
complete -c obsidian -n __obsidian_no_subcommand -a move -d 'Move/rename file'
complete -c obsidian -n '__obsidian_using_subcommand move' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand move' -a 'path=' -d 'File path'
complete -c obsidian -n '__obsidian_using_subcommand move' -a 'to=' -d 'Destination (required)'

# open
complete -c obsidian -n __obsidian_no_subcommand -a open -d 'Open a file'
complete -c obsidian -n '__obsidian_using_subcommand open' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand open' -a 'path=' -d 'File path'
complete -c obsidian -n '__obsidian_using_subcommand open' -a newtab -d 'Open in new tab'

# orphans
complete -c obsidian -n __obsidian_no_subcommand -a orphans -d 'Files with no incoming links'
complete -c obsidian -n '__obsidian_using_subcommand orphans' -a total -d 'Return count'
complete -c obsidian -n '__obsidian_using_subcommand orphans' -a all -d 'Include non-markdown'

# outline
complete -c obsidian -n __obsidian_no_subcommand -a outline -d 'Show headings'
complete -c obsidian -n '__obsidian_using_subcommand outline' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand outline' -a 'path=' -d 'File path'
complete -c obsidian -n '__obsidian_using_subcommand outline' -a 'format=tree' -d Tree
complete -c obsidian -n '__obsidian_using_subcommand outline' -a 'format=md' -d Markdown
complete -c obsidian -n '__obsidian_using_subcommand outline' -a 'format=json' -d JSON
complete -c obsidian -n '__obsidian_using_subcommand outline' -a total -d 'Return count'

# plugin
complete -c obsidian -n __obsidian_no_subcommand -a plugin -d 'Get plugin info'
complete -c obsidian -n '__obsidian_using_subcommand plugin' -a 'id=' -d 'Plugin ID (required)'
complete -c obsidian -n __obsidian_no_subcommand -a 'plugin:disable' -d 'Disable a plugin'
complete -c obsidian -n '__obsidian_using_subcommand plugin:disable' -a 'id=' -d 'Plugin ID (required)'
complete -c obsidian -n '__obsidian_using_subcommand plugin:disable' -a 'filter=core' -d 'Core plugins'
complete -c obsidian -n '__obsidian_using_subcommand plugin:disable' -a 'filter=community' -d Community
complete -c obsidian -n __obsidian_no_subcommand -a 'plugin:enable' -d 'Enable a plugin'
complete -c obsidian -n '__obsidian_using_subcommand plugin:enable' -a 'id=' -d 'Plugin ID (required)'
complete -c obsidian -n '__obsidian_using_subcommand plugin:enable' -a 'filter=core' -d 'Core plugins'
complete -c obsidian -n '__obsidian_using_subcommand plugin:enable' -a 'filter=community' -d Community
complete -c obsidian -n __obsidian_no_subcommand -a 'plugin:install' -d 'Install community plugin'
complete -c obsidian -n '__obsidian_using_subcommand plugin:install' -a 'id=' -d 'Plugin ID (required)'
complete -c obsidian -n '__obsidian_using_subcommand plugin:install' -a enable -d 'Enable after install'
complete -c obsidian -n __obsidian_no_subcommand -a 'plugin:reload' -d 'Reload plugin (dev)'
complete -c obsidian -n '__obsidian_using_subcommand plugin:reload' -a 'id=' -d 'Plugin ID (required)'
complete -c obsidian -n __obsidian_no_subcommand -a 'plugin:uninstall' -d 'Uninstall plugin'
complete -c obsidian -n '__obsidian_using_subcommand plugin:uninstall' -a 'id=' -d 'Plugin ID (required)'

# plugins
complete -c obsidian -n __obsidian_no_subcommand -a plugins -d 'List installed plugins'
complete -c obsidian -n '__obsidian_using_subcommand plugins' -a 'filter=core' -d 'Core plugins'
complete -c obsidian -n '__obsidian_using_subcommand plugins' -a 'filter=community' -d Community
complete -c obsidian -n '__obsidian_using_subcommand plugins' -a versions -d 'Include versions'
complete -c obsidian -n '__obsidian_using_subcommand plugins' -a 'format=json' -d JSON
complete -c obsidian -n '__obsidian_using_subcommand plugins' -a 'format=tsv' -d TSV
complete -c obsidian -n '__obsidian_using_subcommand plugins' -a 'format=csv' -d CSV
complete -c obsidian -n __obsidian_no_subcommand -a 'plugins:enabled' -d 'List enabled plugins'
complete -c obsidian -n '__obsidian_using_subcommand plugins:enabled' -a 'filter=core' -d Core
complete -c obsidian -n '__obsidian_using_subcommand plugins:enabled' -a 'filter=community' -d Community
complete -c obsidian -n '__obsidian_using_subcommand plugins:enabled' -a versions -d 'Include versions'
complete -c obsidian -n '__obsidian_using_subcommand plugins:enabled' -a 'format=json' -d JSON
complete -c obsidian -n '__obsidian_using_subcommand plugins:enabled' -a 'format=tsv' -d TSV
complete -c obsidian -n '__obsidian_using_subcommand plugins:enabled' -a 'format=csv' -d CSV
complete -c obsidian -n __obsidian_no_subcommand -a 'plugins:restrict' -d 'Toggle restricted mode'
complete -c obsidian -n '__obsidian_using_subcommand plugins:restrict' -a on -d Enable
complete -c obsidian -n '__obsidian_using_subcommand plugins:restrict' -a off -d Disable

# prepend
complete -c obsidian -n __obsidian_no_subcommand -a prepend -d 'Prepend content to file'
complete -c obsidian -n '__obsidian_using_subcommand prepend' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand prepend' -a 'path=' -d 'File path'
complete -c obsidian -n '__obsidian_using_subcommand prepend' -a 'content=' -d 'Content (required)'
complete -c obsidian -n '__obsidian_using_subcommand prepend' -a inline -d 'Without newline'

# properties
complete -c obsidian -n __obsidian_no_subcommand -a properties -d 'List properties'
complete -c obsidian -n '__obsidian_using_subcommand properties' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand properties' -a 'path=' -d 'File path'
complete -c obsidian -n '__obsidian_using_subcommand properties' -a 'name=' -d 'Property name'
complete -c obsidian -n '__obsidian_using_subcommand properties' -a total -d 'Return count'
complete -c obsidian -n '__obsidian_using_subcommand properties' -a 'sort=count' -d 'Sort by count'
complete -c obsidian -n '__obsidian_using_subcommand properties' -a counts -d 'Include counts'
complete -c obsidian -n '__obsidian_using_subcommand properties' -a active -d 'Active file'
complete -c obsidian -n '__obsidian_using_subcommand properties' -a 'format=yaml' -d YAML
complete -c obsidian -n '__obsidian_using_subcommand properties' -a 'format=json' -d JSON
complete -c obsidian -n '__obsidian_using_subcommand properties' -a 'format=tsv' -d TSV
complete -c obsidian -n __obsidian_no_subcommand -a 'property:read' -d 'Read property value'
complete -c obsidian -n '__obsidian_using_subcommand property:read' -a 'name=' -d 'Property (required)'
complete -c obsidian -n '__obsidian_using_subcommand property:read' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand property:read' -a 'path=' -d 'File path'
complete -c obsidian -n __obsidian_no_subcommand -a 'property:remove' -d 'Remove property'
complete -c obsidian -n '__obsidian_using_subcommand property:remove' -a 'name=' -d 'Property (required)'
complete -c obsidian -n '__obsidian_using_subcommand property:remove' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand property:remove' -a 'path=' -d 'File path'
complete -c obsidian -n __obsidian_no_subcommand -a 'property:set' -d 'Set property'
complete -c obsidian -n '__obsidian_using_subcommand property:set' -a 'name=' -d 'Property (required)'
complete -c obsidian -n '__obsidian_using_subcommand property:set' -a 'value=' -d 'Value (required)'
complete -c obsidian -n '__obsidian_using_subcommand property:set' -a 'type=text' -d Text
complete -c obsidian -n '__obsidian_using_subcommand property:set' -a 'type=list' -d List
complete -c obsidian -n '__obsidian_using_subcommand property:set' -a 'type=number' -d Number
complete -c obsidian -n '__obsidian_using_subcommand property:set' -a 'type=checkbox' -d Checkbox
complete -c obsidian -n '__obsidian_using_subcommand property:set' -a 'type=date' -d Date
complete -c obsidian -n '__obsidian_using_subcommand property:set' -a 'type=datetime' -d Datetime
complete -c obsidian -n '__obsidian_using_subcommand property:set' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand property:set' -a 'path=' -d 'File path'

# publish
complete -c obsidian -n __obsidian_no_subcommand -a 'publish:site' -d 'Show publish site info'
complete -c obsidian -n __obsidian_no_subcommand -a 'publish:list' -d 'List published files'
complete -c obsidian -n '__obsidian_using_subcommand publish:list' -a total -d 'Return count'
complete -c obsidian -n __obsidian_no_subcommand -a 'publish:status' -d 'List publish changes'
complete -c obsidian -n '__obsidian_using_subcommand publish:status' -a total -d Count
complete -c obsidian -n '__obsidian_using_subcommand publish:status' -a new -d 'New files'
complete -c obsidian -n '__obsidian_using_subcommand publish:status' -a changed -d Changed
complete -c obsidian -n '__obsidian_using_subcommand publish:status' -a deleted -d Deleted
complete -c obsidian -n __obsidian_no_subcommand -a 'publish:add' -d 'Publish file'
complete -c obsidian -n '__obsidian_using_subcommand publish:add' -a 'file=' -d File
complete -c obsidian -n '__obsidian_using_subcommand publish:add' -a 'path=' -d Path
complete -c obsidian -n '__obsidian_using_subcommand publish:add' -a changed -d 'Publish changed'
complete -c obsidian -n __obsidian_no_subcommand -a 'publish:remove' -d 'Unpublish file'
complete -c obsidian -n '__obsidian_using_subcommand publish:remove' -a 'file=' -d File
complete -c obsidian -n '__obsidian_using_subcommand publish:remove' -a 'path=' -d Path
complete -c obsidian -n __obsidian_no_subcommand -a 'publish:open' -d 'Open on published site'
complete -c obsidian -n '__obsidian_using_subcommand publish:open' -a 'file=' -d File
complete -c obsidian -n '__obsidian_using_subcommand publish:open' -a 'path=' -d Path

# random
complete -c obsidian -n __obsidian_no_subcommand -a random -d 'Open random note'
complete -c obsidian -n '__obsidian_using_subcommand random' -a 'folder=' -d 'Limit to folder'
complete -c obsidian -n '__obsidian_using_subcommand random' -a newtab -d 'New tab'
complete -c obsidian -n __obsidian_no_subcommand -a 'random:read' -d 'Read random note'
complete -c obsidian -n '__obsidian_using_subcommand random:read' -a 'folder=' -d 'Limit to folder'

# read
complete -c obsidian -n __obsidian_no_subcommand -a read -d 'Read file contents'
complete -c obsidian -n '__obsidian_using_subcommand read' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand read' -a 'path=' -d 'File path'

# recents / reload / restart
complete -c obsidian -n __obsidian_no_subcommand -a recents -d 'Recently opened files'
complete -c obsidian -n '__obsidian_using_subcommand recents' -a total -d 'Return count'
complete -c obsidian -n __obsidian_no_subcommand -a reload -d 'Reload the vault'
complete -c obsidian -n __obsidian_no_subcommand -a restart -d 'Restart the app'

# rename
complete -c obsidian -n __obsidian_no_subcommand -a rename -d 'Rename a file'
complete -c obsidian -n '__obsidian_using_subcommand rename' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand rename' -a 'path=' -d 'File path'
complete -c obsidian -n '__obsidian_using_subcommand rename' -a 'name=' -d 'New name (required)'

# search
complete -c obsidian -n __obsidian_no_subcommand -a search -d 'Search vault'
complete -c obsidian -n '__obsidian_using_subcommand search' -a 'query=' -d 'Search query (required)'
complete -c obsidian -n '__obsidian_using_subcommand search' -a 'path=' -d 'Limit to folder'
complete -c obsidian -n '__obsidian_using_subcommand search' -a 'limit=' -d 'Max files'
complete -c obsidian -n '__obsidian_using_subcommand search' -a total -d 'Return count'
complete -c obsidian -n '__obsidian_using_subcommand search' -a case -d 'Case sensitive'
complete -c obsidian -n '__obsidian_using_subcommand search' -a 'format=text' -d Text
complete -c obsidian -n '__obsidian_using_subcommand search' -a 'format=json' -d JSON
complete -c obsidian -n __obsidian_no_subcommand -a 'search:context' -d 'Search with line context'
complete -c obsidian -n '__obsidian_using_subcommand search:context' -a 'query=' -d 'Query (required)'
complete -c obsidian -n '__obsidian_using_subcommand search:context' -a 'path=' -d 'Limit to folder'
complete -c obsidian -n '__obsidian_using_subcommand search:context' -a 'limit=' -d 'Max files'
complete -c obsidian -n '__obsidian_using_subcommand search:context' -a case -d 'Case sensitive'
complete -c obsidian -n '__obsidian_using_subcommand search:context' -a 'format=text' -d Text
complete -c obsidian -n '__obsidian_using_subcommand search:context' -a 'format=json' -d JSON
complete -c obsidian -n __obsidian_no_subcommand -a 'search:open' -d 'Open search view'
complete -c obsidian -n '__obsidian_using_subcommand search:open' -a 'query=' -d Query

# snippets
complete -c obsidian -n __obsidian_no_subcommand -a snippets -d 'List CSS snippets'
complete -c obsidian -n __obsidian_no_subcommand -a 'snippets:enabled' -d 'List enabled snippets'
complete -c obsidian -n __obsidian_no_subcommand -a 'snippet:enable' -d 'Enable CSS snippet'
complete -c obsidian -n '__obsidian_using_subcommand snippet:enable' -a 'name=' -d 'Snippet (required)'
complete -c obsidian -n __obsidian_no_subcommand -a 'snippet:disable' -d 'Disable CSS snippet'
complete -c obsidian -n '__obsidian_using_subcommand snippet:disable' -a 'name=' -d 'Snippet (required)'

# sync
complete -c obsidian -n __obsidian_no_subcommand -a sync -d 'Pause/resume sync'
complete -c obsidian -n '__obsidian_using_subcommand sync' -a on -d 'Resume sync'
complete -c obsidian -n '__obsidian_using_subcommand sync' -a off -d 'Pause sync'
complete -c obsidian -n __obsidian_no_subcommand -a 'sync:status' -d 'Show sync status'
complete -c obsidian -n __obsidian_no_subcommand -a 'sync:deleted' -d 'Deleted files in sync'
complete -c obsidian -n '__obsidian_using_subcommand sync:deleted' -a total -d 'Return count'
complete -c obsidian -n __obsidian_no_subcommand -a 'sync:history' -d 'Sync version history'
complete -c obsidian -n '__obsidian_using_subcommand sync:history' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand sync:history' -a 'path=' -d 'File path'
complete -c obsidian -n '__obsidian_using_subcommand sync:history' -a total -d 'Return count'
complete -c obsidian -n __obsidian_no_subcommand -a 'sync:open' -d 'Open sync history'
complete -c obsidian -n '__obsidian_using_subcommand sync:open' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand sync:open' -a 'path=' -d 'File path'
complete -c obsidian -n __obsidian_no_subcommand -a 'sync:read' -d 'Read sync version'
complete -c obsidian -n '__obsidian_using_subcommand sync:read' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand sync:read' -a 'path=' -d 'File path'
complete -c obsidian -n '__obsidian_using_subcommand sync:read' -a 'version=' -d 'Version (required)'
complete -c obsidian -n __obsidian_no_subcommand -a 'sync:restore' -d 'Restore sync version'
complete -c obsidian -n '__obsidian_using_subcommand sync:restore' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand sync:restore' -a 'path=' -d 'File path'
complete -c obsidian -n '__obsidian_using_subcommand sync:restore' -a 'version=' -d 'Version (required)'

# tabs
complete -c obsidian -n __obsidian_no_subcommand -a tabs -d 'List open tabs'
complete -c obsidian -n '__obsidian_using_subcommand tabs' -a ids -d 'Include tab IDs'
complete -c obsidian -n __obsidian_no_subcommand -a 'tab:open' -d 'Open new tab'
complete -c obsidian -n '__obsidian_using_subcommand tab:open' -a 'group=' -d 'Tab group ID'
complete -c obsidian -n '__obsidian_using_subcommand tab:open' -a 'file=' -d 'File to open'
complete -c obsidian -n '__obsidian_using_subcommand tab:open' -a 'view=' -d 'View type'

# tags
complete -c obsidian -n __obsidian_no_subcommand -a tags -d 'List tags'
complete -c obsidian -n '__obsidian_using_subcommand tags' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand tags' -a 'path=' -d 'File path'
complete -c obsidian -n '__obsidian_using_subcommand tags' -a total -d 'Return count'
complete -c obsidian -n '__obsidian_using_subcommand tags' -a counts -d 'Include counts'
complete -c obsidian -n '__obsidian_using_subcommand tags' -a 'sort=count' -d 'Sort by count'
complete -c obsidian -n '__obsidian_using_subcommand tags' -a active -d 'Active file'
complete -c obsidian -n '__obsidian_using_subcommand tags' -a 'format=json' -d JSON
complete -c obsidian -n '__obsidian_using_subcommand tags' -a 'format=tsv' -d TSV
complete -c obsidian -n '__obsidian_using_subcommand tags' -a 'format=csv' -d CSV
complete -c obsidian -n __obsidian_no_subcommand -a tag -d 'Get tag info'
complete -c obsidian -n '__obsidian_using_subcommand tag' -a 'name=' -d 'Tag name (required)'
complete -c obsidian -n '__obsidian_using_subcommand tag' -a total -d 'Return count'
complete -c obsidian -n '__obsidian_using_subcommand tag' -a verbose -d 'Include file list'

# tasks
complete -c obsidian -n __obsidian_no_subcommand -a tasks -d 'List tasks'
complete -c obsidian -n '__obsidian_using_subcommand tasks' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand tasks' -a 'path=' -d 'File path'
complete -c obsidian -n '__obsidian_using_subcommand tasks' -a 'status=' -d 'Filter by status'
complete -c obsidian -n '__obsidian_using_subcommand tasks' -a total -d 'Return count'
complete -c obsidian -n '__obsidian_using_subcommand tasks' -a done -d 'Show completed'
complete -c obsidian -n '__obsidian_using_subcommand tasks' -a todo -d 'Show incomplete'
complete -c obsidian -n '__obsidian_using_subcommand tasks' -a verbose -d 'Group by file'
complete -c obsidian -n '__obsidian_using_subcommand tasks' -a active -d 'Active file'
complete -c obsidian -n '__obsidian_using_subcommand tasks' -a daily -d 'Daily note'
complete -c obsidian -n '__obsidian_using_subcommand tasks' -a 'format=json' -d JSON
complete -c obsidian -n '__obsidian_using_subcommand tasks' -a 'format=tsv' -d TSV
complete -c obsidian -n '__obsidian_using_subcommand tasks' -a 'format=csv' -d CSV
complete -c obsidian -n __obsidian_no_subcommand -a task -d 'Show/update task'
complete -c obsidian -n '__obsidian_using_subcommand task' -a 'ref=' -d 'Task ref (path:line)'
complete -c obsidian -n '__obsidian_using_subcommand task' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand task' -a 'path=' -d 'File path'
complete -c obsidian -n '__obsidian_using_subcommand task' -a 'line=' -d 'Line number'
complete -c obsidian -n '__obsidian_using_subcommand task' -a 'status=' -d 'Status character'
complete -c obsidian -n '__obsidian_using_subcommand task' -a toggle -d 'Toggle status'
complete -c obsidian -n '__obsidian_using_subcommand task' -a done -d 'Mark done'
complete -c obsidian -n '__obsidian_using_subcommand task' -a todo -d 'Mark todo'
complete -c obsidian -n '__obsidian_using_subcommand task' -a daily -d 'Use daily note'

# templates
complete -c obsidian -n __obsidian_no_subcommand -a templates -d 'List templates'
complete -c obsidian -n '__obsidian_using_subcommand templates' -a total -d 'Return count'
complete -c obsidian -n __obsidian_no_subcommand -a 'template:insert' -d 'Insert template'
complete -c obsidian -n '__obsidian_using_subcommand template:insert' -a 'name=' -d 'Template (required)'
complete -c obsidian -n __obsidian_no_subcommand -a 'template:read' -d 'Read template'
complete -c obsidian -n '__obsidian_using_subcommand template:read' -a 'name=' -d 'Template (required)'
complete -c obsidian -n '__obsidian_using_subcommand template:read' -a resolve -d 'Resolve variables'
complete -c obsidian -n '__obsidian_using_subcommand template:read' -a 'title=' -d 'Title for resolution'

# themes
complete -c obsidian -n __obsidian_no_subcommand -a themes -d 'List installed themes'
complete -c obsidian -n '__obsidian_using_subcommand themes' -a versions -d 'Include versions'
complete -c obsidian -n __obsidian_no_subcommand -a theme -d 'Show active theme'
complete -c obsidian -n '__obsidian_using_subcommand theme' -a 'name=' -d 'Theme name'
complete -c obsidian -n __obsidian_no_subcommand -a 'theme:set' -d 'Set active theme'
complete -c obsidian -n '__obsidian_using_subcommand theme:set' -a 'name=' -d 'Theme (required)'
complete -c obsidian -n __obsidian_no_subcommand -a 'theme:install' -d 'Install theme'
complete -c obsidian -n '__obsidian_using_subcommand theme:install' -a 'name=' -d 'Theme (required)'
complete -c obsidian -n '__obsidian_using_subcommand theme:install' -a enable -d 'Activate after'
complete -c obsidian -n __obsidian_no_subcommand -a 'theme:uninstall' -d 'Uninstall theme'
complete -c obsidian -n '__obsidian_using_subcommand theme:uninstall' -a 'name=' -d 'Theme (required)'

# unique
complete -c obsidian -n __obsidian_no_subcommand -a unique -d 'Create unique note'
complete -c obsidian -n '__obsidian_using_subcommand unique' -a 'name=' -d 'Note name'
complete -c obsidian -n '__obsidian_using_subcommand unique' -a 'content=' -d Content
complete -c obsidian -n '__obsidian_using_subcommand unique' -a 'paneType=tab' -d Tab
complete -c obsidian -n '__obsidian_using_subcommand unique' -a 'paneType=split' -d Split
complete -c obsidian -n '__obsidian_using_subcommand unique' -a 'paneType=window' -d Window
complete -c obsidian -n '__obsidian_using_subcommand unique' -a open -d 'Open after'

# unresolved
complete -c obsidian -n __obsidian_no_subcommand -a unresolved -d 'Unresolved links'
complete -c obsidian -n '__obsidian_using_subcommand unresolved' -a total -d 'Return count'
complete -c obsidian -n '__obsidian_using_subcommand unresolved' -a counts -d 'Include counts'
complete -c obsidian -n '__obsidian_using_subcommand unresolved' -a verbose -d 'Include sources'
complete -c obsidian -n '__obsidian_using_subcommand unresolved' -a 'format=json' -d JSON
complete -c obsidian -n '__obsidian_using_subcommand unresolved' -a 'format=tsv' -d TSV
complete -c obsidian -n '__obsidian_using_subcommand unresolved' -a 'format=csv' -d CSV

# vault / vaults
complete -c obsidian -n __obsidian_no_subcommand -a vault -d 'Show vault info'
complete -c obsidian -n '__obsidian_using_subcommand vault' -a 'info=name' -d 'Vault name'
complete -c obsidian -n '__obsidian_using_subcommand vault' -a 'info=path' -d 'Vault path'
complete -c obsidian -n '__obsidian_using_subcommand vault' -a 'info=files' -d 'File count'
complete -c obsidian -n '__obsidian_using_subcommand vault' -a 'info=folders' -d 'Folder count'
complete -c obsidian -n '__obsidian_using_subcommand vault' -a 'info=size' -d 'Vault size'
complete -c obsidian -n __obsidian_no_subcommand -a vaults -d 'List known vaults'
complete -c obsidian -n '__obsidian_using_subcommand vaults' -a total -d 'Return count'
complete -c obsidian -n '__obsidian_using_subcommand vaults' -a verbose -d 'Include paths'

# version
complete -c obsidian -n __obsidian_no_subcommand -a version -d 'Show Obsidian version'

# web
complete -c obsidian -n __obsidian_no_subcommand -a web -d 'Open URL in web viewer'
complete -c obsidian -n '__obsidian_using_subcommand web' -a 'url=' -d 'URL (required)'
complete -c obsidian -n '__obsidian_using_subcommand web' -a newtab -d 'New tab'

# wordcount
complete -c obsidian -n __obsidian_no_subcommand -a wordcount -d 'Count words/characters'
complete -c obsidian -n '__obsidian_using_subcommand wordcount' -a 'file=' -d 'File name'
complete -c obsidian -n '__obsidian_using_subcommand wordcount' -a 'path=' -d 'File path'
complete -c obsidian -n '__obsidian_using_subcommand wordcount' -a words -d 'Words only'
complete -c obsidian -n '__obsidian_using_subcommand wordcount' -a characters -d 'Characters only'

# workspace
complete -c obsidian -n __obsidian_no_subcommand -a workspace -d 'Show workspace tree'
complete -c obsidian -n '__obsidian_using_subcommand workspace' -a ids -d 'Include IDs'
complete -c obsidian -n __obsidian_no_subcommand -a workspaces -d 'List saved workspaces'
complete -c obsidian -n '__obsidian_using_subcommand workspaces' -a total -d 'Return count'
complete -c obsidian -n __obsidian_no_subcommand -a 'workspace:save' -d 'Save workspace'
complete -c obsidian -n '__obsidian_using_subcommand workspace:save' -a 'name=' -d 'Workspace name'
complete -c obsidian -n __obsidian_no_subcommand -a 'workspace:load' -d 'Load workspace'
complete -c obsidian -n '__obsidian_using_subcommand workspace:load' -a 'name=' -d 'Name (required)'
complete -c obsidian -n __obsidian_no_subcommand -a 'workspace:delete' -d 'Delete workspace'
complete -c obsidian -n '__obsidian_using_subcommand workspace:delete' -a 'name=' -d 'Name (required)'

# ── Developer commands ──

complete -c obsidian -n __obsidian_no_subcommand -a devtools -d 'Toggle dev tools'

complete -c obsidian -n __obsidian_no_subcommand -a 'dev:cdp' -d 'Run CDP command'
complete -c obsidian -n '__obsidian_using_subcommand dev:cdp' -a 'method=' -d 'CDP method (required)'
complete -c obsidian -n '__obsidian_using_subcommand dev:cdp' -a 'params=' -d 'JSON params'

complete -c obsidian -n __obsidian_no_subcommand -a 'dev:console' -d 'Show console messages'
complete -c obsidian -n '__obsidian_using_subcommand dev:console' -a clear -d 'Clear buffer'
complete -c obsidian -n '__obsidian_using_subcommand dev:console' -a 'limit=' -d 'Max messages'
complete -c obsidian -n '__obsidian_using_subcommand dev:console' -a 'level=log' -d Log
complete -c obsidian -n '__obsidian_using_subcommand dev:console' -a 'level=warn' -d Warn
complete -c obsidian -n '__obsidian_using_subcommand dev:console' -a 'level=error' -d Error
complete -c obsidian -n '__obsidian_using_subcommand dev:console' -a 'level=info' -d Info
complete -c obsidian -n '__obsidian_using_subcommand dev:console' -a 'level=debug' -d Debug

complete -c obsidian -n __obsidian_no_subcommand -a 'dev:css' -d 'Inspect CSS'
complete -c obsidian -n '__obsidian_using_subcommand dev:css' -a 'selector=' -d 'CSS selector (required)'
complete -c obsidian -n '__obsidian_using_subcommand dev:css' -a 'prop=' -d 'Property name'

complete -c obsidian -n __obsidian_no_subcommand -a 'dev:debug' -d 'Attach/detach CDP debugger'
complete -c obsidian -n '__obsidian_using_subcommand dev:debug' -a on -d Attach
complete -c obsidian -n '__obsidian_using_subcommand dev:debug' -a off -d Detach

complete -c obsidian -n __obsidian_no_subcommand -a 'dev:dom' -d 'Query DOM elements'
complete -c obsidian -n '__obsidian_using_subcommand dev:dom' -a 'selector=' -d 'CSS selector (required)'
complete -c obsidian -n '__obsidian_using_subcommand dev:dom' -a total -d 'Element count'
complete -c obsidian -n '__obsidian_using_subcommand dev:dom' -a text -d 'Text content'
complete -c obsidian -n '__obsidian_using_subcommand dev:dom' -a inner -d innerHTML
complete -c obsidian -n '__obsidian_using_subcommand dev:dom' -a all -d 'All matches'
complete -c obsidian -n '__obsidian_using_subcommand dev:dom' -a 'attr=' -d 'Attribute value'
complete -c obsidian -n '__obsidian_using_subcommand dev:dom' -a 'css=' -d 'CSS property'

complete -c obsidian -n __obsidian_no_subcommand -a 'dev:errors' -d 'Show JS errors'
complete -c obsidian -n '__obsidian_using_subcommand dev:errors' -a clear -d 'Clear buffer'

complete -c obsidian -n __obsidian_no_subcommand -a 'dev:mobile' -d 'Toggle mobile emulation'
complete -c obsidian -n '__obsidian_using_subcommand dev:mobile' -a on -d Enable
complete -c obsidian -n '__obsidian_using_subcommand dev:mobile' -a off -d Disable

complete -c obsidian -n __obsidian_no_subcommand -a 'dev:screenshot' -d 'Take screenshot'
complete -c obsidian -n '__obsidian_using_subcommand dev:screenshot' -a 'path=' -d 'Output file path'

complete -c obsidian -n __obsidian_no_subcommand -a eval -d 'Execute JavaScript'
complete -c obsidian -n '__obsidian_using_subcommand eval' -a 'code=' -d 'JavaScript (required)'
