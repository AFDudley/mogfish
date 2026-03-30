# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_turbo_global_optspecs
	string join \n version skip-infer no-update-notifier api= color cwd= heap= ui= login= no-color preflight remote-cache-timeout= team= token= trace= verbosity= v check-for-update __test-run dangerously-disable-package-manager-check experimental-allow-no-turbo-json root-turbo-json= cache= force= remote-only= remote-cache-read-only= no-cache cache-workers= dry-run= graph= daemon no-daemon profile= anon-profile= summarize= experimental-space-id= parallel cache-dir= concurrency= continue single-package framework-inference= global-deps= env-mode= F/filter= affected output-logs= log-order= only pkg-inference-root= log-prefix= h/help
end

function __fish_turbo_needs_command
	# Figure out if the current invocation already has a command.
	set -l cmd (commandline -opc)
	set -e cmd[1]
	argparse -s (__fish_turbo_global_optspecs) -- $cmd 2>/dev/null
	or return
	if set -q argv[1]
		# Also print the command, so this can be used to figure out what it is.
		echo $argv[1]
		return 1
	end
	return 0
end

function __fish_turbo_using_subcommand
	set -l cmd (__fish_turbo_needs_command)
	test -z "$cmd"
	and return 1
	contains -- $cmd[1] $argv
end

