# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_llvm_cov_pretty_global_optspecs
	string join \n no-highlight show-instantiations theme= coverage-style= manifest-path= output-dir= open skip-function-coverage h/help V/version
end

function __fish_llvm_cov_pretty_needs_command
	# Figure out if the current invocation already has a command.
	set -l cmd (commandline -opc)
	set -e cmd[1]
	argparse -s (__fish_llvm_cov_pretty_global_optspecs) -- $cmd 2>/dev/null
	or return
	if set -q argv[1]
		# Also print the command, so this can be used to figure out what it is.
		echo $argv[1]
		return 1
	end
	return 0
end

function __fish_llvm_cov_pretty_using_subcommand
	set -l cmd (__fish_llvm_cov_pretty_needs_command)
	test -z "$cmd"
	and return 1
	contains -- $cmd[1] $argv
end

complete -c llvm-cov-pretty -n "__fish_llvm_cov_pretty_needs_command" -l theme -d 'The highlighting theme to use, if not disabled' -r -f -a "solarized\t'🔳 Both light and dark theme'
base16-ocean\t'🔳 Both light and dark theme'
one-three-three-seven\t'⬛ Dark theme only'
coldark\t'🔳 Both light and dark theme'
dark-neon\t'⬛ Dark theme only'
dracula\t'⬛ Dark theme only'
github\t'⬜ Light theme only'
gruvbox\t'🔳 Both light and dark theme'
nord\t'⬛ Dark theme only'
one-half\t'🔳 Both light and dark theme'
monokai-extended\t'🔳 Both light and dark theme'
snazzy\t'⬛ Dark theme only'
two-dark\t'⬛ Dark theme only'
visual-studio-plus\t'⬛ Dark theme only'
zenburn\t'⬛ Dark theme only'"
complete -c llvm-cov-pretty -n "__fish_llvm_cov_pretty_needs_command" -l coverage-style -d 'Where to place the coverage color marker' -r -f -a "line\t'Highlight the whole source line'
gutter\t'Only highlight the gutter (count column)'"
complete -c llvm-cov-pretty -n "__fish_llvm_cov_pretty_needs_command" -l manifest-path -d 'Location of the project\'s Cargo.toml, in case the default detection isn\'t sufficient' -r -F
complete -c llvm-cov-pretty -n "__fish_llvm_cov_pretty_needs_command" -l output-dir -d 'Alternative location to save the report files to, overriding the default' -r -f -a "(__fish_complete_directories)"
complete -c llvm-cov-pretty -n "__fish_llvm_cov_pretty_needs_command" -l no-highlight -d 'Disable any code highlighting'
complete -c llvm-cov-pretty -n "__fish_llvm_cov_pretty_needs_command" -l show-instantiations -d 'Show annotations for missing instantiations'
complete -c llvm-cov-pretty -n "__fish_llvm_cov_pretty_needs_command" -l open -d 'Open the report in the default application after it\'s been generated'
complete -c llvm-cov-pretty -n "__fish_llvm_cov_pretty_needs_command" -l skip-function-coverage -d 'Skip overlaying regular file coverage with function invocation coverage (in source views)'
complete -c llvm-cov-pretty -n "__fish_llvm_cov_pretty_needs_command" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c llvm-cov-pretty -n "__fish_llvm_cov_pretty_needs_command" -s V -l version -d 'Print version'
complete -c llvm-cov-pretty -n "__fish_llvm_cov_pretty_needs_command" -a "completions" -d 'Generate auto-completions scripts for various shells'
complete -c llvm-cov-pretty -n "__fish_llvm_cov_pretty_needs_command" -a "manpages" -d 'Generate man pages into the given directory'
complete -c llvm-cov-pretty -n "__fish_llvm_cov_pretty_needs_command" -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c llvm-cov-pretty -n "__fish_llvm_cov_pretty_using_subcommand completions" -s h -l help -d 'Print help'
complete -c llvm-cov-pretty -n "__fish_llvm_cov_pretty_using_subcommand manpages" -s h -l help -d 'Print help'
complete -c llvm-cov-pretty -n "__fish_llvm_cov_pretty_using_subcommand help; and not __fish_seen_subcommand_from completions manpages help" -f -a "completions" -d 'Generate auto-completions scripts for various shells'
complete -c llvm-cov-pretty -n "__fish_llvm_cov_pretty_using_subcommand help; and not __fish_seen_subcommand_from completions manpages help" -f -a "manpages" -d 'Generate man pages into the given directory'
complete -c llvm-cov-pretty -n "__fish_llvm_cov_pretty_using_subcommand help; and not __fish_seen_subcommand_from completions manpages help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
