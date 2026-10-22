#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

INJECT_PORT=18764

if ! command -v adb >/dev/null; then
  echo "adb is required (host-side key injection)."
  exit 1
fi
if ! adb devices | awk 'NR>1 && $2=="device" {found=1} END {exit found?0:1}'; then
  echo "No Android device/emulator in 'device' state."
  exit 1
fi

if [[ ! -f lib/hive_registrar.g.dart || ! -f lib/l10n/messages_all.dart ]]; then
  echo "Generated sources missing; running prebuild..."
  fvm flutter pub get
  fvm dart run build_runner build --workspace --delete-conflicting-outputs
  fvm dart run intl_generator:extract_to_arb \
    --output-dir=./lib/l10n \
    lib/main/localizations/app_localizations.dart
  fvm dart run intl_generator:generate_from_arb \
    --output-dir=lib/l10n \
    --no-use-deferred-loading \
    lib/main/localizations/app_localizations.dart \
    lib/l10n/intl*.arb
  (
    cd scribe
    fvm dart run intl_generator:extract_to_arb \
      --output-dir=./lib/scribe/ai/l10n \
      lib/scribe/ai/localizations/scribe_localizations.dart
    fvm dart run intl_generator:generate_from_arb \
      --output-dir=lib/scribe/ai/l10n \
      --no-use-deferred-loading \
      lib/scribe/ai/localizations/scribe_localizations.dart \
      lib/scribe/ai/l10n/intl*.arb
  )
fi

inject_from_http() {
  python3 - "$INJECT_PORT" <<'PY'
import subprocess
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs, urlparse

port = int(sys.argv[1])

def inject(token: str) -> None:
    print(f"Injecting: {token}", flush=True)
    for part in token.split(";"):
        part = part.strip()
        if not part:
            continue
        if part.startswith("key:"):
            subprocess.check_call(["adb", "shell", "input", "keyevent", part[4:]])
        else:
            subprocess.check_call(["adb", "shell", "input", "text", part])

class Handler(BaseHTTPRequestHandler):
    def do_GET(self) -> None:
        token = (parse_qs(urlparse(self.path).query).get("token") or [""])[0]
        if token:
            inject(token)
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"ok")

    def log_message(self, format: str, *args) -> None:
        sys.stderr.write("inject-http: " + (format % args) + "\n")

print(f"adb inject HTTP listening on 0.0.0.0:{port}", flush=True)
HTTPServer(("0.0.0.0", port), Handler).serve_forever()
PY
}

adb shell input keyevent KEYCODE_WAKEUP || true
adb shell wm dismiss-keyguard || true

GRADLE_PROPS="$REPO_ROOT/android/gradle.properties"
GRADLE_BACKUP="$(mktemp)"
cp "$GRADLE_PROPS" "$GRADLE_BACKUP"
printf '\nandroid.testInstrumentationRunnerArguments.notClass=com.linagora.android.tmail.WebViewKeyboardTest\n' >> "$GRADLE_PROPS"

inject_from_http &
injector_pid=$!
cleanup() {
  kill "$injector_pid" 2>/dev/null || true
  mv "$GRADLE_BACKUP" "$GRADLE_PROPS"
}
trap cleanup EXIT

SKILL_RUN="$HOME/.claude/skills/patrol-web-test/scripts/run-mobile.sh"
if [[ ! -f "$SKILL_RUN" ]]; then
  echo "Missing $SKILL_RUN"
  exit 1
fi

bash "$SKILL_RUN" \
  integration_test/tests/composer/composer_body_os_keys_test.dart \
  --android
