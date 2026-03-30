set -l themes (jink --list-themes)
set -l langs (jink --list-langs)
complete -c jink -s h -l help -d 'Show this help message'
complete -c jink -s t -l theme -d 'Theme name (default: vitesse-dark)' -x -a "$themes"
complete -c jink -s l -l lang -d 'Language name (default: autodetect)' -x -a "$langs"
complete -c jink -l list-themes -d 'List available themes'
complete -c jink -l list-langs -d 'List available languages'
