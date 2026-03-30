complete -c "simctl" -l "set" # global
complete -c "simctl" -l "profiles" # global
complete -f -c "simctl" -n "__fish_use_subcommand" -a "addmedia" -d "Add photos, live photos, videos, or contacts to the library of a device." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "appinfo" -d "Show information about an installed application." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "boot" -d "Boot a device or device pair." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "clone" -d "Clone an existing device." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "create" -d "Create a new device." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "delete" -d "Delete specified devices, unavailable devices, or all devices." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "diagnose" -d "Collect diagnostic information and logs." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "erase" -d "Erase a device's contents and settings." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "get_app_container" -d "Print the path of the installed app's container" # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "getenv" -d "Print an environment variable from a running device." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "help" -d "Prints the usage for a given subcommand." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "icloud_sync" -d "Trigger iCloud sync on a device." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "install" -d "Install an app on a device." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "install_app_data" -d "Install an xcappdata package to a device, replacing the current contents of the container." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "io" -d "Set up a device IO operation." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "keychain" -d "Manipulate a device's keychain" # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "launch" -d "Launch an application by identifier on a device." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "list" -d "List available devices, device types, runtimes, or device pairs." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "listapps" -d "Show the installed applications." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "location" -d "Control a device's simulated location" # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "logverbose" -d "enable or disable verbose logging for a device" # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "openurl" -d "Open a URL in a device." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "pair" -d "Create a new watch and phone pair." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "pair_activate" -d "Set a given pair as active." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "pbcopy" -d "Copy standard input onto the device pasteboard." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "pbpaste" -d "Print the contents of the device's pasteboard to standard output." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "pbsync" -d "Sync the pasteboard content from one pasteboard to another." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "personalization" -d "Provides utility when working with personalization manifests" # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "privacy" -d "Grant, revoke, or reset privacy and permissions" # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "push" -d "Send a simulated push notification" # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "rename" -d "Rename a device." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "runtime" -d "Perform operations on runtimes" # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "shutdown" -d "Shutdown a device." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "spawn" -d "Spawn a process by executing a given executable on a device." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "status_bar" -d "Set or clear status bar overrides" # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "terminate" -d "Terminate an application by identifier on a device." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "ui" -d "Get or Set UI options" # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "uninstall" -d "Uninstall an app from a device." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "unpair" -d "Unpair a watch and phone pair." # sub
complete -f -c "simctl" -n "__fish_use_subcommand" -a "upgrade" -d "Upgrade a device to a newer runtime." # sub
complete -c "simctl" -n "__fish_seen_subcommand_from 'addmedia'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'addmedia'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'appinfo'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'appinfo'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'boot'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'boot'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'clone'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'clone'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'create'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'create'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'delete'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'delete'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'diagnose'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'diagnose'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'erase'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'erase'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'get_app_container'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'get_app_container'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'getenv'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'getenv'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'help'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'help'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'icloud_sync'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'icloud_sync'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'install'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'install'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'install_app_data'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'install_app_data'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'keychain'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'keychain'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'launch'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'launch'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'list'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'list'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'listapps'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'listapps'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'location'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'location'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'logverbose'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'logverbose'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'openurl'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'openurl'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'pair'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'pair'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'pair_activate'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'pair_activate'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'pbcopy'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'pbcopy'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'pbpaste'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'pbpaste'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'pbsync'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'pbsync'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'personalization'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'personalization'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'privacy'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'privacy'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'push'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'push'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'rename'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'rename'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'runtime'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'runtime'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'shutdown'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'shutdown'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'spawn'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'spawn'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'terminate'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'terminate'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'ui'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'ui'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'uninstall'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'uninstall'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'unpair'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'unpair'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'upgrade'" -l "set" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'upgrade'" -l "profiles" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'diagnose'" -s "b" -d "Do NOT show the resulting archive in a Finder window upon completion." # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'diagnose'" -s "X" -d "Run all diagnostics with no timeout. It ignores the --timeout value if it is specified." # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'diagnose'" -l "timeout" -d "Specify a duration (in seconds) to wait for the log collection before timeout." # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'diagnose'" -l "output" -d "Specify the output directory. If not provided the temporary directory is used." # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'diagnose'" -l "no-archive" -d "Do not create an archive, leave the collected files uncompressed." # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'diagnose'" -l "all-logs" -d "Include all device logs, even for non-booted devices." # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'diagnose'" -l "data-container" -d "Include booted device(s) data directory. Warning: May include private information, app data containers, and increases the size of the archive! Default is NOT to collect the data container." # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'diagnose'" -l "udid" -d "Collect diagnostics only from the specified device. This option may be specified more than once to consider multiple devices. The --all-logs option causes all --udid options to be ignored." # global
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'get_app_container'" -a "app" -d "The .app bundle" # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'get_app_container'" -a "data" -d "The application's data container" # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'get_app_container'" -a "groups" -d "The App Group containers" # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'get_app_container'" -a "groupidentifier" -d "A specific App Group container" # sub
complete -c "simctl" -n "__fish_seen_subcommand_from 'io'" -l "poll" -d "Poll after enumeration." # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'io'" -l "codec" -d "Specifies the codec type. Default is \"hevc\"." -xa "h264 hevc" # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'io'" -l "display" -d "iOS: supports \"internal\" or \"external\". Default is \"internal\". tvOS: supports only \"external\". watchOS: supports only \"internal\". You may also specify a port by UUID." -xa "internal external" # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'io'" -l "mask" -d "For non-rectangular displays, handle the mask by policy." -xa "ignored alpha black" # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'io'" -l "force" -d "Force the output file to be written to, even if the file already exists." # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'io'" -l "type" -d "Can be \"png\", \"tiff\", \"bmp\", \"gif\", \"jpeg\". Default is png." -xa "png tiff bmp gif jpeg" # global
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'io'" -a "enumerate" -d "Lists all available IO ports and descriptor states." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'io'" -a "poll" -d "Polls all available IO ports for events." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'io'" -a "recordVideo" -d "Records the display to a QuickTime movie at the specified file or url." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'io'" -a "screenshot" -d "Saves a screenshot as a PNG to the specified file or url (use '-' for stdout)." # sub
complete -c "simctl" -n "__fish_seen_subcommand_from 'io enumerate'" -l "poll" -d "Poll after enumeration." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io enumerate'" -l "codec" -d "Specifies the codec type. Default is \"hevc\"." -xa "h264 hevc" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io enumerate'" -l "display" -d "iOS: supports \"internal\" or \"external\". Default is \"internal\". tvOS: supports only \"external\". watchOS: supports only \"internal\". You may also specify a port by UUID." -xa "internal external" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io enumerate'" -l "mask" -d "For non-rectangular displays, handle the mask by policy." -xa "ignored alpha black" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io enumerate'" -l "force" -d "Force the output file to be written to, even if the file already exists." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io enumerate'" -l "type" -d "Can be \"png\", \"tiff\", \"bmp\", \"gif\", \"jpeg\". Default is png." -xa "png tiff bmp gif jpeg" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io poll'" -l "poll" -d "Poll after enumeration." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io poll'" -l "codec" -d "Specifies the codec type. Default is \"hevc\"." -xa "h264 hevc" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io poll'" -l "display" -d "iOS: supports \"internal\" or \"external\". Default is \"internal\". tvOS: supports only \"external\". watchOS: supports only \"internal\". You may also specify a port by UUID." -xa "internal external" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io poll'" -l "mask" -d "For non-rectangular displays, handle the mask by policy." -xa "ignored alpha black" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io poll'" -l "force" -d "Force the output file to be written to, even if the file already exists." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io poll'" -l "type" -d "Can be \"png\", \"tiff\", \"bmp\", \"gif\", \"jpeg\". Default is png." -xa "png tiff bmp gif jpeg" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io recordVideo'" -l "poll" -d "Poll after enumeration." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io recordVideo'" -l "codec" -d "Specifies the codec type. Default is \"hevc\"." -xa "h264 hevc" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io recordVideo'" -l "display" -d "iOS: supports \"internal\" or \"external\". Default is \"internal\". tvOS: supports only \"external\". watchOS: supports only \"internal\". You may also specify a port by UUID." -xa "internal external" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io recordVideo'" -l "mask" -d "For non-rectangular displays, handle the mask by policy." -xa "ignored alpha black" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io recordVideo'" -l "force" -d "Force the output file to be written to, even if the file already exists." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io recordVideo'" -l "type" -d "Can be \"png\", \"tiff\", \"bmp\", \"gif\", \"jpeg\". Default is png." -xa "png tiff bmp gif jpeg" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io screenshot'" -l "poll" -d "Poll after enumeration." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io screenshot'" -l "codec" -d "Specifies the codec type. Default is \"hevc\"." -xa "h264 hevc" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io screenshot'" -l "display" -d "iOS: supports \"internal\" or \"external\". Default is \"internal\". tvOS: supports only \"external\". watchOS: supports only \"internal\". You may also specify a port by UUID." -xa "internal external" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io screenshot'" -l "mask" -d "For non-rectangular displays, handle the mask by policy." -xa "ignored alpha black" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io screenshot'" -l "force" -d "Force the output file to be written to, even if the file already exists." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'io screenshot'" -l "type" -d "Can be \"png\", \"tiff\", \"bmp\", \"gif\", \"jpeg\". Default is png." -xa "png tiff bmp gif jpeg" # subcommands flags
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'keychain'" -a "add-root-cert" -d "Add a certificate to the trusted root store." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'keychain'" -a "add-cert" -d "Add a certificate to the keychain." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'keychain'" -a "reset" -d "Reset the keychain." # sub
complete -c "simctl" -n "__fish_seen_subcommand_from 'launch'" -l "arch" -d "Specify an architecture (x86_64 or arm64) to use when spawning a universal binary.  Requires runtime version 26 or newer." -xa "x86_64 arm64" # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'launch'" -l "console" -d "Block and print the application's stdout and stderr to the current terminal. Signals received by simctl are passed through to the application. (Cannot be combined with --stdout or --stderr)" # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'launch'" -l "console-pty" -d "Block and print the application's stdout and stderr to the current terminal via a PTY. Signals received by simctl are passed through to the application. (Cannot be combined with --stdout or --stderr)" # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'launch'" -l "stdout" -d "Redirect the application's standard output to a file." # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'launch'" -l "stderr" -d "Redirect the application's standard error to a file." # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'launch'" -l "terminate-running-process" -d "Terminate any running copy of the application. Note: Log output is often directed to stderr, not stdout." # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'list'" -s "j" -l "json" -d "Print as JSON (optionally specify a file descriptor with --json-fd or file path with --json-output)" # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'list'" -l "json-fd" # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'list'" -l "json-output" # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'list'" -s "e" -l "no-escape-slashes" -d "Encode slashes without escapes in JSON output" # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'list'" -s "v" -d "More verbose output" # global
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'list'" -a "devices" -d "List only items of type devices." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'list'" -a "devicetypes" -d "List only items of type devicetypes." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'list'" -a "runtimes" -d "List only items of type runtimes." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'list'" -a "pairs" -d "List only items of type pairs." # sub
complete -c "simctl" -n "__fish_seen_subcommand_from 'list devices'" -s "j" -l "json" -d "Print as JSON (optionally specify a file descriptor with --json-fd or file path with --json-output)" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'list devices'" -l "json-fd" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'list devices'" -l "json-output" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'list devices'" -s "e" -l "no-escape-slashes" -d "Encode slashes without escapes in JSON output" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'list devices'" -s "v" -d "More verbose output" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'list devicetypes'" -s "j" -l "json" -d "Print as JSON (optionally specify a file descriptor with --json-fd or file path with --json-output)" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'list devicetypes'" -l "json-fd" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'list devicetypes'" -l "json-output" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'list devicetypes'" -s "e" -l "no-escape-slashes" -d "Encode slashes without escapes in JSON output" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'list devicetypes'" -s "v" -d "More verbose output" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'list runtimes'" -s "j" -l "json" -d "Print as JSON (optionally specify a file descriptor with --json-fd or file path with --json-output)" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'list runtimes'" -l "json-fd" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'list runtimes'" -l "json-output" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'list runtimes'" -s "e" -l "no-escape-slashes" -d "Encode slashes without escapes in JSON output" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'list runtimes'" -s "v" -d "More verbose output" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'list pairs'" -s "j" -l "json" -d "Print as JSON (optionally specify a file descriptor with --json-fd or file path with --json-output)" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'list pairs'" -l "json-fd" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'list pairs'" -l "json-output" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'list pairs'" -s "e" -l "no-escape-slashes" -d "Encode slashes without escapes in JSON output" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'list pairs'" -s "v" -d "More verbose output" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'location'" -l "speed" -d "Speed specifies how quickly to move between waypoints in meters per second. If not specified 20m/s is used." # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'location'" -l "distance" -d "Distance will issue an update every <meters> travelled without regard for the time between updates." # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'location'" -l "interval" -d "Interval will issue updates at fixed times without regard for how much the location moves between updates." # global
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'location'" -a "list" -d "List available simulation scenarios." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'location'" -a "clear" -d "Stop any running scenario and clear any simulated location." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'location'" -a "set" -d "Set the location to a specific latitude and longitude." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'location'" -a "run" -d "Run a simulated location scenario (use the list action to get a list of scenarios)." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'location'" -a "start" -d "Set the location to a series of waypoints specified as 'lat,lon' pairs, interpolating between them over time." # sub
complete -c "simctl" -n "__fish_seen_subcommand_from 'location list'" -l "speed" -d "Speed specifies how quickly to move between waypoints in meters per second. If not specified 20m/s is used." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'location list'" -l "distance" -d "Distance will issue an update every <meters> travelled without regard for the time between updates." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'location list'" -l "interval" -d "Interval will issue updates at fixed times without regard for how much the location moves between updates." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'location clear'" -l "speed" -d "Speed specifies how quickly to move between waypoints in meters per second. If not specified 20m/s is used." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'location clear'" -l "distance" -d "Distance will issue an update every <meters> travelled without regard for the time between updates." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'location clear'" -l "interval" -d "Interval will issue updates at fixed times without regard for how much the location moves between updates." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'location set'" -l "speed" -d "Speed specifies how quickly to move between waypoints in meters per second. If not specified 20m/s is used." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'location set'" -l "distance" -d "Distance will issue an update every <meters> travelled without regard for the time between updates." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'location set'" -l "interval" -d "Interval will issue updates at fixed times without regard for how much the location moves between updates." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'location run'" -l "speed" -d "Speed specifies how quickly to move between waypoints in meters per second. If not specified 20m/s is used." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'location run'" -l "distance" -d "Distance will issue an update every <meters> travelled without regard for the time between updates." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'location run'" -l "interval" -d "Interval will issue updates at fixed times without regard for how much the location moves between updates." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'location start'" -l "speed" -d "Speed specifies how quickly to move between waypoints in meters per second. If not specified 20m/s is used." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'location start'" -l "distance" -d "Distance will issue an update every <meters> travelled without regard for the time between updates." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'location start'" -l "interval" -d "Interval will issue updates at fixed times without regard for how much the location moves between updates." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'pbpaste'" -s "v" # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'pbsync'" -s "p" -d "causes simctl to use promise data for secondary types. simctl will continue to run to provide that promise data until something else replaces it on the pasteboard." # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'pbsync'" -s "v" # global
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'personalization'" -a "revoke-manifests" -d "Revokes personalization manifests requiring all runtime cryptex mounts to be re-personalized." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'privacy'" -a "grant" -d "Grant access without prompting. Requires bundle identifier." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'privacy'" -a "revoke" -d "Revoke access, denying all use of the service. Requires bundle identifier." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'privacy'" -a "reset" -d "Reset access, prompting on next use. Bundle identifier optional." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'runtime'" -a "add" -d "Add a runtime disk image to the secure storage area. The image will be staged, verified, and mounted. When possible the image file will be cloned so no additional disk space will be used. If stdout is a terminal and a copy is required then progress will be reported." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'runtime'" -a "delete" -d "Delete a simulator runtime from the secure storage area. If runtime is a disk image any booted simulators are shutdown and the disk is unmounted first. Use the alias 'all' to delete all images." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'runtime'" -a "verify" -d "Re-verify the signature of a given runtime." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'runtime'" -a "list" -d "List runtime disk images, optionally outputting JSON to stdout." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'runtime'" -a "matchlist" -d "List the SDK build to runtime build mapping rules for the selected Xcode. Preferred means the runtime was either bundled with Xcode, exactly matched your SDK version, or the downloadable index indicated a better match for your SDK. Manual overrides using 'match set' have the highest priority." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'runtime'" -a "matchset" -d "Override the SDK to runtime build mapping. This controls which build of a given runtime Xcode will prefer for building and running when using that SDK. If --sdkBuild is not specified it is assumed you mean the SDK build for the currently selected Xcode." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'runtime'" -a "dyld_shared_cacheupdate" -d "Update the dyld shared cache for the specified runtime. If the cache already exists, the process will immediately terminate with success unless --force was specified. If --force is specified, any existing cache will be deleted first." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'runtime'" -a "dyld_shared_cacheremove" -d "Remove the dyld shared cache for the specified runtime." # sub
complete -c "simctl" -n "__fish_seen_subcommand_from 'spawn'" -s "w" -l "wait-for-debugger" -d "Start the process suspended." # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'spawn'" -s "s" -l "standalone" -d "Use a NULL mach bootstrap port, meaning the process cannot connect to other services and does not require a booted device. (deprecated)" # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'spawn'" -s "a" -l "arch" -d "Specify an architecture (x86_64 or arm64) to use when spawning a universal binary." -xa "x86_64 arm64" # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar'" -l "time" -d "Set the date or time to a fixed value. If the string is a valid ISO date string it will also set the date on relevant devices." # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar'" -l "dataNetwork" -xa "hide wifi 3g 4g lte lte-a lte+ 5g 5g+ 5g-uwb 5g-uc" # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar'" -l "wifiMode" -xa "searching failed active" # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar'" -l "wifiBars" -xa "0 1 2 3" # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar'" -l "cellularMode" -xa "notSupported searching failed active" # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar'" -l "cellularBars" -xa "0 1 2 3 4" # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar'" -l "operatorName" -d "Set the cellular operator/carrier name. Use '' for the empty string." # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar'" -l "batteryState" -xa "charging charged discharging" # global
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar'" -l "batteryLevel" -xa "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100" # global
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'status_bar'" -a "list" -d "List existing overrides." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'status_bar'" -a "clear" -d "Clear all existing status bar overrides." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'status_bar'" -a "override" -d "Set status bar override values, according to specified flags." # sub
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar list'" -l "time" -d "Set the date or time to a fixed value. If the string is a valid ISO date string it will also set the date on relevant devices." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar list'" -l "dataNetwork" -xa "hide wifi 3g 4g lte lte-a lte+ 5g 5g+ 5g-uwb 5g-uc" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar list'" -l "wifiMode" -xa "searching failed active" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar list'" -l "wifiBars" -xa "0 1 2 3" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar list'" -l "cellularMode" -xa "notSupported searching failed active" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar list'" -l "cellularBars" -xa "0 1 2 3 4" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar list'" -l "operatorName" -d "Set the cellular operator/carrier name. Use '' for the empty string." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar list'" -l "batteryState" -xa "charging charged discharging" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar list'" -l "batteryLevel" -xa "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar clear'" -l "time" -d "Set the date or time to a fixed value. If the string is a valid ISO date string it will also set the date on relevant devices." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar clear'" -l "dataNetwork" -xa "hide wifi 3g 4g lte lte-a lte+ 5g 5g+ 5g-uwb 5g-uc" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar clear'" -l "wifiMode" -xa "searching failed active" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar clear'" -l "wifiBars" -xa "0 1 2 3" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar clear'" -l "cellularMode" -xa "notSupported searching failed active" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar clear'" -l "cellularBars" -xa "0 1 2 3 4" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar clear'" -l "operatorName" -d "Set the cellular operator/carrier name. Use '' for the empty string." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar clear'" -l "batteryState" -xa "charging charged discharging" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar clear'" -l "batteryLevel" -xa "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar override'" -l "time" -d "Set the date or time to a fixed value. If the string is a valid ISO date string it will also set the date on relevant devices." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar override'" -l "dataNetwork" -xa "hide wifi 3g 4g lte lte-a lte+ 5g 5g+ 5g-uwb 5g-uc" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar override'" -l "wifiMode" -xa "searching failed active" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar override'" -l "wifiBars" -xa "0 1 2 3" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar override'" -l "cellularMode" -xa "notSupported searching failed active" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar override'" -l "cellularBars" -xa "0 1 2 3 4" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar override'" -l "operatorName" -d "Set the cellular operator/carrier name. Use '' for the empty string." # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar override'" -l "batteryState" -xa "charging charged discharging" # subcommands flags
complete -c "simctl" -n "__fish_seen_subcommand_from 'status_bar override'" -l "batteryLevel" -xa "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100" # subcommands flags
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'ui'" -a "appearance" -d "Get or set the user interface appearance style. When invoked without arguments, prints the current appearance style." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'ui'" -a "increase_contrast" -d "Get or set the Increase Contrast mode. When invoked without arguments, prints whether Increase Contrast is enabled." # sub
complete -f -c "simctl" -n "__fish_seen_subcommand_from 'ui'" -a "content_size" -d "Get or set the preferred content size category. When invoked without arguments, prints the current preferred content size category." # sub