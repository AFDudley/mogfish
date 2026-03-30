function __fish_complete_wnlctl
	set -q XDG_RUNTIME_DIR; and set RUNTIME_DIR "$XDG_RUNTIME_DIR"; or set RUNTIME_DIR /tmp
	for f in $RUNTIME_DIR/wnl_slot_*.sock
		set mtch (string match --regex ".*wnl_slot_(\d+).sock" $f)
		set sock (fuser $f 2> /dev/null | string split " " --no-empty)[1]
		set cmdline (cat /proc/$sock/cmdline | string split0)[3..]
		if string match --regex --quiet "^\d+\$" $cmdline[1]
			set cmdline (echo  "$cmdline[2..]")
		end
		if test -n $mtch[2]
			echo $mtch[2]\twnl: $cmdline
		end
	end
end

complete --command wnlctl --no-files --argument '(__fish_complete_wnlctl)' --condition "__fish_is_first_arg"
complete --command wnlctl --no-files
