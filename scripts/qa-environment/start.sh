#!/bin/bash
#
# Starts a long lived web app + tmail-backend stack for manual or agent driven exploratory QA.
#
# Same backend as the patrol integration tests (backend-docker/, provisioned with
# provisioning/integration_test/provisioning.sh), but under its own compose project and ports so it
# does not clash with them, and kept up until stop.sh is called.
#
#   scripts/qa-environment/build.sh    # once, and whenever the code under test changes
#   scripts/qa-environment/start.sh
#   QA_USERS="frank grace" scripts/qa-environment/start.sh   # extra accounts
#
# Accounts are <uid>@example.com, the password is the uid: alice, bob (with a restored mailbox,
# a quota and the bob-guests team mailbox), brian, charlotte, david, emma, plus QA_USERS.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
GENERATED_DIR="$SCRIPT_DIR/.generated"

QA_PROJECT="${QA_PROJECT:-tmail-qa}"
QA_USERS="${QA_USERS:-}"
DOMAIN="example.com"
export QA_WEB_PORT="${QA_WEB_PORT:-8080}"
export QA_JMAP_PORT="${QA_JMAP_PORT:-8090}"
# Single source of truth for the backend version: the compose file of the integration tests.
TMAIL_BACKEND_IMAGE="$(sed -n 's/^ *image: *\(linagora\/tmail-backend:.*\)$/\1/p' "$REPO_DIR/backend-docker/docker-compose.yaml")"
export TMAIL_BACKEND_IMAGE

JMAP_URL="http://localhost:$QA_JMAP_PORT"
WEB_URL="http://localhost:$QA_WEB_PORT"

compose() {
  docker compose -p "$QA_PROJECT" -f "$SCRIPT_DIR/docker-compose.yaml" "$@"
}

webadmin() {
  compose exec -T tmail-backend curl -s "$@"
}

if ! docker image inspect tmail-web-qa >/dev/null 2>&1; then
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
    -e "s|^websocket.url.prefix=.*|websocket.url.prefix=ws://localhost:$QA_JMAP_PORT|" \
    "$REPO_DIR/backend-docker/jmap.properties" > "$GENERATED_DIR/jmap.properties"
sed -e "s|^SERVER_URL=.*|SERVER_URL=$JMAP_URL/|" \
    -e "s|^DOMAIN_REDIRECT_URL=.*|DOMAIN_REDIRECT_URL=$WEB_URL|" \
    "$REPO_DIR/integration_test/integration_test_env.file" > "$GENERATED_DIR/env.file"

echo "==> Starting the stack as compose project '$QA_PROJECT' ($TMAIL_BACKEND_IMAGE)"
compose up -d

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

cat <<INFO

==> The QA environment is up

  Web app: $WEB_URL  (basic authentication, no SSO)
  JMAP:    $JMAP_URL/jmap/session

From a container (e.g. Playwright), join the network '${QA_PROJECT}_default' and use:
  --host-resolver-rules="MAP localhost:$QA_WEB_PORT web:80,MAP localhost:$QA_JMAP_PORT tmail-backend:80"

Stop it with: scripts/qa-environment/stop.sh
INFO
