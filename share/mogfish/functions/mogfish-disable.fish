# mogfish-disable — restore default Enter binding
#
# See docs/plans/mogfish-outside-in-tdd.md, Layer 6

function mogfish-disable
    bind \r execute
    echo "mogfish: disabled (Enter key restored)"
end
