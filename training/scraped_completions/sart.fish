function __fish_sa_artisan_commands_with_descriptions
    begin
        sart list --raw 2>/dev/null
        or return
    end | grep -vE '^ ' | string replace -r '\s+' '\t'
end

function __fish_sa_artisan_commands
    __fish_sa_artisan_commands_with_descriptions | cut -f 1
end

complete -c sart -f -n 'test -f artisan; and __fish_use_subcommand' -a '(__fish_sa_artisan_commands_with_descriptions)'
complete -c sart -f -n 'test -f artisan; and __fish_seen_subcommand_from help' -a '(__fish_sa_artisan_commands)'

