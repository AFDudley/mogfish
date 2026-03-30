complete -c mariadbd-safe -l no-defaults -d Don\'t\ read\ the\ system\ defaults\ file
complete -c mariadbd-safe -l dry-run -d Simulate\ the\ start\ to\ detect\ errors\ but\ don\'t\ start
complete -c mariadbd-safe -l no-auto-restart -d 'Exit after starting mysqld'
complete -c mariadbd-safe -l nowatch -d 'Exit after starting mysqld'
complete -c mariadbd-safe -l skip-kill-mysqld -d Don\'t\ try\ to\ kill\ stray\ mysqld\ processes
complete -c mariadbd-safe -l syslog -d Log\ messages\ to\ syslog\ with\ \'logger\'
complete -c mariadbd-safe -l skip-syslog -d 'Log messages to error log (default)'
complete -c mariadbd-safe -l flush-caches -d 'Flush and purge buffers/caches before'
complete -c mariadbd-safe -l numa-interleave -d 'Run mysqld with its memory interleaved'
