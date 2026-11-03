#!/bin/bash
# Sourced by ci-web-boot-stall-probe.sh. Native stacks of a browser that stopped answering DevTools:
# the kernel stack and syscall of the main thread say what it sleeps on, gdb says which code asked for it.
# They need root (sudo -n) and gdb; every gap is reported as a line, never fatal.

native_preflight() {
    local gdb_path sudo_state scope
    gdb_path=$(command -v gdb || echo none)
    if sudo -n true 2>/dev/null; then sudo_state=ok; else sudo_state=no; fi
    scope=$(cat /proc/sys/kernel/yama/ptrace_scope 2>/dev/null || echo unreadable)
    echo "NATIVE preflight gdb=$gdb_path sudo=$sudo_state ptrace_scope=$scope"
}

# Profiles are found by scanning /tmp, so a browser of another job on this agent can look frozen too.
# True when <pid> descends from the script that started the probe (override with NATIVE_OWNER_PID).
native_owned() {
    local pid="$1" owner="${NATIVE_OWNER_PID:-$PPID}" depth=0
    while [ -n "$pid" ] && [ "$pid" -gt 1 ] && [ $((depth++)) -lt 64 ]; do
        [ "$pid" = "$owner" ] && return 0
        pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
    done
    return 1
}

# gdb stops the process while it reads it, so this runs on a browser whose test already froze.
native_gdb() {
    if ! command -v gdb >/dev/null 2>&1; then
        echo "NATIVE $1 gdb unavailable: not installed"
        return 0
    fi
    echo "NATIVE $1 gdb:"
    sudo -n timeout -k 5s 20s gdb -nx -batch -p "$1" -ex 'set pagination off' -ex 'bt 60' -ex 'thread apply all bt 25' -ex detach 2>&1 | head -500 || true
}

native_stacks() {
    local pid sample
    [ "$#" -gt 0 ] || return 0
    if [ -z "${NATIVE_PREFLIGHT_DONE:-}" ]; then
        NATIVE_PREFLIGHT_DONE=1
        native_preflight
    fi
    for pid in "$@"; do
        if [ ! -d "/proc/$pid" ]; then
            echo "NATIVE $pid unavailable: exited"
            continue
        fi
        if ! sudo -n true 2>/dev/null; then
            echo "NATIVE $pid unavailable: no passwordless sudo"
            continue
        fi
        for sample in 1 2; do
            echo "NATIVE $pid sample=$sample stack: $(sudo -n cat "/proc/$pid/task/$pid/stack" 2>&1 | tr '\n' ';' | cut -c1-600)"
            echo "NATIVE $pid sample=$sample syscall: $(sudo -n cat "/proc/$pid/task/$pid/syscall" 2>&1 | head -1)"
            [ "$sample" -eq 2 ] || sleep 2
        done
        echo "NATIVE $pid exe: $(readelf -n "/proc/$pid/exe" 2>/dev/null | grep -m1 'Build ID' | sed 's/^ *//')"
        native_gdb "$pid"
    done
}
