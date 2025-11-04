# syntax=docker/dockerfile:1.4
# ↑ Required for BuildKit features like --mount=type=ssh

ARG FLUTTER_VERSION=3.32.8

# ──────────────────────────────
# Stage 1 – Build Flutter Web App
# ──────────────────────────────
FROM --platform=amd64 ghcr.io/instrumentisto/flutter:${FLUTTER_VERSION} AS build-env

# Enable SSH forwarding for private git dependencies (git@github.com)
WORKDIR /app
COPY . .

# Fetch pub dependencies for all modules defined in prebuild.sh
# The SSH mount allows access to private repos during flutter pub get
RUN --mount=type=ssh \
    mkdir -p /root/.ssh && \
    ssh-keyscan github.com >> /root/.ssh/known_hosts && \
    # Fetch dependencies for each module
    for mod in core model contact forward rule_filter fcm email_recovery server_settings cozy; do \
      cd /app/$mod && flutter pub get; \
    done && \
    # Fetch dependencies for the main project
    cd /app && flutter pub get

# Run code generation and localization steps
RUN ./scripts/prebuild.sh

# Build Flutter Web in release mode
RUN flutter build web --release

# ──────────────────────────────
# Stage 2 – Runtime Image
# ──────────────────────────────
FROM nginx:alpine

# Install gzip for pre-compression
RUN apk add --no-cache gzip

# Copy Nginx configuration and compiled web assets
COPY --from=build-env /app/server/nginx.conf /etc/nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

EXPOSE 80

# Re-compress assets before starting Nginx
CMD gzip -k -r -f /usr/share/nginx/html/ && nginx -g 'daemon off;'
