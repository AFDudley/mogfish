# mogfish — fish shell integration
# Auto-loaded by fish on startup (via conf.d)
#
# Only activates if mogfish-classify is on PATH.
# See docs/plans/mogfish-outside-in-tdd.md, Layer 6

if command -q mogfish-classify
    mogfish-enable

    # Alias bash to mogfish-bass so that tools (like Claude Code) that
    # invoke `bash -c "CMD"` route through mogfish classification first.
    # Known commands run in fish natively. Unknown commands fall back to
    # real bash via bass. Skills are cached for future invocations.
    function bash --wraps bash
        mogfish-bass $argv
    end
end
