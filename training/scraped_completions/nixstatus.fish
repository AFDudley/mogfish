# Completions for nixstatus command
complete -c nixstatus -f

# Options
complete -c nixstatus -l packages -s p -d "Show installed packages"
complete -c nixstatus -l services -s s -d "Show running services"
complete -c nixstatus -l all -s a -d "Show everything"
complete -c nixstatus -l help -s h -d "Show help message"