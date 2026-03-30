function __g4d_complete
  cd . ^ /dev/null; or cd
  /usr/bin/p4 tabcomplete --token=2 p4 g4d
end

complete -x -c g4d -a '(__g4d_complete)'
