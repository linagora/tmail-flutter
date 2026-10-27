#!/bin/bash
# Usage: ci-backend-teardown.sh [<backend-log>]
# Stops tmail-backend only when this workspace's compose project owns it; another job's backend is left alone.
cd "$(dirname "$0")/../backend-docker" || exit 0
owner=$(docker inspect tmail-backend --format '{{ index .Config.Labels "com.docker.compose.project.working_dir" }}' 2>/dev/null || true)
if [ -z "$owner" ] || [ "$(realpath "$owner" 2>/dev/null)" != "$(pwd -P)" ]; then
    reason="tmail-backend not owned by this workspace (${owner:-none}); skip teardown."
    echo "$reason"
    # Keep why there are no backend logs; never dump another job's compose project.
    if [ -n "$1" ]; then echo "$reason" > "$1"; fi
    exit 0
fi
if [ -n "$1" ]; then
    docker compose logs --no-color --timestamps > "$1" 2>&1 || true
fi
docker compose down --remove-orphans || true
