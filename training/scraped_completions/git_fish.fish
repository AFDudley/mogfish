function __git_fish_install --on-event git_fish_install
  set -l complet_filepath $HOME/.config/fish/completions/git_fish.fish
  set -l url "https://raw.githubusercontent.com/fish-shell/fish-shell/master/share/completions/git.fish"
  if not test -e $complet_filepath
    curl -s $url | sed -E 's/(complete.*) git (.+)/\1 git_fish \2/g' > $complet_filepath
    echo "complete -f -c git_fish -n '__fish_use_subcommand' -a 'cd'     -d 'Change git directory'" >> $complet_filepath
    echo "complete -f -c git_fish -n '__fish_use_subcommand' -a 'erase'  -d 'Erase branches'"       >> $complet_filepath
    echo "complete -f -c git_fish -n '__fish_use_subcommand' -a 'select' -d 'Select branch'"        >> $complet_filepath
  end
end

function __git_fish_update --on-event git_fish_update
  __git_fish_install
end

function __git_fish_uninstall --on-event git_fish_uninstall
  set -l complet_filepath $HOME/.config/fish/completions/git_fish.fish
  if test -e $complet_filepath
    rm -f $complet_filepath
  end
end
