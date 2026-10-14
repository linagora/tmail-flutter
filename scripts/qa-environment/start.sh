#!/bin/bash
#
# Starts a long lived web app + tmail-backend stack for manual or agent driven exploratory QA.
#
# Same backend as the patrol integration tests (backend-docker/, provisioned with
# provisioning/integration_test/provisioning.sh), but under its own compose project and ports so it
# does not clash with them, and kept up until stop.sh is called.
#
# With --mobile-version, the client is the Android app instead of the web app: the APK of
# build.sh --mobile-version (image tmail-mobile-qa-apk) is installed afresh on the emulator
# $ANDROID_SERIAL (already booted: this script never starts one) and signed in as alice. The app
# requires HTTPS: the emulator reaches the backend through a TLS proxy published on the host, as
# https://10.0.2.2:$QA_JMAPS_PORT, with a certificate of a QA CA it is made to trust
# (android-trust-ca.sh: adb root, until its next boot). Plain JMAP stays on
# http://localhost:$QA_JMAP_PORT, the WebAdmin API on 127.0.0.1:$QA_WEBADMIN_PORT.
#
#   scripts/qa-environment/build.sh    # once, and whenever the code under test changes
#   scripts/qa-environment/start.sh
#   QA_USERS="frank grace" scripts/qa-environment/start.sh   # extra accounts
#   ANDROID_SERIAL=emulator-5554 scripts/qa-environment/start.sh --mobile-version
#
# Accounts are <uid>@example.com, the password is the uid: alice, bob (with a restored mailbox,
# a quota and the bob-guests team mailbox), brian, charlotte, david, emma, plus QA_USERS.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
GENERATED_DIR="$SCRIPT_DIR/.generated"

MOBILE=false
for arg in "$@"; do
  case "$arg" in
    --mobile-version) MOBILE=true ;;
    *) echo "Unknown argument: $arg (--mobile-version)" >&2; exit 2 ;;
  esac
done

QA_PROJECT="${QA_PROJECT:-tmail-qa}"
QA_USERS="${QA_USERS:-}"
DOMAIN="example.com"
PACKAGE=com.linagora.android.teammail
APK="$GENERATED_DIR/tmail-qa.apk"
export QA_WEB_PORT="${QA_WEB_PORT:-8080}"
export QA_JMAP_PORT="${QA_JMAP_PORT:-8090}"
export QA_WEBADMIN_PORT="${QA_WEBADMIN_PORT:-8000}"
export QA_JMAPS_PORT="${QA_JMAPS_PORT:-8443}"
# Single source of truth for the backend version: the compose file of the integration tests.
TMAIL_BACKEND_IMAGE="$(sed -n 's/^ *image: *\(linagora\/tmail-backend:.*\)$/\1/p' "$REPO_DIR/backend-docker/docker-compose.yaml")"
export TMAIL_BACKEND_IMAGE

if [ "$MOBILE" = true ]; then
  # 10.0.2.2: the host, as the Android emulator sees it
  JMAP_HOST="10.0.2.2:$QA_JMAPS_PORT"
  JMAP_URL="https://$JMAP_HOST"
  WS_URL="wss://$JMAP_HOST"
  COMPOSE_FILES=(-f "$SCRIPT_DIR/docker-compose.yaml" -f "$SCRIPT_DIR/docker-compose.mobile.yaml")
  SERVICES=(tmail-backend tls)
else
  JMAP_HOST="localhost:$QA_JMAP_PORT"
  JMAP_URL="http://$JMAP_HOST"
  WS_URL="ws://$JMAP_HOST"
  COMPOSE_FILES=(-f "$SCRIPT_DIR/docker-compose.yaml")
  SERVICES=()
fi
WEB_URL="http://localhost:$QA_WEB_PORT"

compose() {
  docker compose -p "$QA_PROJECT" "${COMPOSE_FILES[@]}" "$@"
}

webadmin() {
  compose exec -T tmail-backend curl -s "$@"
}