complete -c turbo -n "__fish_turbo_needs_command" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_needs_command" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_needs_command" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_needs_command" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_needs_command" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_needs_command" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_needs_command" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_needs_command" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_needs_command" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_needs_command" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_needs_command" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_needs_command" -l cache -d 'Set the cache behavior for this run. Pass a list of comma-separated key, value pairs to enable reading and writing to either the local or remote cache' -r
complete -c turbo -n "__fish_turbo_needs_command" -l force -d 'Ignore the existing cache (to force execution). Equivalent to `--cache=local:w,remote:w`' -r -f -a "{true\t'',false\t''}"
complete -c turbo -n "__fish_turbo_needs_command" -l remote-only -d 'Ignore the local filesystem cache for all tasks. Only allow reading and caching artifacts using the remote cache. Equivalent to `--cache=remote:rw`' -r -f -a "{true\t'',false\t''}"
complete -c turbo -n "__fish_turbo_needs_command" -l remote-cache-read-only -d 'Treat remote cache as read only. Equivalent to `--cache=remote:r;local:rw`' -r -f -a "{true\t'',false\t''}"
complete -c turbo -n "__fish_turbo_needs_command" -l cache-workers -d 'Set the number of concurrent cache operations (default 10)' -r
complete -c turbo -n "__fish_turbo_needs_command" -l dry-run -r -f -a "{text\t'',json\t''}"
complete -c turbo -n "__fish_turbo_needs_command" -l graph -d 'Generate a graph of the task execution and output to a file when a filename is specified (.svg, .png, .jpg, .pdf, .json, .html, .mermaid, .dot). Outputs dot graph to stdout when if no filename is provided' -r
complete -c turbo -n "__fish_turbo_needs_command" -l profile -d 'File to write turbo\'s performance profile output into. You can load the file up in chrome://tracing to see which parts of your build were slow' -r
complete -c turbo -n "__fish_turbo_needs_command" -l anon-profile -d 'File to write turbo\'s performance profile output into. All identifying data omitted from the profile' -r
complete -c turbo -n "__fish_turbo_needs_command" -l summarize -d 'Generate a summary of the turbo run' -r -f -a "{true\t'',false\t''}"
complete -c turbo -n "__fish_turbo_needs_command" -l experimental-space-id -r
complete -c turbo -n "__fish_turbo_needs_command" -l cache-dir -d 'Override the filesystem cache directory' -r
complete -c turbo -n "__fish_turbo_needs_command" -l concurrency -d 'Limit the concurrency of task execution. Use 1 for serial (i.e. one-at-a-time) execution' -r
complete -c turbo -n "__fish_turbo_needs_command" -l framework-inference -d 'Specify whether or not to do framework inference for tasks' -r -f -a "{true\t'',false\t''}"
complete -c turbo -n "__fish_turbo_needs_command" -l global-deps -d 'Specify glob of global filesystem dependencies to be hashed. Useful for .env and files' -r
complete -c turbo -n "__fish_turbo_needs_command" -l env-mode -d 'Environment variable mode. Use "loose" to pass the entire existing environment. Use "strict" to use an allowlist specified in turbo.json' -r -f -a "{loose\t'',strict\t''}"
complete -c turbo -n "__fish_turbo_needs_command" -s F -l filter -d 'Use the given selector to specify package(s) to act as entry points. The syntax mirrors pnpm\'s syntax, and additional documentation and examples can be found in turbo\'s documentation https://turbo.build/repo/docs/reference/command-line-reference/run#--filter' -r
complete -c turbo -n "__fish_turbo_needs_command" -l output-logs -d 'Set type of process output logging. Use "full" to show all output. Use "hash-only" to show only turbo-computed task hashes. Use "new-only" to show only new output with only hashes for cached tasks. Use "none" to hide process output. (default full)' -r -f -a "{full\t'',none\t'',hash-only\t'',new-only\t'',errors-only\t''}"
complete -c turbo -n "__fish_turbo_needs_command" -l log-order -d 'Set type of task output order. Use "stream" to show output as soon as it is available. Use "grouped" to show output when a command has finished execution. Use "auto" to let turbo decide based on its own heuristics. (default auto)' -r -f -a "{auto\t'',stream\t'',grouped\t''}"
complete -c turbo -n "__fish_turbo_needs_command" -l pkg-inference-root -r
complete -c turbo -n "__fish_turbo_needs_command" -l log-prefix -d 'Use "none" to remove prefixes from task logs. Use "task" to get task id prefixing. Use "auto" to let turbo decide how to prefix the logs based on the execution environment. In most cases this will be the same as "task". Note that tasks running in parallel interleave their logs, so removing prefixes can make it difficult to associate logs with tasks. Use --log-order=grouped to prevent interleaving. (default auto)' -r -f -a "{auto\t'',none\t'',task\t''}"
complete -c turbo -n "__fish_turbo_needs_command" -l version
complete -c turbo -n "__fish_turbo_needs_command" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_needs_command" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_needs_command" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_needs_command" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_needs_command" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_needs_command" -s v
complete -c turbo -n "__fish_turbo_needs_command" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_needs_command" -l __test-run
complete -c turbo -n "__fish_turbo_needs_command" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_needs_command" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_needs_command" -l no-cache -d 'Avoid saving task results to the cache. Useful for development/watch tasks. Equivalent to `--cache=local:r,remote:r`'
complete -c turbo -n "__fish_turbo_needs_command" -l daemon -d 'Force turbo to use the local daemon. If unset turbo will use the default detection logic'
complete -c turbo -n "__fish_turbo_needs_command" -l no-daemon -d 'Force turbo to not use the local daemon. If unset turbo will use the default detection logic'
complete -c turbo -n "__fish_turbo_needs_command" -l parallel -d 'Execute all tasks in parallel'
complete -c turbo -n "__fish_turbo_needs_command" -l continue -d 'Continue execution even if a task exits with an error or non-zero exit code. The default behavior is to bail'
complete -c turbo -n "__fish_turbo_needs_command" -l single-package -d 'Run turbo in single-package mode'
complete -c turbo -n "__fish_turbo_needs_command" -l affected -d 'Run only tasks that are affected by changes between the current branch and `main`'
complete -c turbo -n "__fish_turbo_needs_command" -l only -d 'Only executes the tasks specified, does not execute parent tasks'
complete -c turbo -n "__fish_turbo_needs_command" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_needs_command" -a "bin" -d 'Get the path to the Turbo binary'
complete -c turbo -n "__fish_turbo_needs_command" -a "completion" -d 'Generate the autocompletion script for the specified shell'
complete -c turbo -n "__fish_turbo_needs_command" -a "daemon" -d 'Runs the Turborepo background daemon'
complete -c turbo -n "__fish_turbo_needs_command" -a "generate" -d 'Generate a new app / package'
complete -c turbo -n "__fish_turbo_needs_command" -a "telemetry" -d 'Enable or disable anonymous telemetry'
complete -c turbo -n "__fish_turbo_needs_command" -a "scan" -d 'Turbo your monorepo by running a number of \'repo lints\' to identify common issues, suggest fixes, and improve performance'
complete -c turbo -n "__fish_turbo_needs_command" -a "config"
complete -c turbo -n "__fish_turbo_needs_command" -a "ls" -d 'EXPERIMENTAL: List packages in your monorepo'
complete -c turbo -n "__fish_turbo_needs_command" -a "link" -d 'Link your local directory to a Vercel organization and enable remote caching'
complete -c turbo -n "__fish_turbo_needs_command" -a "login" -d 'Login to your Vercel account'
complete -c turbo -n "__fish_turbo_needs_command" -a "logout" -d 'Logout to your Vercel account'
complete -c turbo -n "__fish_turbo_needs_command" -a "info" -d 'Print debugging information'
complete -c turbo -n "__fish_turbo_needs_command" -a "prune" -d 'Prepare a subset of your monorepo'
complete -c turbo -n "__fish_turbo_needs_command" -a "run" -d 'Run tasks across projects in your monorepo'
complete -c turbo -n "__fish_turbo_needs_command" -a "query" -d 'Query your monorepo using GraphQL. If no query is provided, spins up a GraphQL server with GraphiQL'
complete -c turbo -n "__fish_turbo_needs_command" -a "watch" -d 'Arguments used in run and watch'
complete -c turbo -n "__fish_turbo_needs_command" -a "unlink" -d 'Unlink the current directory from your Vercel organization and disable Remote Caching'
complete -c turbo -n "__fish_turbo_using_subcommand bin" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand bin" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand bin" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand bin" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand bin" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand bin" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand bin" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand bin" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand bin" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand bin" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand bin" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand bin" -l version
complete -c turbo -n "__fish_turbo_using_subcommand bin" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand bin" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand bin" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand bin" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand bin" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand bin" -s v
complete -c turbo -n "__fish_turbo_using_subcommand bin" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand bin" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand bin" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand bin" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand bin" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand completion" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand completion" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand completion" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand completion" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand completion" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand completion" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand completion" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand completion" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand completion" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand completion" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand completion" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand completion" -l version
complete -c turbo -n "__fish_turbo_using_subcommand completion" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand completion" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand completion" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand completion" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand completion" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand completion" -s v
complete -c turbo -n "__fish_turbo_using_subcommand completion" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand completion" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand completion" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand completion" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand completion" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -l idle-time -d 'Set the idle timeout for turbod' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -l version
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -s v
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -f -a "restart" -d 'Restarts the turbo daemon'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -f -a "start" -d 'Ensures that the turbo daemon is running'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -f -a "status" -d 'Reports the status of the turbo daemon'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -f -a "stop" -d 'Stops the turbo daemon'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -f -a "clean" -d 'Stops the turbo daemon if it is already running, and removes any stale daemon state'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and not __fish_seen_subcommand_from restart start status stop clean logs" -f -a "logs" -d 'Shows the daemon logs'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from restart" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from restart" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from restart" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from restart" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from restart" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from restart" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from restart" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from restart" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from restart" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from restart" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from restart" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from restart" -l version
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from restart" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from restart" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from restart" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from restart" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from restart" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from restart" -s v
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from restart" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from restart" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from restart" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from restart" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from restart" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from start" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from start" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from start" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from start" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from start" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from start" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from start" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from start" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from start" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from start" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from start" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from start" -l version
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from start" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from start" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from start" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from start" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from start" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from start" -s v
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from start" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from start" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from start" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from start" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from start" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -l json -d 'Pass --json to report status in JSON format'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -l version
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -s v
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from status" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from stop" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from stop" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from stop" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from stop" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from stop" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from stop" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from stop" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from stop" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from stop" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from stop" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from stop" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from stop" -l version
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from stop" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from stop" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from stop" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from stop" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from stop" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from stop" -s v
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from stop" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from stop" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from stop" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from stop" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from stop" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -l clean-logs -d 'Clean'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -l version
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -s v
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from clean" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from logs" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from logs" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from logs" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from logs" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from logs" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from logs" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from logs" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from logs" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from logs" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from logs" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from logs" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from logs" -l version
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from logs" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from logs" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from logs" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from logs" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from logs" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from logs" -s v
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from logs" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from logs" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from logs" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from logs" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand daemon; and __fish_seen_subcommand_from logs" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -l tag -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -s c -l config -d 'Generator configuration file' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -s r -l root -d 'The root of your repository (default: directory with root turbo.json)' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -s a -l args -d 'Answers passed directly to generator' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -l version
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -s v
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -a "workspace" -d 'Add a new package or app to your project'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and not __fish_seen_subcommand_from workspace run" -a "run"
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -s n -l name -d 'Name for the new workspace' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -s c -l copy -d 'Generate a workspace using an existing workspace as a template. Can be the name of a local workspace within your monorepo, or a fully qualified GitHub URL with any branch and/or subdirectory' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -s d -l destination -d 'Where the new workspace should be created' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -s t -l type -d 'The type of workspace to create' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -s r -l root -d 'The root of your repository (default: directory with root turbo.json)' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -s p -l example-path -d 'In a rare case, your GitHub URL might contain a branch name with a slash (e.g. bug/fix-1) and the path to the example (e.g. foo/bar). In this case, you must specify the path to the example separately: --example-path foo/bar' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -s b -l empty -d 'Generate an empty workspace'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -l show-all-dependencies -d 'Do not filter available dependencies by the workspace type'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -l version
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -s v
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from workspace" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -s c -l config -d 'Generator configuration file' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -s r -l root -d 'The root of your repository (default: directory with root turbo.json)' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -s a -l args -d 'Answers passed directly to generator' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -l version
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -s v
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand generate; and __fish_seen_subcommand_from run" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -l version
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -s v
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -f -a "enable" -d 'Enables anonymous telemetry'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -f -a "disable" -d 'Disables anonymous telemetry'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and not __fish_seen_subcommand_from enable disable status" -f -a "status" -d 'Reports the status of telemetry'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from enable" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from enable" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from enable" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from enable" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from enable" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from enable" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from enable" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from enable" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from enable" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from enable" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from enable" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from enable" -l version
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from enable" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from enable" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from enable" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from enable" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from enable" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from enable" -s v
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from enable" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from enable" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from enable" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from enable" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from enable" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from disable" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from disable" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from disable" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from disable" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from disable" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from disable" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from disable" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from disable" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from disable" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from disable" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from disable" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from disable" -l version
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from disable" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from disable" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from disable" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from disable" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from disable" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from disable" -s v
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from disable" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from disable" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from disable" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from disable" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from disable" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from status" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from status" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from status" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from status" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from status" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from status" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from status" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from status" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from status" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from status" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from status" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from status" -l version
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from status" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from status" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from status" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from status" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from status" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from status" -s v
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from status" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from status" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from status" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from status" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand telemetry; and __fish_seen_subcommand_from status" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand scan" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand scan" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand scan" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand scan" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand scan" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand scan" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand scan" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand scan" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand scan" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand scan" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand scan" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand scan" -l version
complete -c turbo -n "__fish_turbo_using_subcommand scan" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand scan" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand scan" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand scan" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand scan" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand scan" -s v
complete -c turbo -n "__fish_turbo_using_subcommand scan" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand scan" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand scan" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand scan" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand scan" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand config" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand config" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand config" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand config" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand config" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand config" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand config" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand config" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand config" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand config" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand config" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand config" -l version
complete -c turbo -n "__fish_turbo_using_subcommand config" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand config" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand config" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand config" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand config" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand config" -s v
complete -c turbo -n "__fish_turbo_using_subcommand config" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand config" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand config" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand config" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand config" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand ls" -s F -l filter -d 'Use the given selector to specify package(s) to act as entry points. The syntax mirrors pnpm\'s syntax, and additional documentation and examples can be found in turbo\'s documentation https://turbo.build/repo/docs/reference/command-line-reference/run#--filter' -r
complete -c turbo -n "__fish_turbo_using_subcommand ls" -l output -d 'Output format' -r -f -a "{pretty\t'Output in a human-readable format',json\t'Output in JSON format for direct parsing'}"
complete -c turbo -n "__fish_turbo_using_subcommand ls" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand ls" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand ls" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand ls" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand ls" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand ls" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand ls" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand ls" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand ls" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand ls" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand ls" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand ls" -l affected -d 'Show only packages that are affected by changes between the current branch and `main`'
complete -c turbo -n "__fish_turbo_using_subcommand ls" -l version
complete -c turbo -n "__fish_turbo_using_subcommand ls" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand ls" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand ls" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand ls" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand ls" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand ls" -s v
complete -c turbo -n "__fish_turbo_using_subcommand ls" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand ls" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand ls" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand ls" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand ls" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand link" -l target -d 'Specify what should be linked (default "remote cache")' -r -f -a "{remote-cache\t'',spaces\t''}"
complete -c turbo -n "__fish_turbo_using_subcommand link" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand link" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand link" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand link" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand link" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand link" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand link" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand link" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand link" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand link" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand link" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand link" -l no-gitignore -d 'Do not create or modify .gitignore (default false)'
complete -c turbo -n "__fish_turbo_using_subcommand link" -l version
complete -c turbo -n "__fish_turbo_using_subcommand link" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand link" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand link" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand link" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand link" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand link" -s v
complete -c turbo -n "__fish_turbo_using_subcommand link" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand link" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand link" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand link" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand link" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand login" -l sso-team -r
complete -c turbo -n "__fish_turbo_using_subcommand login" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand login" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand login" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand login" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand login" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand login" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand login" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand login" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand login" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand login" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand login" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand login" -s f -l force -d 'Force a login to receive a new token. Will overwrite any existing tokens for the given login url'
complete -c turbo -n "__fish_turbo_using_subcommand login" -l version
complete -c turbo -n "__fish_turbo_using_subcommand login" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand login" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand login" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand login" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand login" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand login" -s v
complete -c turbo -n "__fish_turbo_using_subcommand login" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand login" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand login" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand login" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand login" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand logout" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand logout" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand logout" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand logout" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand logout" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand logout" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand logout" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand logout" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand logout" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand logout" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand logout" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand logout" -l invalidate -d 'Invalidate the token on the server'
complete -c turbo -n "__fish_turbo_using_subcommand logout" -l version
complete -c turbo -n "__fish_turbo_using_subcommand logout" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand logout" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand logout" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand logout" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand logout" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand logout" -s v
complete -c turbo -n "__fish_turbo_using_subcommand logout" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand logout" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand logout" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand logout" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand logout" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand info" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand info" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand info" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand info" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand info" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand info" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand info" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand info" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand info" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand info" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand info" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand info" -l version
complete -c turbo -n "__fish_turbo_using_subcommand info" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand info" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand info" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand info" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand info" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand info" -s v
complete -c turbo -n "__fish_turbo_using_subcommand info" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand info" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand info" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand info" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand info" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l scope -r
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l out-dir -r
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l docker
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l version
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand prune" -s v
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand prune" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand prune" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand run" -l cache -d 'Set the cache behavior for this run. Pass a list of comma-separated key, value pairs to enable reading and writing to either the local or remote cache' -r
complete -c turbo -n "__fish_turbo_using_subcommand run" -l force -d 'Ignore the existing cache (to force execution). Equivalent to `--cache=local:w,remote:w`' -r -f -a "{true\t'',false\t''}"
complete -c turbo -n "__fish_turbo_using_subcommand run" -l remote-only -d 'Ignore the local filesystem cache for all tasks. Only allow reading and caching artifacts using the remote cache. Equivalent to `--cache=remote:rw`' -r -f -a "{true\t'',false\t''}"
complete -c turbo -n "__fish_turbo_using_subcommand run" -l remote-cache-read-only -d 'Treat remote cache as read only. Equivalent to `--cache=remote:r;local:rw`' -r -f -a "{true\t'',false\t''}"
complete -c turbo -n "__fish_turbo_using_subcommand run" -l cache-workers -d 'Set the number of concurrent cache operations (default 10)' -r
complete -c turbo -n "__fish_turbo_using_subcommand run" -l dry-run -r -f -a "{text\t'',json\t''}"
complete -c turbo -n "__fish_turbo_using_subcommand run" -l graph -d 'Generate a graph of the task execution and output to a file when a filename is specified (.svg, .png, .jpg, .pdf, .json, .html, .mermaid, .dot). Outputs dot graph to stdout when if no filename is provided' -r
complete -c turbo -n "__fish_turbo_using_subcommand run" -l profile -d 'File to write turbo\'s performance profile output into. You can load the file up in chrome://tracing to see which parts of your build were slow' -r
complete -c turbo -n "__fish_turbo_using_subcommand run" -l anon-profile -d 'File to write turbo\'s performance profile output into. All identifying data omitted from the profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand run" -l summarize -d 'Generate a summary of the turbo run' -r -f -a "{true\t'',false\t''}"
complete -c turbo -n "__fish_turbo_using_subcommand run" -l experimental-space-id -r
complete -c turbo -n "__fish_turbo_using_subcommand run" -l cache-dir -d 'Override the filesystem cache directory' -r
complete -c turbo -n "__fish_turbo_using_subcommand run" -l concurrency -d 'Limit the concurrency of task execution. Use 1 for serial (i.e. one-at-a-time) execution' -r
complete -c turbo -n "__fish_turbo_using_subcommand run" -l framework-inference -d 'Specify whether or not to do framework inference for tasks' -r -f -a "{true\t'',false\t''}"
complete -c turbo -n "__fish_turbo_using_subcommand run" -l global-deps -d 'Specify glob of global filesystem dependencies to be hashed. Useful for .env and files' -r
complete -c turbo -n "__fish_turbo_using_subcommand run" -l env-mode -d 'Environment variable mode. Use "loose" to pass the entire existing environment. Use "strict" to use an allowlist specified in turbo.json' -r -f -a "{loose\t'',strict\t''}"
complete -c turbo -n "__fish_turbo_using_subcommand run" -s F -l filter -d 'Use the given selector to specify package(s) to act as entry points. The syntax mirrors pnpm\'s syntax, and additional documentation and examples can be found in turbo\'s documentation https://turbo.build/repo/docs/reference/command-line-reference/run#--filter' -r
complete -c turbo -n "__fish_turbo_using_subcommand run" -l output-logs -d 'Set type of process output logging. Use "full" to show all output. Use "hash-only" to show only turbo-computed task hashes. Use "new-only" to show only new output with only hashes for cached tasks. Use "none" to hide process output. (default full)' -r -f -a "{full\t'',none\t'',hash-only\t'',new-only\t'',errors-only\t''}"
complete -c turbo -n "__fish_turbo_using_subcommand run" -l log-order -d 'Set type of task output order. Use "stream" to show output as soon as it is available. Use "grouped" to show output when a command has finished execution. Use "auto" to let turbo decide based on its own heuristics. (default auto)' -r -f -a "{auto\t'',stream\t'',grouped\t''}"
complete -c turbo -n "__fish_turbo_using_subcommand run" -l pkg-inference-root -r
complete -c turbo -n "__fish_turbo_using_subcommand run" -l log-prefix -d 'Use "none" to remove prefixes from task logs. Use "task" to get task id prefixing. Use "auto" to let turbo decide how to prefix the logs based on the execution environment. In most cases this will be the same as "task". Note that tasks running in parallel interleave their logs, so removing prefixes can make it difficult to associate logs with tasks. Use --log-order=grouped to prevent interleaving. (default auto)' -r -f -a "{auto\t'',none\t'',task\t''}"
complete -c turbo -n "__fish_turbo_using_subcommand run" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand run" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand run" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand run" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand run" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand run" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand run" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand run" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand run" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand run" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand run" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand run" -l no-cache -d 'Avoid saving task results to the cache. Useful for development/watch tasks. Equivalent to `--cache=local:r,remote:r`'
complete -c turbo -n "__fish_turbo_using_subcommand run" -l daemon -d 'Force turbo to use the local daemon. If unset turbo will use the default detection logic'
complete -c turbo -n "__fish_turbo_using_subcommand run" -l no-daemon -d 'Force turbo to not use the local daemon. If unset turbo will use the default detection logic'
complete -c turbo -n "__fish_turbo_using_subcommand run" -l parallel -d 'Execute all tasks in parallel'
complete -c turbo -n "__fish_turbo_using_subcommand run" -l continue -d 'Continue execution even if a task exits with an error or non-zero exit code. The default behavior is to bail'
complete -c turbo -n "__fish_turbo_using_subcommand run" -l single-package -d 'Run turbo in single-package mode'
complete -c turbo -n "__fish_turbo_using_subcommand run" -l affected -d 'Run only tasks that are affected by changes between the current branch and `main`'
complete -c turbo -n "__fish_turbo_using_subcommand run" -l only -d 'Only executes the tasks specified, does not execute parent tasks'
complete -c turbo -n "__fish_turbo_using_subcommand run" -l version
complete -c turbo -n "__fish_turbo_using_subcommand run" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand run" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand run" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand run" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand run" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand run" -s v
complete -c turbo -n "__fish_turbo_using_subcommand run" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand run" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand run" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand run" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand run" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand query" -s V -l variables -d 'Pass variables to the query via a JSON file' -r
complete -c turbo -n "__fish_turbo_using_subcommand query" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand query" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand query" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand query" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand query" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand query" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand query" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand query" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand query" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand query" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand query" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand query" -l version
complete -c turbo -n "__fish_turbo_using_subcommand query" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand query" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand query" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand query" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand query" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand query" -s v
complete -c turbo -n "__fish_turbo_using_subcommand query" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand query" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand query" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand query" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand query" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l cache-dir -d 'Override the filesystem cache directory' -r
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l concurrency -d 'Limit the concurrency of task execution. Use 1 for serial (i.e. one-at-a-time) execution' -r
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l framework-inference -d 'Specify whether or not to do framework inference for tasks' -r -f -a "{true\t'',false\t''}"
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l global-deps -d 'Specify glob of global filesystem dependencies to be hashed. Useful for .env and files' -r
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l env-mode -d 'Environment variable mode. Use "loose" to pass the entire existing environment. Use "strict" to use an allowlist specified in turbo.json' -r -f -a "{loose\t'',strict\t''}"
complete -c turbo -n "__fish_turbo_using_subcommand watch" -s F -l filter -d 'Use the given selector to specify package(s) to act as entry points. The syntax mirrors pnpm\'s syntax, and additional documentation and examples can be found in turbo\'s documentation https://turbo.build/repo/docs/reference/command-line-reference/run#--filter' -r
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l output-logs -d 'Set type of process output logging. Use "full" to show all output. Use "hash-only" to show only turbo-computed task hashes. Use "new-only" to show only new output with only hashes for cached tasks. Use "none" to hide process output. (default full)' -r -f -a "{full\t'',none\t'',hash-only\t'',new-only\t'',errors-only\t''}"
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l log-order -d 'Set type of task output order. Use "stream" to show output as soon as it is available. Use "grouped" to show output when a command has finished execution. Use "auto" to let turbo decide based on its own heuristics. (default auto)' -r -f -a "{auto\t'',stream\t'',grouped\t''}"
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l pkg-inference-root -r
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l log-prefix -d 'Use "none" to remove prefixes from task logs. Use "task" to get task id prefixing. Use "auto" to let turbo decide how to prefix the logs based on the execution environment. In most cases this will be the same as "task". Note that tasks running in parallel interleave their logs, so removing prefixes can make it difficult to associate logs with tasks. Use --log-order=grouped to prevent interleaving. (default auto)' -r -f -a "{auto\t'',none\t'',task\t''}"
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l continue -d 'Continue execution even if a task exits with an error or non-zero exit code. The default behavior is to bail'
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l single-package -d 'Run turbo in single-package mode'
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l affected -d 'Run only tasks that are affected by changes between the current branch and `main`'
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l only -d 'Only executes the tasks specified, does not execute parent tasks'
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l version
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand watch" -s v
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand watch" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand watch" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -l target -d 'Specify what should be unlinked (default "remote cache")' -r -f -a "{remote-cache\t'',spaces\t''}"
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -l api -d 'Override the endpoint for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -l cwd -d 'The directory in which to run turbo' -r
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -l heap -d 'Specify a file to save a pprof heap profile' -r
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -l ui -d 'Specify whether to use the streaming UI or TUI' -r -f -a "{tui\t'Use the terminal user interface',stream\t'Use the standard output stream',web\t'Use the web user interface (experimental)'}"
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -l login -d 'Override the login endpoint' -r
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -l remote-cache-timeout -d 'Set a timeout for all HTTP requests' -r
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -l team -d 'Set the team slug for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -l token -d 'Set the auth token for API calls' -r
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -l trace -d 'Specify a file to save a pprof trace' -r
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -l verbosity -d 'Verbosity level' -r
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -l root-turbo-json -d 'Use the `turbo.json` located at the provided path instead of one at the root of the repository' -r
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -l version
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -l skip-infer -d 'Skip any attempts to infer which version of Turbo the project is configured to use'
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -l no-update-notifier -d 'Disable the turbo update notification'
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -l color -d 'Force color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -l no-color -d 'Suppress color usage in the terminal'
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -l preflight -d 'When enabled, turbo will precede HTTP requests with an OPTIONS request for authorization'
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -s v
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -l check-for-update -d 'Force a check for a new version of turbo'
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -l __test-run
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -l dangerously-disable-package-manager-check -d 'Allow for missing `packageManager` in `package.json`'
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -l experimental-allow-no-turbo-json
complete -c turbo -n "__fish_turbo_using_subcommand unlink" -s h -l help -d 'Print help (see more with \'--help\')'
