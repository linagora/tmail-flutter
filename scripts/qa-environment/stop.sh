#!/bin/bash
#
# Stops the QA environment started by start.sh. The backend stores everything in memory: its data
# is gone once stopped.
#
# With --mobile-version, also leaves the emulator $ANDROID_SERIAL as a run found it: the app
# uninstalled, airplane mode off, Maestro's driver stopped. The emulator is only reset when the QA
# stack was running: otherwise another run may be using it.
#
#   scripts/qa-environment/stop.sh
#   ANDROID_SERIAL=emulator-5554 scripts/qa-environment/stop.sh --mobile-version
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

MOBILE=false
for arg in "$@"; do
  case "$arg" in
    --mobile-version) MOBILE=true ;;
    *) echo "Unknown argument: $arg (--mobile-version)" >&2; exit 2 ;;
  esac
done

QA_PROJECT="${QA_PROJECT:-tmail-qa}"

# compose interpolates the whole file even to stop it
export TMAIL_BACKEND_IMAGE=unused QA_JMAP_PORT=0 QA_WEB_PORT=0
RUNNING="$(docker compose -p "$QA_PROJECT" ps -q 2>/dev/null || true)"
docker compose -p "$QA_PROJECT" -f "$SCRIPT_DIR/docker-compose.yaml" down --volumes --remove-orphans
if [ "$MOBILE" = true ] && [ -n "$RUNNING" ] && [ -n "${ANDROID_SERIAL:-}" ]; then
  export PATH="${ANDROID_HOME:-$HOME/Android/Sdk}/platform-tools:$PATH"
  if adb get-state >/dev/null 2>&1; then
    adb uninstall com.linagora.android.teammail >/dev/null || true
    adb shell cmd connectivity airplane-mode disable || true
    adb shell am force-stop dev.mobile.maestro.test || true
    adb shell am force-stop dev.mobile.maestro || true
    adb forward --remove-all || true
  fi
fi
echo "==> QA environment '$QA_PROJECT' stopped"
