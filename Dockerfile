ARG FLUTTER_VERSION=3.32.8

# Sentry build-time configuration (used only during the build stage)
# These values are provided via GitHub Actions secrets and are NOT persisted
# into the final runtime image.
ARG SENTRY_AUTH_TOKEN
ARG SENTRY_ORG
ARG SENTRY_PROJECT
ARG SENTRY_URL
ARG SENTRY_RELEASE

# Stage 1 - Install dependencies and build the app
# This matches the flutter version on our CI/CD pipeline on Github
FROM --platform=amd64 ghcr.io/instrumentisto/flutter:${FLUTTER_VERSION} AS build-env

# Re-declare ARGs in this stage to make them available in RUN commands
ARG SENTRY_AUTH_TOKEN
ARG SENTRY_ORG
ARG SENTRY_PROJECT
ARG SENTRY_URL
ARG SENTRY_RELEASE
ARG VCS_REF

# Set directory to Copy App
WORKDIR /app

COPY . .

RUN ls -la

# Precompile tmail flutter
RUN ./scripts/prebuild.sh

RUN curl -sL https://sentry.io/get-cli/ | bash

RUN sentry-cli releases new "$SENTRY_RELEASE" || true

# Build flutter for web (with source maps for Sentry)
RUN flutter build web --release --source-maps --dart-define=SENTRY_RELEASE=$SENTRY_RELEASE

# Upload source maps to Sentry when all required variables are available.
# The build will NOT fail if this step is unavailable.
RUN sentry-cli releases set-commits "$SENTRY_RELEASE" --commit $VCS_REF

RUN sentry-cli sourcemaps upload build/web \
        --url-prefix "~/" \
        --validate && \
    sentry-cli releases finalize "$SENTRY_RELEASE"

# Stage 2 - Create the run-time image
FROM nginx:alpine
RUN apk add gzip
COPY --from=build-env /app/server/nginx.conf /etc/nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Record the exposed port
EXPOSE 80

# Before stating NGinx, re-zip all the content to ensure customizations are propagated
CMD gzip -k -r -f /usr/share/nginx/html/ && nginx -g 'daemon off;'