if [ "$MOBILE" = true ]; then
  export ANDROID_SERIAL="${ANDROID_SERIAL:?the emulator under test, e.g. emulator-5554}"
  export PATH="${ANDROID_HOME:-$HOME/Android/Sdk}/platform-tools:$HOME/.maestro/bin:$PATH"
  export MAESTRO_CLI_NO_ANALYTICS="${MAESTRO_CLI_NO_ANALYTICS:-1}"
  command -v adb >/dev/null || { echo "adb is not on the PATH (Android SDK platform-tools)" >&2; exit 1; }
  command -v maestro >/dev/null || { echo "maestro is not on the PATH (https://docs.maestro.dev)" >&2; exit 1; }
  docker image inspect tmail-mobile-qa-apk >/dev/null 2>&1 ||
    { echo "The tmail-mobile-qa-apk image is missing, build it first: scripts/qa-environment/build.sh --mobile-version" >&2; exit 1; }
  [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = 1 ] ||
    { echo "$ANDROID_SERIAL is not a booted device" >&2; exit 1; }
elif ! docker image inspect tmail-web-qa >/dev/null 2>&1; then
  echo "The tmail-web-qa image is missing, build it first: scripts/qa-environment/build.sh" >&2
  exit 1
fi

echo "==> Generating the configuration in $GENERATED_DIR"
mkdir -p "$GENERATED_DIR"
if [ ! -f "$GENERATED_DIR/jwt_privatekey" ]; then
  openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -out "$GENERATED_DIR/jwt_privatekey" 2>/dev/null
  openssl rsa -in "$GENERATED_DIR/jwt_privatekey" -pubout -out "$GENERATED_DIR/jwt_publickey" 2>/dev/null
fi
# James advertises these URLs in its JMAP session, the app uses them for every later request.
sed -e "s|^url.prefix=.*|url.prefix=$JMAP_URL|" \
    -e "s|^websocket.url.prefix=.*|websocket.url.prefix=$WS_URL|" \
    "$REPO_DIR/backend-docker/jmap.properties" > "$GENERATED_DIR/jmap.properties"
if [ "$MOBILE" = true ]; then
  # The QA CA, then the certificate of the TLS proxy: 10.0.2.2 for the emulator, localhost for curl
  if [ ! -f "$GENERATED_DIR/qa-ca.pem" ]; then
    openssl req -x509 -newkey rsa:2048 -nodes -days 3650 -subj "/CN=Twake Mail QA CA" \
      -addext basicConstraints=critical,CA:TRUE -addext keyUsage=critical,keyCertSign,cRLSign \
      -keyout "$GENERATED_DIR/qa-ca.key" -out "$GENERATED_DIR/qa-ca.pem" 2>/dev/null
  fi
  openssl req -newkey rsa:2048 -nodes -subj "/CN=10.0.2.2" \
    -keyout "$GENERATED_DIR/tls.key" -out "$GENERATED_DIR/tls.csr" 2>/dev/null
  openssl x509 -req -in "$GENERATED_DIR/tls.csr" -CA "$GENERATED_DIR/qa-ca.pem" \
    -CAkey "$GENERATED_DIR/qa-ca.key" -CAcreateserial -days 825 -out "$GENERATED_DIR/tls.pem" \
    -extfile <(printf 'subjectAltName=IP:10.0.2.2,IP:127.0.0.1,DNS:localhost\nextendedKeyUsage=serverAuth\n') 2>/dev/null
  chmod 644 "$GENERATED_DIR/tls.key"
  cat > "$GENERATED_DIR/nginx-tls.conf" <<'NGINX'
server {
  listen 443 ssl;
  ssl_certificate /etc/nginx/tls.pem;
  ssl_certificate_key /etc/nginx/tls.key;
  client_max_body_size 0;
  proxy_read_timeout 1h;
  location / {
    proxy_pass http://tmail-backend:80;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $http_connection;
    proxy_set_header X-Forwarded-Proto https;
  }
}
NGINX
fi
sed -e "s|^SERVER_URL=.*|SERVER_URL=$JMAP_URL/|" \
    -e "s|^DOMAIN_REDIRECT_URL=.*|DOMAIN_REDIRECT_URL=$WEB_URL|" \
    "$REPO_DIR/integration_test/integration_test_env.file" > "$GENERATED_DIR/env.file"

