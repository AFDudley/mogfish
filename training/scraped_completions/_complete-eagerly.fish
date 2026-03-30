status is-interactive; or return
#
# function _complete-eagerly_install --on-event _complete-eagerly_install
#
#     # Set universal variables, create bindings, and other initialization logic.
# end
#
# function _complete-eagerly_update --on-event _complete-eagerly_update
# 	# Migrate resources, print warnings, and other update logic.
# end
#
# function _complete-eagerly_uninstall --on-event _complete-eagerly_uninstall
# 	# Erase "private" functions, variables, bindings, and other uninstall logic.
# end

# commandline --function accept-autosuggestion
# commandline --function expand-abbr
# commandline --function complete
# commandline --function complete-and-search
# commandline --function suppress-autosuggestion

# commandline --is-valid # Return true if the current commandline is syntactically valid and complete.
# commandline --paging-mode
# commandline --paging-full-mode
# commandline --search-mode

# TODO: <kpbaks 2023-09-05 22:54:00> make smarter
function __complete-eagerly.fish::space
    set -l buffer (commandline)
    # set -l before (commandline --cut-at-cursor)
    # NOTE: " " is normally used to expand abbreviations, so we need to
    # do it, otherwise the users abbreviation will not work.
    commandline --function expand-abbr
    commandline --insert " "
    if test (string trim -- $buffer) = ""
        # Do not want to complete if the user has not typed anything yet.
        return
    end
    commandline --is-valid; or return
    # set -l tokens (commandline --tokenize)
    # set -l prog $tokens[1]
    # type --query $prog; or return
    commandline --function complete
    # commandline --function complete-and-search
    set -l buffer_after (commandline)
    test $buffer = $buffer_after; and return
    # commandline --function accept-autosuggestion
    # commandline --function suppress-autosuggestion
end

function __complete-eagerly.fish::hyphen
    set -l buffer (commandline)
    set -l before (commandline --cut-at-cursor)
    commandline --insert -
    if test (string trim -- $buffer) = ""
        # Do not want to complete if the user has not typed anything yet.
        return
    end
    commandline --is-valid; or return
    set -l character_before_cursor (string sub --start=-1 $before)
    if test $character_before_cursor = -
        # we now have "--" in the buffer, so we want to complete long options
    end

    commandline --function complete
end

function __complete-eagerly.fish::dollar
    set -l buffer (commandline)
    commandline --insert \$
    if test (string trim -- $buffer) = ""
        # Do not want to complete if the user has not typed anything yet.
        return
    end

    commandline --function complete
end


function __complete-eagerly.fish::slash
    set -l buffer (commandline)
    # TODO: <kpbaks 2023-09-07 21:34:53> check if the path being written exists
    # TODO: <kpbaks 2023-09-07 21:36:19> check how many files/directories are in the folder
    # TODO: <kpbaks 2023-09-07 21:36:19> if there are more than 1, then do not complete
    # FIXME: <kpbaks 2023-09-07 21:38:37> if there already is a slash at the cursor, then do not complete
    commandline --insert /
    if test (string trim -- $buffer) = ""
        # Do not want to complete if the user has not typed anything yet.
        return
    end

    commandline --function complete
    # commandline --function backward-delete-char

end




set -l mode default
bind --mode $mode " " __complete-eagerly.fish::space
bind --mode $mode - __complete-eagerly.fish::hyphen
bind --mode $mode \$ __complete-eagerly.fish::dollar
bind --mode $mode / __complete-eagerly.fish::slash
# FIXME: <kpbaks 2023-09-06 20:00:17> does not get registered properly. It is like the `preset`
# binding still remains.
# bind backspace __complete-eagerly.fish::backspace
# bind --mode default z __complete-eagerly.fish::backspace



set --global __complete_eagerly_last_character_expanded_text ""
# TODO: <kpbaks 2023-09-06 20:03:02> See if you can make this work
# with all characters in the alphabet. That would be cool.
set -l alphabet a b c d e f g h i j k l m n o p q r s t u v w x y z
for key in $alphabet (string upper $alphabet) (seq 0 9)
    # IDEA: before `commandline --function complete` is run, copy the buffer.
    # after `commandline --function complete` is run, check if the buffer is
    # equal to $buffer + <char>. If not then the completion has completed "to much"
    # and we should use `commandline --function replace' to replace the buffer with
    # the original $buffer + <char>.
    # TODO: <kpbaks 2023-09-17 12:03:48> autosuggestion seems to disappear when
    # creating the keybind like this.
    set -l fnname "__complete-eagerly.fish::$key"
    eval "function $fnname
		set -l buffer (commandline)
		commandline --insert $key
		if test (string trim -- \$buffer) = ''
			# Do not want to complete if the user has not typed anything yet.
			return
		end
		commandline --function complete
		set -l buffer_after (commandline)
        set __complete_eagerly_last_character_expanded_text \
			(string sub --start=(math (string length -- \$buffer) + 1) \$buffer_after)
	end"

    bind --mode $mode $key $fnname
end


function __complete-eagerly.fish::backspace
    set -l buffer (commandline)
    set -l in_paging_mode 0
    commandline --paging-mode; and set in_paging_mode 1

    commandline --function backward-delete-char
    commandline --insert $__complete_eagerly_last_character_expanded_text
    if test (string trim -- $buffer) = ""
        # Do not want to complete if the user has not typed anything yet.
        return
    end

    if test $in_paging_mode -eq 1
        # Reenable pager
        # TODO:

    end


    # commandline --function complete
end

bind --mode $mode backspace __complete-eagerly.fish::backspace

#
# for char in a e o
#     eval "function __complete-eagerly.fish::$char
#         set -l buffer (commandline)
#         # commandline --function expand-abbr
#         commandline --insert $char
#         if test (string trim -- \$buffer) = ''
#             # Do not want to complete if the user has not typed anything yet.
#             return
#         end
#
#         commandline --function complete
#     end"
#     bind --mode default $char __complete-eagerly.fish::$char
# end
