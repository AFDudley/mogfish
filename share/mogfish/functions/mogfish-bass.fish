# mogfish-bass — bash compatibility wrapper that routes through mogfish
#
# Replaces `bash -c "CMD"` with mogfish classification + fish-native
# execution when possible. Falls back to bass (real bash) only when
# the command uses bash-specific syntax.
#
# Usage: mogfish-bass -c "CMD"   (same interface as bash)
#        mogfish-bass SCRIPT      (run a bash script file)

function mogfish-bass
    # Handle bash -c "command" pattern (what Claude Code sends)
    if test (count $argv) -ge 2; and test "$argv[1]" = "-c"
        set -l cmd $argv[2..-1]
        set -l joined_cmd (string join " " $cmd)

        # Classify the command
        set -l result (mogfish-classify -- $joined_cmd 2>/dev/null)
        set -l classify_status $status

        # If classifier fails or returns passthrough, use bass
        if test $classify_status -ne 0; or test "$result" = "passthrough"
            bass $joined_cmd
            return $status
        end

        switch $result
            case 'known:*'
                # Known command — safe to run directly in fish.
                # Strip the "known:" prefix to verify, then eval in fish.
                eval $joined_cmd
                return $status

            case 'skill:*'
                # Cached skill — run via mogfish skill handler
                set -l intent (string replace 'skill:' '' $result)
                __mogfish_run_skill $intent
                return $status

            case 'generate:*'
                # Novel intent — generate skill, but also run the
                # original command via bass so it doesn't block.
                # The skill will be cached for next time.
                bass $joined_cmd
                set -l bass_status $status
                # Background: generate and cache the skill for next time
                __mogfish_generate $joined_cmd &
                return $bass_status

            case '*'
                # Unknown classification — fall back to bass
                bass $joined_cmd
                return $status
        end

    else
        # Not -c pattern (script file or other args) — pass through to bash
        command bash $argv
        return $status
    end
end
