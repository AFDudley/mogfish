# Completion for quickpkg

complete -c quickpkg -s h -l help -d 'Show this help message and exit'
complete -c quickpkg -l umask -d 'Umask used during package creation (default 0077)' -x
complete -c quickpkg -l ignore-default-opts -d 'Do not use QUICKPKG_DEFAULT_OPTS'
complete -c quickpkg -l include-config -d 'Include CONFIG_PROTECT files' -xa 'y n'
complete -c quickpkg -l include-unmodified-config -d 'Include unmodified CONFIG_PROTECT files' -xa 'y n'

# Package completion
complete -c quickpkg -f -a '(__gentoo_packages_installed)'
