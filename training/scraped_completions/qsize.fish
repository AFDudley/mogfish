# Completion for qsize (portage-utils)
# Calculate size usage

# Common options
complete -c qsize -l root -d 'Set the ROOT env var' -r -F
complete -c qsize -s v -l verbose -d 'Make a lot of noise'
complete -c qsize -s q -l quiet -d 'Tighter output; suppress warnings'
complete -c qsize -s C -l nocolor -d 'Do not output color'
complete -c qsize -s h -l help -d 'Print this help and exit'
complete -c qsize -s V -l version -d 'Print version and exit'

# qsize specific options
complete -c qsize -s f -l filesystem -d 'Show size used on disk'
complete -c qsize -s s -l sum -d 'Include a summary'
complete -c qsize -s S -l sum-only -d 'Show just the summary'
complete -c qsize -s m -l megabytes -d 'Display size in megabytes'
complete -c qsize -s k -l kilobytes -d 'Display size in kilobytes'
complete -c qsize -s b -l bytes -d 'Display size in bytes'
complete -c qsize -s i -l ignore -d 'Ignore regexp string' -x
complete -c qsize -s F -l format -d 'Print matched atom using given format string' -x

# Package name completion
complete -c qsize -f -a '(__gentoo_packages_installed)'
