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

# Set directory to Copy App
WORKDIR /app

COPY . .

# Precompile tmail flutter
RUN ./scripts/prebuild.sh

# Build flutter for web (with source maps for Sentry)
RUN flutter build web --release --source-maps

# Upload source maps to Sentry when all required variables are available.
# The build will NOT fail if this step is unavailable.
RUN if [ -n "$SENTRY_AUTH_TOKEN" ] && [ -n "$SENTRY_ORG" ] && [ -n "$SENTRY_PROJECT" ] && [ -n "$SENTRY_RELEASE" ]; then \
      echo "Sentry configuration detected, uploading sourcemaps for release $SENTRY_RELEASE" && \
      export SENTRY_AUTH_TOKEN="$SENTRY_AUTH_TOKEN" && \
      export SENTRY_ORG="$SENTRY_ORG" && \
      export SENTRY_PROJECT="$SENTRY_PROJECT" && \
      export SENTRY_RELEASE="$SENTRY_RELEASE" && \
      [ -n "$SENTRY_URL" ] && export SENTRY_URL="$SENTRY_URL" || true && \
      echo "Creating sentry.properties to enable sourcemap upload..." && \
      { \
        echo "defaults.org=$SENTRY_ORG"; \
        echo "defaults.project=$SENTRY_PROJECT"; \
        echo "auth.token=$SENTRY_AUTH_TOKEN"; \
        echo "release.version=$SENTRY_RELEASE"; \
        echo "release.associateCommits=false"; \
        if [ -n "$SENTRY_URL" ]; then \
          echo "defaults.url=$SENTRY_URL"; \
        fi; \
        echo "upload.sourcemaps=true"; \
        echo "upload.sourcemaps.path=build/web"; \
        echo "upload.sourcemaps.urlPrefix=~/"; \
      } > sentry.properties && \
      echo "Uploading sourcemaps to Sentry using sentry_dart_plugin..." && \
      dart run sentry_dart_plugin --ignore-missing || echo "Sentry sourcemaps upload failed, continuing" && \
      rm -f sentry.properties && \
      echo "Sourcemap upload completed"; \
    else \
      echo "Sentry configuration not complete, skipping sourcemap upload"; \
    fi || echo "Sentry sourcemap upload step failed, continuing build"

# Stage 2 - Create the run-time image
FROM nginx:alpine
RUN apk add gzip
COPY --from=build-env /app/server/nginx.conf /etc/nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Record the exposed port
EXPOSE 80

# Before stating NGinx, re-zip all the content to ensure customizations are propagated
CMD gzip -k -r -f /usr/share/nginx/html/ && nginx -g 'daemon off;'
