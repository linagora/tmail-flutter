ARG FLUTTER_VERSION=3.38.7
ARG APP_VERSION
# Stage 1 - Install dependencies and build the app
# This matches the flutter version on our CI/CD pipeline on Github
FROM --platform=amd64 ghcr.io/instrumentisto/flutter:${FLUTTER_VERSION} AS build-env

# Pass version into build stage
ARG APP_VERSION

# Set directory to Copy App
WORKDIR /app

COPY . .

# Precompile tmail flutter
RUN ./scripts/prebuild.sh
# Build flutter for web (use --build-name if APP_VERSION is set)
RUN if [ -n "$APP_VERSION" ]; then \
      flutter build web --release --build-name="$APP_VERSION"; \
    else \
      flutter build web --release; \
    fi

# Stage 2 - Create the run-time image
FROM nginx:alpine
RUN apk add gzip
COPY --from=build-env /app/server/nginx.conf /etc/nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Record the exposed port
EXPOSE 80

# Before stating NGinx, re-zip all the content to ensure customizations are propagated
CMD gzip -k -r -f /usr/share/nginx/html/ && nginx -g 'daemon off;'
