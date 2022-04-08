#Stage 1 - Install dependencies and build the app
FROM debian:latest AS build-env

ENV FLUTTER_CHANNEL="stable"
ENV FLUTTER_VERSION="2.10.0"
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
RUN cd core \
  && flutter pub get \
  && cd ../model \
  && flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs \
  && cd .. \
  && flutter pub get && flutter pub run intl_generator:extract_to_arb --output-dir=./lib/l10n lib/main/localizations/app_localizations.dart \
  && flutter pub get && flutter pub run intl_generator:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/main/localizations/app_localizations.dart lib/l10n/intl*.arb \
  && flutter build web --profile \
  && gzip -r -k /app/build/web

# Stage 2 - Create the run-time image
FROM nginx:stable
RUN chmod -R 755 /usr/share/nginx/html
COPY --from=build-env /app/server/nginx.conf /etc/nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Record the exposed port
EXPOSE 80

ENTRYPOINT ["nginx", "-g", "daemon off;"]