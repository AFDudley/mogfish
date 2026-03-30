complete -c tldr -s u -l update -d "Update the cache" # global
complete -c tldr -s l -l list -d "List all pages in the current platform" # global
complete -c tldr -s a -l list-all -d "List all pages" # global
complete -c tldr -l list-platforms -d "List available platforms" # global
complete -c tldr -l list-languages -d "List installed languages" # global
complete -c tldr -s i -l info -d "Show cache information (path, age, installed languages and the number of pages)" # global
complete -c tldr -s r -l render -d "Render the specified markdown file" # global
complete -c tldr -l clean-cache -d "Clean the cache" # global
complete -c tldr -l gen-config -d "Print the default config" # global
complete -c tldr -l config-path -d "Print the default config path and create the config directory" # global
complete -c tldr -s p -l platform -d "Specify the platform to use" -xa "linux osx windows" # global
complete -c tldr -s L -l language -d "Specify the languages to use" # global
complete -c tldr -l short-options -d "Display short options wherever possible (e.g. '-s')" # global
complete -c tldr -l long-options -d "Display long options wherever possible (e.g. '--long')" # global
complete -c tldr -s o -l offline -d "Do not update the cache, even if it is stale" # global
complete -c tldr -s c -l compact -d "Strip empty lines from output" # global
complete -c tldr -l no-compact -d "Do not strip empty lines from output (overrides --compact)" # global
complete -c tldr -s R -l raw -d "Print pages in raw markdown instead of rendering them" # global
complete -c tldr -l no-raw -d "Render pages instead of printing raw file contents (overrides --raw)" # global
complete -c tldr -s q -l quiet -d "Suppress status messages and warnings" # global
complete -c tldr -l color -d "Specify when to enable color" -xa "auto always never" # global
complete -c tldr -l config -d "Specify an alternative path to the config file" # global
complete -c tldr -s v -l version -d "Print version" # global
complete -c tldr -s h -l help -d "Print help"
complete -c tldr --condition __fish_no_subcommands -x -a '(tldr --list)'
