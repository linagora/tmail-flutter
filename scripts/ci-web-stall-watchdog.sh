#!/bin/bash
# Usage: ci-web-stall-watchdog.sh <patrol-console-log> <dump-file> <root-pid>
# Once Playwright runs under <root-pid>, a console with no new test/step marker
# for STALL_MINUTES gets its process/socket/HTTP state dumped and Playwright
# interrupted, so a stuck run fails fast with evidence.
PATROL_LOG="$1"
DUMP_FILE="$2"
ROOT_PID="$3"
STALL_MINUTES="${STALL_MINUTES:-15}"
POLL_SECONDS="${POLL_SECONDS:-30}"
GRACE_SECONDS="${GRACE_SECONDS:-60}"

descendants() {
    local child
    for child in $(pgrep -P "$1"); do
        echo "$child"
        descendants "$child"
    done
}

# This run's Playwright CLI only: other jobs on the agent are never touched.
playwright_pids() {
    local pid
    for pid in $(descendants "$ROOT_PID"); do
        # Patrol runs `npx playwright test ...` in a shell: sh, npm and node all match.
        ps -o args= -p "$pid" | grep -qE 'playwright( test|/cli\.js test) tests/test\.spec\.ts' && echo "$pid"
    done
}

count_markers() {
    LC_ALL=C grep -acE '✅|❌' "$PATROL_LOG" 2>/dev/null || true
}

dump_state() {
    {
        echo "=== stall $(date -u +%FT%TZ): no progress for ${STALL_MINUTES} min ==="
        echo "--- processes by cpu"
        ps -eo pid,ppid,stat,etime,pcpu,pmem,rss,comm --sort=-pcpu | head -30
        echo "--- sockets"
        ss -tanp 2>/dev/null | grep -E ':(3000|9999|80)\b'
        echo "--- flutter web server"
        curl -sS -m 10 -o /dev/null -w 'GET / http=%{http_code} time=%{time_total}s\n' http://localhost:3000/
        curl -sS -m 10 -o /dev/null -w 'GET main.dart.js http=%{http_code} time=%{time_total}s\n' http://localhost:3000/main.dart.js
        echo "--- docker"
        timeout 15 docker ps -a --format 'table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}'
        timeout 15 docker stats --no-stream
    } >> "$DUMP_FILE" 2>&1
}

last_count=-1
last_change=$(date +%s)
interrupted_at=0
while sleep "$POLL_SECONDS"; do
    pids=$(playwright_pids)
    count=$(count_markers)
    now=$(date +%s)
    if [ "$interrupted_at" -gt 0 ]; then
        if [ -z "$pids" ]; then
            interrupted_at=0
            last_change="$now"
        elif [ $((now - interrupted_at)) -ge "$GRACE_SECONDS" ]; then
            # SIGINT can be ignored (background child of a non-interactive shell)
            # shellcheck disable=SC2086
            kill -TERM $pids 2>/dev/null
            interrupted_at="$now"
        fi
        continue
    fi
    # Startup (flutter build, npm/browser install) is not counted as a stall.
    if [ -z "$pids" ] || [ "${count:-0}" != "$last_count" ]; then
        last_count="${count:-0}"
        last_change="$now"
        continue
    fi
    if [ $((now - last_change)) -ge $((STALL_MINUTES * 60)) ]; then
        dump_state
        # shellcheck disable=SC2086
        kill -INT $pids 2>/dev/null
        interrupted_at="$now"
    fi
done
