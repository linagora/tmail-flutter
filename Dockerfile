ARG FLUTTER_VERSION=3.10.6
# Stage 1 - Install dependencies and build the app
# This matches the flutter version on our CI/CD pipeline on Github
FROM --platform=amd64 ghcr.io/cirruslabs/flutter:${FLUTTER_VERSION} AS build-env

# Set directory to Copy App
WORKDIR /app

COPY . .

# Precompile tmail flutter
RUN bash prebuild.sh
# Build flutter for web
RUN flutter build web --release

# Stage 2 - Create the run-time image
FROM nginx:alpine
RUN apk add gzip
COPY --from=build-env /app/server/nginx.conf /etc/nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Record the exposed port
EXPOSE 80

# Before stating NGinx, re-zip all the content to ensure customizations are propagated
CMD gzip -k -r -f /usr/share/nginx/html/ && nginx -g 'daemon off;'
