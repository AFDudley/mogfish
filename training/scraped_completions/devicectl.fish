complete -c "devicectl" -s "v" -l "verbose" -d "If given, provide more logging output than normal." # global
complete -c "devicectl" -s "q" -l "quiet" -d "If given, output will include only errors." # global
complete -c "devicectl" -s "t" -l "timeout" -d "The overall command timeout in seconds. If this limit is exceeded the command is abandoned as a failure." # global
complete -c "devicectl" -s "j" -l "json-output" -d "An optional path to write a JSON file with command results." # global
complete -c "devicectl" -s "l" -l "log-output" -d "An optional path to write all logging otherwise passed to stdout/stderr." # global
complete -c "devicectl" -l "version" -d "Show the version." # global
complete -c "devicectl" -s "h" -l "help" -d "Show help information." # global
complete -f -c "devicectl" -n "__fish_use_subcommand" -a "device" -d "Commands to interact with devices." # sub
complete -f -c "devicectl" -n "__fish_use_subcommand" -a "diagnose" -d "Gather diagnostic information for debugging or filing bug reports." # sub
complete -f -c "devicectl" -n "__fish_use_subcommand" -a "list" -d "List things that devicectl knows about." # sub
complete -f -c "devicectl" -n "__fish_use_subcommand" -a "manage" -d "Commands to change state between the system and devices, or between devices themselves." # sub
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device'" -s "v" -l "verbose" -d "If given, provide more logging output than normal." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device'" -s "q" -l "quiet" -d "If given, output will include only errors." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device'" -s "t" -l "timeout" -d "The overall command timeout in seconds. If this limit is exceeded the command is abandoned as a failure." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device'" -s "j" -l "json-output" -d "An optional path to write a JSON file with command results." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device'" -s "l" -l "log-output" -d "An optional path to write all logging otherwise passed to stdout/stderr." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'diagnose'" -s "v" -l "verbose" -d "If given, provide more logging output than normal." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'diagnose'" -s "q" -l "quiet" -d "If given, output will include only errors." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'diagnose'" -s "t" -l "timeout" -d "The overall command timeout in seconds. If this limit is exceeded the command is abandoned as a failure." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'diagnose'" -s "j" -l "json-output" -d "An optional path to write a JSON file with command results." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'diagnose'" -s "l" -l "log-output" -d "An optional path to write all logging otherwise passed to stdout/stderr." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'list'" -s "v" -l "verbose" -d "If given, provide more logging output than normal." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'list'" -s "q" -l "quiet" -d "If given, output will include only errors." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'list'" -s "t" -l "timeout" -d "The overall command timeout in seconds. If this limit is exceeded the command is abandoned as a failure." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'list'" -s "j" -l "json-output" -d "An optional path to write a JSON file with command results." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'list'" -s "l" -l "log-output" -d "An optional path to write all logging otherwise passed to stdout/stderr." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage'" -s "v" -l "verbose" -d "If given, provide more logging output than normal." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage'" -s "q" -l "quiet" -d "If given, output will include only errors." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage'" -s "t" -l "timeout" -d "The overall command timeout in seconds. If this limit is exceeded the command is abandoned as a failure." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage'" -s "j" -l "json-output" -d "An optional path to write a JSON file with command results." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage'" -s "l" -l "log-output" -d "An optional path to write all logging otherwise passed to stdout/stderr." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device'" -s "v" -l "verbose" -d "If given, provide more logging output than normal." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device'" -s "q" -l "quiet" -d "If given, output will include only errors." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device'" -s "t" -l "timeout" -d "The overall command timeout in seconds. If this limit is exceeded the command is abandoned as a failure." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device'" -s "j" -l "json-output" -d "An optional path to write a JSON file with command results." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device'" -s "l" -l "log-output" -d "An optional path to write all logging otherwise passed to stdout/stderr." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device'" -l "version" -d "Show the version." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device'" -s "h" -l "help" -d "Show help information." # global
complete -f -c "devicectl" -n "__fish_seen_subcommand_from 'device'" -a "copy" -d "Copy files." # sub
complete -f -c "devicectl" -n "__fish_seen_subcommand_from 'device'" -a "info" -d "Commands that provide information about a specific device" # sub
complete -f -c "devicectl" -n "__fish_seen_subcommand_from 'device'" -a "install" -d "Install content onto a device." # sub
complete -f -c "devicectl" -n "__fish_seen_subcommand_from 'device'" -a "notification" -d "Post and observe Darwin notifications on a device." # sub
complete -f -c "devicectl" -n "__fish_seen_subcommand_from 'device'" -a "orientation" -d "Control device orientation." # sub
complete -f -c "devicectl" -n "__fish_seen_subcommand_from 'device'" -a "process" -d "Interact with processes on devices." # sub
complete -f -c "devicectl" -n "__fish_seen_subcommand_from 'device'" -a "reboot" -d "Reboot a device." # sub
complete -f -c "devicectl" -n "__fish_seen_subcommand_from 'device'" -a "uninstall" -d "Uninstall content from a device." # sub
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device copy'" -s "v" -l "verbose" -d "If given, provide more logging output than normal." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device copy'" -s "q" -l "quiet" -d "If given, output will include only errors." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device copy'" -s "t" -l "timeout" -d "The overall command timeout in seconds. If this limit is exceeded the command is abandoned as a failure." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device copy'" -s "j" -l "json-output" -d "An optional path to write a JSON file with command results." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device copy'" -s "l" -l "log-output" -d "An optional path to write all logging otherwise passed to stdout/stderr." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device info'" -s "v" -l "verbose" -d "If given, provide more logging output than normal." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device info'" -s "q" -l "quiet" -d "If given, output will include only errors." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device info'" -s "t" -l "timeout" -d "The overall command timeout in seconds. If this limit is exceeded the command is abandoned as a failure." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device info'" -s "j" -l "json-output" -d "An optional path to write a JSON file with command results." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device info'" -s "l" -l "log-output" -d "An optional path to write all logging otherwise passed to stdout/stderr." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device install'" -s "v" -l "verbose" -d "If given, provide more logging output than normal." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device install'" -s "q" -l "quiet" -d "If given, output will include only errors." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device install'" -s "t" -l "timeout" -d "The overall command timeout in seconds. If this limit is exceeded the command is abandoned as a failure." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device install'" -s "j" -l "json-output" -d "An optional path to write a JSON file with command results." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device install'" -s "l" -l "log-output" -d "An optional path to write all logging otherwise passed to stdout/stderr." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device notification'" -s "v" -l "verbose" -d "If given, provide more logging output than normal." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device notification'" -s "q" -l "quiet" -d "If given, output will include only errors." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device notification'" -s "t" -l "timeout" -d "The overall command timeout in seconds. If this limit is exceeded the command is abandoned as a failure." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device notification'" -s "j" -l "json-output" -d "An optional path to write a JSON file with command results." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device notification'" -s "l" -l "log-output" -d "An optional path to write all logging otherwise passed to stdout/stderr." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device orientation'" -s "v" -l "verbose" -d "If given, provide more logging output than normal." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device orientation'" -s "q" -l "quiet" -d "If given, output will include only errors." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device orientation'" -s "t" -l "timeout" -d "The overall command timeout in seconds. If this limit is exceeded the command is abandoned as a failure." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device orientation'" -s "j" -l "json-output" -d "An optional path to write a JSON file with command results." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device orientation'" -s "l" -l "log-output" -d "An optional path to write all logging otherwise passed to stdout/stderr." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device process'" -s "v" -l "verbose" -d "If given, provide more logging output than normal." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device process'" -s "q" -l "quiet" -d "If given, output will include only errors." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device process'" -s "t" -l "timeout" -d "The overall command timeout in seconds. If this limit is exceeded the command is abandoned as a failure." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device process'" -s "j" -l "json-output" -d "An optional path to write a JSON file with command results." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device process'" -s "l" -l "log-output" -d "An optional path to write all logging otherwise passed to stdout/stderr." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device reboot'" -s "v" -l "verbose" -d "If given, provide more logging output than normal." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device reboot'" -s "q" -l "quiet" -d "If given, output will include only errors." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device reboot'" -s "t" -l "timeout" -d "The overall command timeout in seconds. If this limit is exceeded the command is abandoned as a failure." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device reboot'" -s "j" -l "json-output" -d "An optional path to write a JSON file with command results." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device reboot'" -s "l" -l "log-output" -d "An optional path to write all logging otherwise passed to stdout/stderr." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device uninstall'" -s "v" -l "verbose" -d "If given, provide more logging output than normal." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device uninstall'" -s "q" -l "quiet" -d "If given, output will include only errors." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device uninstall'" -s "t" -l "timeout" -d "The overall command timeout in seconds. If this limit is exceeded the command is abandoned as a failure." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device uninstall'" -s "j" -l "json-output" -d "An optional path to write a JSON file with command results." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'device uninstall'" -s "l" -l "log-output" -d "An optional path to write all logging otherwise passed to stdout/stderr." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'diagnose'" -s "d" -l "devices" -d "The identifiers, ECIDs, UDIDs, or names of the devices. If not specified, all known devices are used." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'diagnose'" -s "b" -l "finder" -d "Do not show the resulting archive in Finder upon completion. Default is to show the archive in Finder if the current user is controlling the Aqua console session." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'diagnose'" -l "no-finder" -d "Do not show the resulting archive in Finder upon completion. Default is to show the archive in Finder if the current user is controlling the Aqua console session." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'diagnose'" -s "k" -l "keep-temp-dir" -d "Keep the temporary directory after archiving. Default is to delete the directory once the archive has been created." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'diagnose'" -s "a" -l "archive-destination" -d "The path for the final ZIP archive. By default the archive is placed at '/tmp/devicectl_diagnose_<timestamp>.zip'. This is ignored if --createRadar is passed in (since no archive is created)." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'diagnose'" -l "archive" -d "Do not create an archive, leave the collected files uncompressed." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'diagnose'" -l "no-archive" -d "Do not create an archive, leave the collected files uncompressed." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'diagnose'" -l "include-host-sysdiagnose" -d "When running the command, include the host sysdiagnose collection, which may increase diagnostics collection time." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'diagnose'" -l "no-include-host-sysdiagnose" -d "When running the command, include the host sysdiagnose collection, which may increase diagnostics collection time." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'diagnose'" -s "v" -l "verbose" -d "If given, provide more logging output than normal." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'diagnose'" -s "q" -l "quiet" -d "If given, output will include only errors." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'diagnose'" -s "t" -l "timeout" -d "The overall command timeout in seconds. If this limit is exceeded the command is abandoned as a failure." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'diagnose'" -s "j" -l "json-output" -d "An optional path to write a JSON file with command results." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'diagnose'" -s "l" -l "log-output" -d "An optional path to write all logging otherwise passed to stdout/stderr." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'diagnose'" -l "version" -d "Show the version." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'diagnose'" -s "h" -l "help" -d "Show help information." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'list'" -s "v" -l "verbose" -d "If given, provide more logging output than normal." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'list'" -s "q" -l "quiet" -d "If given, output will include only errors." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'list'" -s "t" -l "timeout" -d "The overall command timeout in seconds. If this limit is exceeded the command is abandoned as a failure." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'list'" -s "j" -l "json-output" -d "An optional path to write a JSON file with command results." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'list'" -s "l" -l "log-output" -d "An optional path to write all logging otherwise passed to stdout/stderr." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'list'" -l "version" -d "Show the version." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'list'" -s "h" -l "help" -d "Show help information." # global
complete -f -c "devicectl" -n "__fish_seen_subcommand_from 'list'" -a "devices" -d "Lists devices that CoreDevice knows about" # sub
complete -f -c "devicectl" -n "__fish_seen_subcommand_from 'list'" -a "preferredDDI" -d "List the DDI that CoreDevice will use for a given platform." # sub
complete -c "devicectl" -n "__fish_seen_subcommand_from 'list devices'" -s "v" -l "verbose" -d "If given, provide more logging output than normal." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'list devices'" -s "q" -l "quiet" -d "If given, output will include only errors." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'list devices'" -s "t" -l "timeout" -d "The overall command timeout in seconds. If this limit is exceeded the command is abandoned as a failure." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'list devices'" -s "j" -l "json-output" -d "An optional path to write a JSON file with command results." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'list devices'" -s "l" -l "log-output" -d "An optional path to write all logging otherwise passed to stdout/stderr." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'list preferredDDI'" -s "v" -l "verbose" -d "If given, provide more logging output than normal." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'list preferredDDI'" -s "q" -l "quiet" -d "If given, output will include only errors." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'list preferredDDI'" -s "t" -l "timeout" -d "The overall command timeout in seconds. If this limit is exceeded the command is abandoned as a failure." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'list preferredDDI'" -s "j" -l "json-output" -d "An optional path to write a JSON file with command results." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'list preferredDDI'" -s "l" -l "log-output" -d "An optional path to write all logging otherwise passed to stdout/stderr." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage'" -s "v" -l "verbose" -d "If given, provide more logging output than normal." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage'" -s "q" -l "quiet" -d "If given, output will include only errors." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage'" -s "t" -l "timeout" -d "The overall command timeout in seconds. If this limit is exceeded the command is abandoned as a failure." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage'" -s "j" -l "json-output" -d "An optional path to write a JSON file with command results." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage'" -s "l" -l "log-output" -d "An optional path to write all logging otherwise passed to stdout/stderr." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage'" -l "version" -d "Show the version." # global
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage'" -s "h" -l "help" -d "Show help information." # global
complete -f -c "devicectl" -n "__fish_seen_subcommand_from 'manage'" -a "ddis" -d "Commands used to manage the set of developer disk images present on the host." # sub
complete -f -c "devicectl" -n "__fish_seen_subcommand_from 'manage'" -a "loggingProfile" -d "Commands used to manage the Core Device logging profile." # sub
complete -f -c "devicectl" -n "__fish_seen_subcommand_from 'manage'" -a "pair" -d "Pair with a given device." # sub
complete -f -c "devicectl" -n "__fish_seen_subcommand_from 'manage'" -a "unpair" -d "Unpair a manually paired device." # sub
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage ddis'" -s "v" -l "verbose" -d "If given, provide more logging output than normal." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage ddis'" -s "q" -l "quiet" -d "If given, output will include only errors." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage ddis'" -s "t" -l "timeout" -d "The overall command timeout in seconds. If this limit is exceeded the command is abandoned as a failure." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage ddis'" -s "j" -l "json-output" -d "An optional path to write a JSON file with command results." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage ddis'" -s "l" -l "log-output" -d "An optional path to write all logging otherwise passed to stdout/stderr." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage loggingProfile'" -s "v" -l "verbose" -d "If given, provide more logging output than normal." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage loggingProfile'" -s "q" -l "quiet" -d "If given, output will include only errors." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage loggingProfile'" -s "t" -l "timeout" -d "The overall command timeout in seconds. If this limit is exceeded the command is abandoned as a failure." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage loggingProfile'" -s "j" -l "json-output" -d "An optional path to write a JSON file with command results." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage loggingProfile'" -s "l" -l "log-output" -d "An optional path to write all logging otherwise passed to stdout/stderr." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage pair'" -s "v" -l "verbose" -d "If given, provide more logging output than normal." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage pair'" -s "q" -l "quiet" -d "If given, output will include only errors." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage pair'" -s "t" -l "timeout" -d "The overall command timeout in seconds. If this limit is exceeded the command is abandoned as a failure." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage pair'" -s "j" -l "json-output" -d "An optional path to write a JSON file with command results." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage pair'" -s "l" -l "log-output" -d "An optional path to write all logging otherwise passed to stdout/stderr." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage unpair'" -s "v" -l "verbose" -d "If given, provide more logging output than normal." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage unpair'" -s "q" -l "quiet" -d "If given, output will include only errors." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage unpair'" -s "t" -l "timeout" -d "The overall command timeout in seconds. If this limit is exceeded the command is abandoned as a failure." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage unpair'" -s "j" -l "json-output" -d "An optional path to write a JSON file with command results." # subcommands flags
complete -c "devicectl" -n "__fish_seen_subcommand_from 'manage unpair'" -s "l" -l "log-output" -d "An optional path to write all logging otherwise passed to stdout/stderr." # subcommands flags