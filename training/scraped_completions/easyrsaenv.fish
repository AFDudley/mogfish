function __fish_easyrsaenv_needs_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'easyrsaenv' ]
    return 0
  end
  return 1
end

function __fish_easyrsaenv_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

complete -f -c easyrsaenv -n '__fish_easyrsaenv_needs_command' -a '(easyrsaenv commands)'
for cmd in (easyrsaenv commands)
  complete -f -c easyrsaenv -n "__fish_easyrsaenv_using_command $cmd" -a \
    "(easyrsaenv completions (commandline -opc)[2..-1])"
end
