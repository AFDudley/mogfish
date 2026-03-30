# Fish completion for BastilleBSD

# Disable file completions for the entire command
complete -c bastille -f

# Main subcommands
complete -c bastille -f -n '__fish_use_subcommand' -a 'bootstrap' -d 'Bootstrap a release for jail base'
complete -c bastille -f -n '__fish_use_subcommand' -a 'clone' -d 'Clone an existing jail'
complete -c bastille -f -n '__fish_use_subcommand' -a 'cmd' -d 'Execute arbitrary command on targeted jail(s)'
complete -c bastille -f -n '__fish_use_subcommand' -a 'config' -d 'Get, set or remove a config value for the targeted jail(s)'
complete -c bastille -f -n '__fish_use_subcommand' -a 'console' -d 'Console into a jail'
complete -c bastille -f -n '__fish_use_subcommand' -a 'create' -d 'Create a new jail'
complete -c bastille -f -n '__fish_use_subcommand' -a 'destroy' -d 'Destroy a jail'
complete -c bastille -f -n '__fish_use_subcommand' -a 'edit' -d 'Edit jail configuration'
complete -c bastille -f -n '__fish_use_subcommand' -a 'export' -d 'Export a jail'
complete -c bastille -f -n '__fish_use_subcommand' -a 'htop' -d 'Interactive process viewer for jail'
complete -c bastille -f -n '__fish_use_subcommand' -a 'import' -d 'Import a jail'
complete -c bastille -f -n '__fish_use_subcommand' -a 'limits' -d 'Apply resource limits to jail'
complete -c bastille -f -n '__fish_use_subcommand' -a 'list' -d 'List jails'
complete -c bastille -f -n '__fish_use_subcommand' -a 'pkg' -d 'Manage packages in jail'
complete -c bastille -f -n '__fish_use_subcommand' -a 'restart' -d 'Restart a jail'
complete -c bastille -f -n '__fish_use_subcommand' -a 'rdr' -d 'Redirect host port to jail port'
complete -c bastille -f -n '__fish_use_subcommand' -a 'service' -d 'Manage services in jail'
complete -c bastille -f -n '__fish_use_subcommand' -a 'start' -d 'Start a jail'
complete -c bastille -f -n '__fish_use_subcommand' -a 'stop' -d 'Stop a jail'
complete -c bastille -f -n '__fish_use_subcommand' -a 'template' -d 'Apply template to jail'
complete -c bastille -f -n '__fish_use_subcommand' -a 'top' -d 'Display running processes in jail'
complete -c bastille -f -n '__fish_use_subcommand' -a 'update' -d 'Update jail'
complete -c bastille -f -n '__fish_use_subcommand' -a 'upgrade' -d 'Upgrade jail'

# Run given arguments as root, via doas or sudo or don't run it at all
function runasroot
    if fish_is_root_user
        $argv
    else if command -q doas
        doas $argv
    else if command -q sudo
        sudo $argv
    end
end

function __bastille_jails
    jls -h name | tail -n +2
end

function __bastille_commandline_count
    test (count (commandline -xpc)) -eq $argv
end

function __bastille_templates
    cd /usr/local/bastille/templates/
    path dirname */*/Bastillefile
end

# Bootstrap options
complete -c bastille -f -n '__fish_seen_subcommand_from bootstrap' -s h -l help -d 'Show help'

# List options
complete -c bastille -f -n '__fish_seen_subcommand_from list' -s a -l all -d 'List all jails'
complete -c bastille -f -n '__fish_seen_subcommand_from list' -s j -l jails -d 'List running jails'

# Config operations
complete -c bastille -f -n '__fish_seen_subcommand_from config' -a 'get set remove' -d 'Config operation'

# Service operations
function __bastille_print_service_name
    set -l cmd (commandline -opc)
    runasroot service -j $cmd[3] -l
end

# Service completion: First jail name, then service operations
complete -c bastille -f -n '__fish_seen_subcommand_from service; and __bastille_commandline_count 2' -a '(__bastille_jails)' -d 'Jail'
complete -c bastille -f -n '__fish_seen_subcommand_from service; and __bastille_commandline_count 3' -a '(__bastille_print_service_name)' -d 'Service'
complete -c bastille -f -n '__fish_seen_subcommand_from service; and __bastille_commandline_count 4' -a 'start stop restart status enable disable' -d 'Service operation'

# Pkg operations
complete -c bastille -f -n '__fish_seen_subcommand_from pkg' -a 'install remove update upgrade search info' -d 'Package operation'

# template operations
complete -c bastille -f -n '__fish_seen_subcommand_from template' -a '(__bastille_templates)' -d 'Template'

# Complete jail names for commands that need them
complete -c bastille -f -n '__fish_seen_subcommand_from clone cmd config console destroy edit export htop limits pkg restart rdr start stop template top update upgrade' -a '(__bastille_jails)' -d 'Jail'

# Global options
complete -c bastille -f -s h -l help -d 'Show help'
complete -c bastille -f -s v -l version -d 'Show version'
