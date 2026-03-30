function __fish_tfenv_needs_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'tfenv' ]
    return 0
  end
  return 1
end

function __fish_tfenv_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

complete -f -c tfenv -n '__fish_tfenv_needs_command' -a '(tfenv commands)'
for cmd in (tfenv commands)
  complete -f -c tfenv -n "__fish_tfenv_using_command $cmd" -a \
    "(tfenv completions (commandline -opc)[2..-1])"
end
