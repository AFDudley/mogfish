# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_somo_global_optspecs
	string join \n k/kill proto= t/tcp u/udp ip= remote-port= p/port= program= pid= format= json o/open l/listen exclude-ipv6 c/compact r/reverse s/sort= h/help V/version
end

function __fish_somo_needs_command
	# Figure out if the current invocation already has a command.
	set -l cmd (commandline -opc)
	set -e cmd[1]
	argparse -s (__fish_somo_global_optspecs) -- $cmd 2>/dev/null
	or return
	if set -q argv[1]
		# Also print the command, so this can be used to figure out what it is.
		echo $argv[1]
		return 1
	end
	return 0
end

function __fish_somo_using_subcommand
	set -l cmd (__fish_somo_needs_command)
	test -z "$cmd"
	and return 1
	contains -- $cmd[1] $argv
end

complete -c somo -n "__fish_somo_needs_command" -l proto -d 'Deprecated. Use \'--tcp\' and \'--udp\' instead' -r
complete -c somo -n "__fish_somo_needs_command" -l ip -d 'Filter connections by remote IP address' -r
complete -c somo -n "__fish_somo_needs_command" -l remote-port -d 'Filter connections by remote port' -r
complete -c somo -n "__fish_somo_needs_command" -s p -l port -d 'Filter connections by local port' -r
complete -c somo -n "__fish_somo_needs_command" -l program -d 'Filter connections by program name' -r
complete -c somo -n "__fish_somo_needs_command" -l pid -d 'Filter connections by PID' -r
complete -c somo -n "__fish_somo_needs_command" -l format -d 'Format the output in a certain way, e.g., `somo --format "PID: {{pid}}, Protocol: {{proto}}, Remote Address: {{remote_address}}"`' -r
complete -c somo -n "__fish_somo_needs_command" -s s -l sort -d 'Sort by column name' -r -f -a "proto\t''
local_port\t''
remote_address\t''
remote_port\t''
program\t''
pid\t''
state\t''"
complete -c somo -n "__fish_somo_needs_command" -s k -l kill -d 'Display an interactive selection option after inspecting connections'
complete -c somo -n "__fish_somo_needs_command" -s t -l tcp -d 'Include TCP connections'
complete -c somo -n "__fish_somo_needs_command" -s u -l udp -d 'Include UDP connections'
complete -c somo -n "__fish_somo_needs_command" -l json -d 'Output in JSON'
complete -c somo -n "__fish_somo_needs_command" -s o -l open -d 'Filter by open connections'
complete -c somo -n "__fish_somo_needs_command" -s l -l listen -d 'Filter by listening connections'
complete -c somo -n "__fish_somo_needs_command" -l exclude-ipv6 -d 'Exclude IPv6 connections'
complete -c somo -n "__fish_somo_needs_command" -s c -l compact
complete -c somo -n "__fish_somo_needs_command" -s r -l reverse -d 'Reverse order of the table'
complete -c somo -n "__fish_somo_needs_command" -s h -l help -d 'Print help'
complete -c somo -n "__fish_somo_needs_command" -s V -l version -d 'Print version'
complete -c somo -n "__fish_somo_needs_command" -f -a "generate-completions" -d 'Generate shell completions'
complete -c somo -n "__fish_somo_needs_command" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c somo -n "__fish_somo_using_subcommand generate-completions" -s h -l help -d 'Print help'
complete -c somo -n "__fish_somo_using_subcommand help; and not __fish_seen_subcommand_from generate-completions help" -f -a "generate-completions" -d 'Generate shell completions'
complete -c somo -n "__fish_somo_using_subcommand help; and not __fish_seen_subcommand_from generate-completions help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
