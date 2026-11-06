#!/bin/bash
# Usage: ci-backend-teardown.sh [<backend-log>]
# Stops tmail-backend and pool containers only when this workspace's compose project owns them; another job's backend is left alone.
cd "$(dirname "$0")/../backend-docker" || exit 0
# Pool containers (scripts/backend-reset-server.py) belong to the workspace that started them.
docker ps -aq --filter label=tmail.ci.pool=1 | while read -r id; do
    pool_owner=$(docker inspect "$id" --format '{{ index .Config.Labels "com.docker.compose.project.working_dir" }}' 2>/dev/null || true)
    [ -n "$pool_owner" ] && [ "$(realpath "$pool_owner" 2>/dev/null)" = "$(pwd -P)" ] || continue
    if [ -n "$1" ]; then
        docker logs --timestamps "$id" > "$(dirname "$1")/backend-$(docker inspect "$id" --format '{{.Name}}' | tr -d /).log" 2>&1 || true
    fi
    docker rm -f "$id" >/dev/null || true
done
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