echo "==> Starting the stack as compose project '$QA_PROJECT' ($TMAIL_BACKEND_IMAGE)"
compose up -d "${SERVICES[@]}"

echo "==> Waiting for tmail-backend"
for _ in $(seq 1 120); do
  if compose logs tmail-backend 2>/dev/null | grep -qi "JAMES server started"; then
    ready=true
    break
  fi
  sleep 5
done
if [ "${ready:-false}" != "true" ]; then
  echo "tmail-backend did not start within 10 minutes, see: docker compose -p $QA_PROJECT logs" >&2
  exit 1
fi

echo "==> Creating the QA accounts"
if [ "$(webadmin -I -o /dev/null -w '%{http_code}' "http://localhost:8000/users/bob@$DOMAIN")" = "200" ]; then
  echo "    already provisioned"
else
  compose exec -T tmail-backend /root/conf/integration_test/provisioning.sh >/dev/null
fi
for uid in $QA_USERS; do
  status="$(webadmin -o /dev/null -w '%{http_code}' -X PUT -H 'Content-Type: application/json' \
    -d "{\"password\":\"$uid\"}" "http://localhost:8000/users/$uid@$DOMAIN")"
  case "$status" in
    204) ;;
    *) echo "tmail-backend refused to create $uid@$DOMAIN: HTTP $status" >&2; exit 1 ;;
  esac
done
for uid in alice bob brian charlotte david emma $QA_USERS; do
  echo "    $uid@$DOMAIN / $uid"
done

if [ "$MOBILE" = false ]; then
  cat <<INFO

==> The QA environment is up

  Web app: $WEB_URL  (basic authentication, no SSO)
  JMAP:    $JMAP_URL/jmap/session

From a container (e.g. Playwright), join the network '${QA_PROJECT}_default' and use:
  --host-resolver-rules="MAP localhost:$QA_WEB_PORT web:80,MAP localhost:$QA_JMAP_PORT tmail-backend:80"

Stop it with: scripts/qa-environment/stop.sh
INFO
  exit 0
fi

echo "==> Making $ANDROID_SERIAL trust the QA CA"
"$SCRIPT_DIR/android-trust-ca.sh" "$GENERATED_DIR/qa-ca.pem"
for _ in $(seq 1 30); do
  curl -s -o /dev/null --cacert "$GENERATED_DIR/qa-ca.pem" "https://localhost:$QA_JMAPS_PORT/" && break
  sleep 1
done

echo "==> Installing the APK of tmail-mobile-qa-apk on $ANDROID_SERIAL"
container="$(docker create tmail-mobile-qa-apk none)"
docker cp -q "$container:/tmail-qa.apk" "$APK"
docker rm "$container" >/dev/null
# Uninstalling drops the account and the cache of the previous run
adb uninstall "$PACKAGE" >/dev/null 2>&1 || true
adb install "$APK"
adb shell pm grant "$PACKAGE" android.permission.POST_NOTIFICATIONS 2>/dev/null ||
  echo "    android.permission.POST_NOTIFICATIONS not granted (not requested by the app on this Android?)"

echo "==> Signing in as alice@$DOMAIN"
maestro --device "$ANDROID_SERIAL" test -e USERNAME=alice -e SERVER="$JMAP_HOST" \
  -e EMAIL="alice@$DOMAIN" -e PASSWORD=alice "$SCRIPT_DIR/sign-in.yaml"
adb shell am force-stop dev.mobile.maestro.test 2>/dev/null || true

cat <<INFO

==> The QA environment is up

  Twake Mail ($PACKAGE) on $ANDROID_SERIAL, signed in as alice@$DOMAIN / alice
  Server URL in the app: $JMAP_URL  (basic authentication, no SSO)
  From this host: JMAP http://localhost:$QA_JMAP_PORT/jmap/session, WebAdmin http://localhost:$QA_WEBADMIN_PORT

Stop it with: ANDROID_SERIAL=$ANDROID_SERIAL scripts/qa-environment/stop.sh --mobile-version
INFO
