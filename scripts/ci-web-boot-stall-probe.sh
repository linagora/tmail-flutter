#!/bin/bash
# Usage: ci-web-boot-stall-probe.sh <patrol-console-log> <dump-file> <dev-server-url>
# Every tab boot logs one "DDC is about to load 1/2 scripts" first and one "Starting application" last,
# but the lines name no tab, so the log only says that some boot is unfinished.
# Then the tabs are asked: each one without a Flutter view for BOOT_STALL_SECONDS dumps the dev server
# and socket state once, so a stalled page.goto shows whether the server starved or dwds dropped the connection.
# When the tabs cannot be read, the unfinished boot itself triggers the dump, at most every DUMP_EVERY_SECONDS.
PATROL_LOG="$1"
DUMP_FILE="$2"
SERVER_URL="$3"
BOOT_STALL_SECONDS="${BOOT_STALL_SECONDS:-90}"
CHECK_EVERY_SECONDS="${CHECK_EVERY_SECONDS:-30}"
DUMP_EVERY_SECONDS="${DUMP_EVERY_SECONDS:-120}"
POLL_SECONDS="${POLL_SECONDS:-10}"
SERVER_PORT="${SERVER_URL##*:}"

if [ -z "${WEB_RUNNER_DIR:-}" ]; then
    echo "SKIP boot stall probe: WEB_RUNNER_DIR unset" >> "$DUMP_FILE"
    exit 0
fi

count_log() {
    LC_ALL=C grep -acE "$1" "$PATROL_LOG" 2>/dev/null || true
}

pending_boots() {
    local started finished
    started=$(count_log 'DDC is about to load 1/2 scripts')
    finished=$(count_log 'Starting application from main method')
    echo $(( ${started:-0} - ${finished:-0} ))
}

# One "<profile dir> <navigation origin>" per tab that waited past BOOT_STALL_SECONDS for its Flutter view.
stalled_tabs() {
    awk -v min_ms="$((BOOT_STALL_SECONDS * 1000))" '
        $1 == "TABS" { dir = $2 }
        $1 == "PAGE" {
            for (i = 2; i <= NF; i++) { split($i, kv, "="); f[kv[1]] = kv[2] }
            if (f["now"] + 0 >= min_ms) print dir, f["origin"]
        }' <<< "$1"
}

# CDP failed somewhere: no tab list, a failed connection or page, or the helper timeout.
# A profile dir without DevToolsActivePort is a closed browser, not a failure.
tabs_unreadable() {
    ! grep -q '^TABS' <<< "$1" || grep -E '^(SKIP|TIMEOUT)' <<< "$1" | grep -qv 'DevToolsActivePort'
}

dump_state() {
    local pages="$1" src
    {
        echo "=== boot stall $(date -u +%FT%TZ): $2 > ${BOOT_STALL_SECONDS}s ==="
        echo "--- boot markers: started=$(count_log 'DDC is about to load 1/2 scripts') connected=$(count_log 'App connection established') running=$(count_log 'Starting application from main method') isolate-exits=$(count_log 'Isolate exit handled')"
        echo "--- last dwds/boot lines"
        LC_ALL=C grep -aE 'DDC is about to load|App connection established|Starting application from main method|Isolate exit handled|DevHandler|Playwright: .*(rror|ailed)' "$PATROL_LOG" | tail -15 | cut -c1-240
        echo "--- load"
        uptime
        free -m
        echo "--- processes by cpu"
        ps -eo pid,ppid,stat,etime,pcpu,pmem,rss,comm --sort=-pcpu | head -25
        echo "--- browser and dev server processes"
        echo "chrome processes: $(pgrep -fc 'chrom.*(headless|--remote-debugging)')"
        ps -o pid,stat,etime,pcpu,rss,args -p "$(pgrep -f 'flutter_tools.*snapshot.*run' | paste -sd, -)" 2>/dev/null | cut -c1-200
        echo "--- dev server sockets (port ${SERVER_PORT}) by state"
        ss -tan "( sport = :${SERVER_PORT} )" 2>/dev/null | awk 'NR>1 {n[$1]++} END {for (s in n) print s, n[s]}'
        echo "--- dev server sockets with queued bytes (Recv-Q Send-Q)"
        ss -tan "( sport = :${SERVER_PORT} )" 2>/dev/null | awk 'NR>1 && ($2>0 || $3>0)' | head -40
        echo "--- dev server responsiveness"
        curl -sS -m 20 -o /dev/null -w 'GET main.dart.js http=%{http_code} connect=%{time_connect}s ttfb=%{time_starttransfer}s total=%{time_total}s bytes=%{size_download}\n' "${SERVER_URL}/main.dart.js"
        curl -sS -m 20 -o /dev/null -w 'GET / http=%{http_code} total=%{time_total}s\n' "${SERVER_URL}/"
        echo "--- tabs still booting (CDP)"
        printf '%s\n' "$pages"
        echo "--- pending and last script responsiveness"
        while IFS= read -r src; do
            [ -n "$src" ] || continue
            curl -gsS -m 20 -o /dev/null -w 'http=%{http_code} connect=%{time_connect}s ttfb=%{time_starttransfer}s total=%{time_total}s bytes=%{size_download} ' -- "$src" || true
            echo "$src"
        done < <(printf '%s\n' "$pages" | sed -n 's/^\(PENDING\|LAST_SCRIPT\) //p' | awk '!seen[$0]++' | head -20) || true
        echo "--- last finished test before the stall"
        LC_ALL=C grep -a 'PatrolBinding: finished test' "$PATROL_LOG" | tail -1 | cut -c1-240 || true
    } >> "$DUMP_FILE" 2>&1
}

last_check=0
blind_since=0
last_blind_dump=0
seen=""
while sleep "$POLL_SECONDS"; do
    # A stalled boot never logs "Starting application", so pending stays above 0 while one exists.
    if [ "$(pending_boots)" -le 0 ]; then
        blind_since=0
        continue
    fi
    now=$(date +%s)
    [ $((now - last_check)) -ge "$CHECK_EVERY_SECONDS" ] || continue
    last_check="$now"
    pages=$(timeout 40 node "$(dirname "$0")/ci-web-boot-stall-pages.js" "$WEB_RUNNER_DIR" 2>&1) || true
    fresh=0
    while read -r key; do
        case "$seen" in *"|$key|"*) continue ;; esac
        seen="$seen|$key|"
        fresh=$((fresh + 1))
    done < <(stalled_tabs "$pages")
    if [ "$fresh" -gt 0 ]; then
        dump_state "$pages" "$fresh tab(s) booting"
    elif tabs_unreadable "$pages"; then
        [ "$blind_since" -gt 0 ] || blind_since="$now"
        if [ $((now - blind_since)) -ge "$BOOT_STALL_SECONDS" ] && [ $((now - last_blind_dump)) -ge "$DUMP_EVERY_SECONDS" ]; then
            dump_state "$pages" "boot(s) pending, tabs unreadable"
            last_blind_dump="$now"
        fi
    else
        blind_since=0
    fi
done
