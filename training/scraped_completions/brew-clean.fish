# 禁用默认的文件补全，因为我们只希望补全子命令
complete -c brew-clean -f

# 补全 deps 子命令
complete -c brew-clean -a deps -d "清理冗余 Deps 依赖包"

# 补全 taps 子命令
complete -c brew-clean -a taps -d "清理冗余 Tap 仓库"

# 补全帮助选项
complete -c brew-clean -s h -l help -d "显示帮助信息 Help"
