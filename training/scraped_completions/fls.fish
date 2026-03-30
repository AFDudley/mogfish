## Completions for fls
# Flags
complete -c fls -s h -l help    -d 'Show help and exit'
complete -c fls -s a -l all     -d 'Include internal helper names'
complete -c fls -s b -l builtin -d 'Only functions from system paths'
complete -c fls -s u -l user    -d 'Only functions from user paths'
complete -c fls -s p -l paths   -d 'Show source file path'
complete -c fls -s d -l doc     -d 'Show leading documentation comments'
complete -c fls -s 1 -l names   -d 'Print names only'
complete -c fls -s g -l grep    -d 'Filter by TEXT in name or description' -r
complete -c fls -s l -l long    -d 'Extended details (implies --paths)'

# Positional PATTERN: suggest function names (hide internals by default)
complete -c fls -n 'not __fish_seen_argument -s g -l grep' \
  -a '(functions -n | string match -rv "^(__|_)")' \
  -d 'Function name'
