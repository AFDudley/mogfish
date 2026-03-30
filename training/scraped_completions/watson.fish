function __watson_arg_number -a number
    set -l cmd (commandline -opc)
    test (count $cmd) -eq $number
end

function __watson_arg_after -a number
    set -l cmd (commandline -opc)
    test (count $cmd) -gt $number
end

function __watson_arg_eq -a arg_num -a value
    set -l cmd (commandline -opc)
    test (count $cmd) -ge $arg_num; and test $value = $cmd[$arg_num]
end

complete -f -c watson -n '__fish_prog_needs_command' -l help -d 'show help message and exit'

complete -f -c watson -n '__fish_prog_needs_command' -a cancel -d 'Cancel the last call to the start command.'
complete -f -c watson -n '__fish_prog_needs_command' -a config -d 'Get and set configuration options.'
complete -f -c watson -n '__fish_prog_needs_command' -a edit -d 'Edit a frame.'
complete -f -c watson -n '__fish_prog_needs_command' -a frames -d 'Display the list of all frame IDs.'
complete -f -c watson -n '__fish_prog_needs_command' -a help -d 'Display help information'
complete -f -c watson -n '__fish_prog_needs_command' -a log -d 'Display each recorded session'
complete -f -c watson -n '__fish_prog_needs_command' -a merge -d 'Perform a merge of the existing frames'
complete -f -c watson -n '__fish_prog_needs_command' -a projects -d 'Display the list of all the existing projects'
complete -f -c watson -n '__fish_prog_needs_command' -a remove -d 'Remove a frame.'
complete -f -c watson -n '__fish_prog_needs_command' -a rename -d 'Rename a project or tag.'
complete -f -c watson -n '__fish_prog_needs_command' -a report -d 'Display a report of the time spent on each project.'
complete -f -c watson -n '__fish_prog_needs_command' -a restart -d 'Restart monitoring time'
complete -f -c watson -n '__fish_prog_needs_command' -a start -d 'Start monitoring time for the given project.'
complete -f -c watson -n '__fish_prog_needs_command' -a status -d 'Display when the current project was started.'
complete -f -c watson -n '__fish_prog_needs_command' -a stop -d 'Stop monitoring time for the current project.'
complete -f -c watson -n '__fish_prog_needs_command' -a sync -d 'Get the frames from the server and push the frames.'
complete -f -c watson -n '__fish_prog_needs_command' -a tags -d 'Display the list of all the tags.'

complete -f -c watson -n '__fish_prog_using_command start; and __watson_arg_number 2' -a '(watson projects)'
complete -f -c watson -n '__fish_prog_using_command start; and __watson_arg_after 2' -a '(watson tags | sed -e "s/^/+/")'

complete -f -c watson -n '__fish_prog_using_command rename; and __watson_arg_number 2' -a 'project tag'
complete -f -c watson -n '__fish_prog_using_command rename; and __watson_arg_number 3; and __watson_arg_eq 3 "project"' -a '(watson projects)'
complete -f -c watson -n '__fish_prog_using_command rename; and __watson_arg_number 3; and __watson_arg_eq 3 "tag"' -a '(watson tags)'
complete -f -c watson -n '__fish_prog_using_command rename; and __watson_arg_after 4'

complete -f -c watson -n '__fish_prog_using_command remove; and __watson_arg_number 2' -a '(watson frames)'
complete -f -c watson -n '__fish_prog_using_command remove; and __watson_arg_after 2'

complete -f -c watson -n '__fish_prog_using_command edit; and __watson_arg_number 2' -a '(watson frames)'
complete -f -c watson -n '__fish_prog_using_command edit; and __watson_arg_after 2'
