ARG FLUTTER_VERSION=3.32.8

FROM --platform=amd64 ghcr.io/instrumentisto/flutter:${FLUTTER_VERSION} AS build-env

ARG SENTRY_AUTH_TOKEN
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

RUN ./scripts/prebuild.sh && \
    flutter build web --release --source-maps --dart-define=SENTRY_RELEASE=$SENTRY_RELEASE && \
    if [ -n "$SENTRY_AUTH_TOKEN" ] && [ -n "$SENTRY_ORG" ] && [ -n "$SENTRY_PROJECT" ] && [ -n "$SENTRY_RELEASE" ]; then \
        echo "Sentry configuration detected, uploading sourcemaps..." && \
        curl -sL https://sentry.io/get-cli/ | SENTRY_CLI_VERSION=2.20.7 bash && \
        sentry-cli releases new "$SENTRY_RELEASE" || true && \
        sentry-cli sourcemaps upload build/web \
            --org "$SENTRY_ORG" \
            --project "$SENTRY_PROJECT" \
            --auth-token "$SENTRY_AUTH_TOKEN" \
            --release "$SENTRY_RELEASE" \
            --dist "$GITHUB_SHA" \
            --url-prefix "~/" \
            --validate \
            --wait || echo "Sentry sourcemaps upload failed, continuing build" && \
        sentry-cli releases finalize "$SENTRY_RELEASE" || echo "Sentry release finalize failed, continuing build"; \
    else \
        echo "Sentry configuration not complete, skipping sourcemap upload"; \
    fi

FROM nginx:alpine
RUN apk add gzip
COPY --from=build-env /app/server/nginx.conf /etc/nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD gzip -k -r -f /usr/share/nginx/html/ && nginx -g 'daemon off;'