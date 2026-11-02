ARG FLUTTER_VERSION=3.47.9

# instrumentisto/flutter is archived and has no 3.47.9 tag; gmeligio tracks current stable.
# Digest pins the linux/amd64 manifest (digest wins over the tag).
FROM --platform=amd64 ghcr.io/gmeligio/flutter-web:${FLUTTER_VERSION}@sha256:8af1fcd0a7f7e84580f30d7f915f44237bb7a032bd8f4e3135a64fbec1ce1756 AS build-env

ARG SENTRY_ORG
ARG SENTRY_PROJECT
ARG SENTRY_URL
ARG SENTRY_RELEASE
ARG VCS_REF
ARG GITHUB_SHA

# Image defaults to user flutter; root only for COPY ownership.
USER root
WORKDIR /app
COPY . .
RUN chown -R flutter:flutter /app

USER flutter

ENV GITHUB_SHA=$GITHUB_SHA \
    SENTRY_ORG=$SENTRY_ORG \
    SENTRY_PROJECT=$SENTRY_PROJECT \
    SENTRY_URL=$SENTRY_URL \
    SENTRY_RELEASE=$SENTRY_RELEASE

# The Sentry auth token comes in as a BuildKit secret, never a build-arg: build-arg
# values are recorded in the image provenance attestation pushed to public registries.
# Release builds set SENTRY_UPLOAD so a missing secret fails instead of caching a skip.
ARG SENTRY_UPLOAD=
RUN --mount=type=secret,id=sentry_auth_token \
    sentry_auth_token="$(cat /run/secrets/sentry_auth_token 2>/dev/null || true)" && \
    if [ -n "${SENTRY_UPLOAD}" ] && [ -z "$sentry_auth_token" ]; then \
      echo "SENTRY_UPLOAD is set but the sentry_auth_token secret is empty" >&2; exit 1; \
    fi && \
    ./scripts/prebuild.sh && \
    SENTRY_AUTH_TOKEN="$sentry_auth_token" ./scripts/configure-sentry.sh && \
    flutter build web --release --source-maps --no-web-resources-cdn \
    --dart-define=SENTRY_RELEASE=$SENTRY_RELEASE \
    --dart-define=SENTRY_DIST=$GITHUB_SHA && \
    SENTRY_AUTH_TOKEN="$sentry_auth_token" ./scripts/run-sentry.sh

FROM nginx:alpine@sha256:df221db836e1754089190208cee7eeda94f233197056426eda74a43ab1abeac2
RUN apk add gzip
COPY --from=build-env /app/server/nginx.conf /etc/nginx
COPY --from=build-env /app/server/csp-headers.conf.template /etc/nginx/csp-headers.conf.template
COPY --from=build-env --chmod=755 /app/server/docker-entrypoint.d/ /docker-entrypoint.d/
COPY --from=build-env /app/build/web /usr/share/nginx/html
ENV CSP_FRAME_ANCESTORS="'self'"
ENV CSP_FRAME_SRC=""
ENV CSP_SCRIPT_SRC=""
ENV CSP_CONNECT_SRC=""
ENV CSP_IMG_SRC=""
ENV CSP_REPORT_URI=""
RUN /docker-entrypoint.d/21-render-csp-headers.sh && /docker-entrypoint.d/25-csp-report-uri.sh && nginx -t
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
