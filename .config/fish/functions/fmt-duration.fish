function fmt-duration --argument-names ms
    if test -z "$ms"
        echo "usage: fmt-duration <milliseconds>"
        return 1
    end

    set -l MS_PER_SEC 1000
    set -l SECS_PER_MIN 60
    set -l SECS_PER_HOUR 3600
    set -l SECS_PER_DAY 86400
    set -l ROUNDING_THRESHOLD 30

    set -l s (math "$ms / $MS_PER_SEC")

    if test $s -lt 1
        echo {$ms}ms
    else if test $s -lt $SECS_PER_MIN
        printf "%.1fs\n" $s
    else if test $s -lt $SECS_PER_HOUR
        printf "%dm %ds\n" (math "floor($s / $SECS_PER_MIN)") (math "floor($s % $SECS_PER_MIN)")
    else
        set -l rounded $s
        if test (math "$s % $SECS_PER_MIN") -ge $ROUNDING_THRESHOLD
            set rounded (math "$s + $SECS_PER_MIN")
        end

        if test $s -lt $SECS_PER_DAY
            printf "%dh %dm\n" \
                (math "floor($rounded / $SECS_PER_HOUR)") \
                (math "floor($rounded % $SECS_PER_HOUR / $SECS_PER_MIN)")
        else
            printf "%dd %dh %dm\n" \
                (math "floor($rounded / $SECS_PER_DAY)") \
                (math "floor($rounded % $SECS_PER_DAY / $SECS_PER_HOUR)") \
                (math "floor($rounded % $SECS_PER_HOUR / $SECS_PER_MIN)")
        end
    end
end
