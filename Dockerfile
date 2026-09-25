# syntax=docker/dockerfile:1
ARG FLUTTER_VERSION=3.38.9

FROM --platform=amd64 ghcr.io/instrumentisto/flutter:${FLUTTER_VERSION} AS build-env

# SENTRY_AUTH_TOKEN is a secret: it is provided as a BuildKit secret
# (id=sentry_auth_token), never as a build argument, which would be
# recorded in the image history and in the provenance attestation.
ARG SENTRY_ORG
ARG SENTRY_PROJECT
ARG SENTRY_URL
ARG SENTRY_RELEASE
ARG VCS_REF
ARG GITHUB_SHA

WORKDIR /app
COPY . .

ENV GITHUB_SHA=$GITHUB_SHA \
    SENTRY_ORG=$SENTRY_ORG \
    SENTRY_PROJECT=$SENTRY_PROJECT \
    SENTRY_URL=$SENTRY_URL \
    SENTRY_RELEASE=$SENTRY_RELEASE

RUN --mount=type=secret,id=sentry_auth_token \
    ./scripts/prebuild.sh && \
    ./scripts/configure-sentry.sh && \
    flutter build web --release --source-maps --no-web-resources-cdn \
    --dart-define=SENTRY_RELEASE=$SENTRY_RELEASE \
    --dart-define=SENTRY_DIST=$GITHUB_SHA && \
    SENTRY_AUTH_TOKEN="$(cat /run/secrets/sentry_auth_token 2>/dev/null || true)" ./scripts/run-sentry.sh

FROM nginx:alpine
RUN apk add gzip
COPY --from=build-env /app/server/nginx.conf /etc/nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD gzip -k -r -f /usr/share/nginx/html/ && nginx -g 'daemon off;'