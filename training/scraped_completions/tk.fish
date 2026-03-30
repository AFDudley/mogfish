function __list_session
	tmux list-sessions -F "#{session_name}"
end


complete -c tk -f -a "(__list_session)"
