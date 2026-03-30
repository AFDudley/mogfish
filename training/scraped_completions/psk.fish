# pass completions from
#  https://git.zx2c4.com/password-store/tree/src/completion/pass.fish-completion
function __psk_pass_get_prefix
    if set -q PASSWORD_STORE_DIR
        realpath -- "$PASSWORD_STORE_DIR"
    else
        echo "$HOME/.password-store"
    end
end

function __psk_pass_print_entries
    set -l ext '.gpg'
    set -l prefix (__psk_pass_get_prefix)
    set -l matches $prefix/**$ext
    printf '%s\n' $matches | sed "s#$prefix/\(.*\)$ext#\1#"
end

set -l psk_subcommands login copy show list

complete -c psk -f

complete -c psk -s h -l help -d "Print help"
complete -c psk -s v -l version -d "Print version"

complete -c psk -n "not __fish_seen_subcommand_from $psk_subcommands" -a login -d 'Copy login and pass to the clipboard'
complete -c psk -n "not __fish_seen_subcommand_from $psk_subcommands" -a copy -d 'Copy value of key to the clipboard'
complete -c psk -n "not __fish_seen_subcommand_from $psk_subcommands" -a show -d 'Print value of key'
complete -c psk -n "not __fish_seen_subcommand_from $psk_subcommands" -a list -d 'List valid keys'

complete -c psk -f -n "__fish_seen_subcommand_from $psk_subcommands" -a "(__psk_pass_print_entries)"
