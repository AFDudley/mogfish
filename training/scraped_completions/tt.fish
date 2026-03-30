complete -c tt -f

complete -c tt -n "not __fish_seen_subcommand_from start stop pause resume status report" \
    -a "start" -d "Start a tracked session"
complete -c tt -n "not __fish_seen_subcommand_from start stop pause resume status report" \
    -a "stop" -d "Stop current session"
complete -c tt -n "not __fish_seen_subcommand_from start stop pause resume status report" \
    -a "pause" -d "Pause current session"
complete -c tt -n "not __fish_seen_subcommand_from start stop pause resume status report" \
    -a "resume" -d "Resume paused session"
complete -c tt -n "not __fish_seen_subcommand_from start stop pause resume status report" \
    -a "status" -d "Show session status"
complete -c tt -n "not __fish_seen_subcommand_from start stop pause resume status report" \
    -a "report" -d "Show daily report"

complete -c tt -n "__fish_seen_subcommand_from start report" \
    -a "(test -n \"\$TIME_TRACKER_DIR\"; and find \$TIME_TRACKER_DIR -name '*.md' -printf '%f\n' 2>/dev/null | sed 's/.md\$//' | sort -u)"
