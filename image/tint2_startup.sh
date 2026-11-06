#!/bin/bash

echo "starting tint2 on display :$DISPLAY_NUM ..."

MAX_TRIES=5
for i in $(seq 1 $MAX_TRIES); do
    # 先确认 X display 真正可达
    for w in $(seq 1 20); do
        if xdpyinfo >/dev/null 2>&1; then break; fi
        sleep 0.5
    done

    tint2 -c $HOME/.config/tint2/tint2rc 2>/tmp/tint2_stderr.log &
    TINT2_PID=$!

    # Wait for tint2 window properties to appear
    timeout=30
    while [ $timeout -gt 0 ]; do
        if xdotool search --class "tint2" >/dev/null 2>&1; then
            echo "tint2 ready (try $i)"
            rm -f /tmp/tint2_stderr.log
            exit 0
        fi
        # tint2 进程死了就立即重试，别傻等
        if ! kill -0 $TINT2_PID 2>/dev/null; then
            break
        fi
        sleep 1
        timeout=$((timeout-1))
    done

    echo "tint2 try $i failed:" >&2
    cat /tmp/tint2_stderr.log >&2 2>/dev/null || true
    kill $TINT2_PID 2>/dev/null || true
    sleep 2
done

echo "tint2 failed after $MAX_TRIES tries" >&2
exit 1
