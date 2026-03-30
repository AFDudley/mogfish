set -q XDG_CONFIG_HOME || set -x XDG_CONFIG_HOME $HOME/.config
set -q fd2_notes_home || set -U fd2_notes_home ~/notes
set -q fd2_notes_default_insert_point || set -U fd2_notes_default_insert_point $FD_NOTES_HOME

bind \cn n2_fzf

set -l name (basename (status -f) .fish){_uninstall}

function $name --on-event $name
    bind --erase \cn
end

complete -f -c n2_create -s t -r -d 'title of the note'
complete -f -c n2_create -s g -d 'tags for the note'

complete -f -c n2_pcreate -s t -r -d 'title of the note'
complete -f -c n2_pcreate -s g -d 'tags for the note'

complete -c n2_edit -s f -r -d 'path of the note'

complete -f -c n2_find -s p -r -d 'search pattern'
complete -f -c n2_search -s p -r -d 'search pattern'
complete -f -c n2_search_and_edit -s p -r -d 'search pattern'
complete -c n2_get_file_relative_path -s p -r -d 'path to note'

complete -c n2_move -s f -r -d 'from basename'
complete -c n2_move -s t -r -d 'to basename'

functions -e fen
alias fen='n2_fzf'
