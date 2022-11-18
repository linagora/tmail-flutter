#Stage 1 - Install dependencies and build the app
FROM debian:latest AS build-env

ENV FLUTTER_CHANNEL="stable"
ENV FLUTTER_VERSION="3.0.1"
ENV FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/$FLUTTER_CHANNEL/linux/flutter_linux_$FLUTTER_VERSION-$FLUTTER_CHANNEL.tar.xz"
ENV FLUTTER_HOME="/opt/flutter"

ENV PATH "$PATH:$FLUTTER_HOME/bin"

# Prerequisites
RUN apt update && apt install -y curl git unzip xz-utils zip gzip libglu1-mesa \
 && mkdir -p $FLUTTER_HOME \
 && curl -o flutter.tar.xz $FLUTTER_URL \
 && tar xf flutter.tar.xz -C /opt \
 && rm flutter.tar.xz \
 && flutter doctor \
 && rm -rf /var/lib/{apt,dpkg,cache,log}

# Set directory to Copy App
WORKDIR /app

COPY . .

# Precompile tmail flutter
RUN bash prebuild.sh && flutter build web --profile

# Stage 2 - Create the run-time image
FROM nginx:mainline
RUN chmod -R 755 /usr/share/nginx/html && apt install -y gzip
COPY --from=build-env /app/server/nginx.conf /etc/nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Record the exposed port
EXPOSE 80

# Before stating NGinx, re-zip all the content to ensure customizations are propagated
CMD gzip -k -r /usr/share/nginx/html/ && nginx -g 'daemon off;'
