complete -c ncmd
complete -c ncmd --exclusive --long version -d "print version"
complete -c ncmd --exclusive --long help -d "print help"

# tidy
complete -c ncmd --exclusive --condition __fish_use_subcommand -a tidy -d "delete trash files and dirs"
# rename
complete -c ncmd --condition __fish_use_subcommand -a rename -d "rename files in dir"
# config
complete -c ncmd --exclusive --condition __fish_use_subcommand -a config -d "generate index.md in hexo theme"
# txtfmt
complete -c ncmd --condition __fish_use_subcommand -a txtfmt -d "format txt to markdown"
# shell
complete -c ncmd --condition __fish_use_subcommand -a shell -d "shell tools"
complete -c ncmd -n "__fish_seen_subcommand_from shell" -a dir-index -d "add index for dir"
complete -c ncmd -n "__fish_seen_subcommand_from shell" -a dir-next -d "change current dir"
complete -c ncmd -n "__fish_seen_subcommand_from shell" -a dir-sort -d "rename dirs"
complete -c ncmd -n "__fish_seen_subcommand_from shell" -a file-mark -d "mark file"
complete -c ncmd -n "__fish_seen_subcommand_from shell" -a file-md -d "create md"
complete -c ncmd -n "__fish_seen_subcommand_from shell" -a file-suffix -d "change suffix"
# image
complete -c ncmd --condition __fish_use_subcommand -a image -d "image tools"
complete -c ncmd -n "__fish_seen_subcommand_from image" -a convert -d "convert to jpg"
complete -c ncmd -n "__fish_seen_subcommand_from image" -a optimize -d "op image"
# video
complete -c ncmd --condition __fish_use_subcommand -a video -d "video tools"
complete -c ncmd -n "__fish_seen_subcommand_from video" -a convert -d "convert to mp4"
complete -c ncmd -n "__fish_seen_subcommand_from video" -a crop -d "crop video"
