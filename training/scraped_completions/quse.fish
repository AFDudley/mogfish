# Completion for quse (portage-utils)
# Find pkgs using USE flags

# Common options
complete -c quse -l root -d 'Set the ROOT env var' -r -F
complete -c quse -s v -l verbose -d 'Make a lot of noise'
complete -c quse -s q -l quiet -d 'Tighter output; suppress warnings'
complete -c quse -s C -l nocolor -d 'Do not output color'
complete -c quse -s h -l help -d 'Print this help and exit'
complete -c quse -s V -l version -d 'Print version and exit'

# quse specific options
complete -c quse -s e -l exact -d 'Show exact non regexp matching using strcmp'
complete -c quse -s a -l all -d "List all ebuilds, don't match anything"
complete -c quse -s L -l license -d 'Use the LICENSE vs IUSE'
complete -c quse -s D -l describe -d 'Describe the USE flag'
complete -c quse -s I -l installed -d 'Only search installed packages'
complete -c quse -s p -l package -d 'Restrict matching to package or category' -x
complete -c quse -s R -l repo -d 'Show repository the ebuild originates from'
complete -c quse -s F -l format -d 'Print matched atom using given format string' -x

# USE flag completion (when not using -p option)
complete -c quse -n 'not __fish_seen_subcommand_from -p --package' -f -a '(__gentoo_packages_useflag)'

# Package name completion (for -p option)
complete -c quse -n '__fish_seen_subcommand_from -p --package' -f -a '(__gentoo_packages_available)'
