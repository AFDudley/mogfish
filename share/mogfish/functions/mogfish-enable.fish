# mogfish-enable — rebind Enter to mogfish classifier
#
# See docs/plans/mogfish-outside-in-tdd.md, Layer 6

function mogfish-enable
    bind \r __mogfish_execute
    echo "mogfish: enabled (Enter key rebound)"
end
