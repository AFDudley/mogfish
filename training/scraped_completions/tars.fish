function get_tars_completions
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 ]
    cat $HOME/.cache/tars/completion/commands
    return
  end

  if [ (count $cmd) -gt 2 ]
    return
  end

  set tars_command $cmd[2]
  switch $tars_command
    case service hostlist ssh p_exec
      set completion_source services
    case database
      set completion_source databases
    case stq
      set completion_source stq_queues
    case grafana
      set completion_source grafana
    case config
      set completion_source config_v1
    case handler
      set completion_source handler
    case '*'
      return
  end

  set current_word (commandline -ct)
  set regex_pattern (eval echo $current_word | sed 's/\(.\)/\1.*/g')

  grep -i $regex_pattern $HOME/.cache/tars/completion/$completion_source
end

complete -c tars --force-files --condition '__fish_seen_subcommand_from logs-sanitizer'
complete -c tars --no-files -a '(get_tars_completions)'
