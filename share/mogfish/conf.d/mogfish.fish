# mogfish — fish shell integration
# Auto-loaded by fish on startup (via conf.d)
#
# Only activates if mogfish-classify is on PATH.
# See docs/plans/mogfish-outside-in-tdd.md, Layer 6

if command -q mogfish-classify
    mogfish-enable
end
