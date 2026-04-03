# __mogfish_generate — generate and execute a mog script for novel input
#
# Calls mogfish-annotate generate to produce a Mog script from natural
# language, then executes it. On success, caches the result as a skill.
#
# See docs/plans/mogfish-outside-in-tdd.md, Layer 6

function __mogfish_generate --argument-names cmd
    # Generate a Mog script from the intent
    set -l script (mogfish-annotate generate --intent "$cmd" 2>/dev/null)

    if test $status -ne 0; or test -z "$script"
        echo "mogfish: generation failed for '$cmd'" >&2
        return 1
    end

    # TODO: compile with mogc --emit-ir to validate before executing
    # TODO: execute via mog runtime
    # TODO: cache as skill via mogfish skill-cache

    # For now, print the generated script
    echo "mogfish: generated script for '$cmd':"
    echo "$script"
end
