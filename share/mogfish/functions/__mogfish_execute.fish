# __mogfish_execute — Enter key handler for mogfish
#
# Reads the commandline buffer, classifies via mogfish-classify,
# and routes to the appropriate handler.
#
# See docs/plans/mogfish-outside-in-tdd.md, Layer 6

function __mogfish_execute
    set -l cmd (commandline -b)

    # Empty command — just execute (prints new prompt)
    if test -z "$cmd"
        commandline -f execute
        return
    end

    # Classify
    set -l result (mogfish-classify -- $cmd 2>/dev/null)

    # On error or passthrough, execute normally
    if test $status -ne 0; or test "$result" = passthrough
        commandline -f execute
        return
    end

    switch $result
        case 'known:*'
            # Known command — execute as-is
            commandline -f execute
        case 'skill:*'
            # Cached skill — run via skill handler
            set -l intent (string replace 'skill:' '' $result)
            __mogfish_run_skill $intent
        case 'generate:*'
            # Novel intent — generate and confirm
            __mogfish_generate $cmd
        case '*'
            commandline -f execute
    end
end
