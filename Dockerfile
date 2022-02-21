#Stage 1 - Install dependencies and build the app
FROM debian:latest AS build-env

# Install flutter dependencies
RUN apt-get update
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libglu1-mesa fonts-droid-fallback python3
RUN apt-get clean

# Install flutter
RUN curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_2.10.0-stable.tar.xz | tar -C /opt -xJ

# Set flutter path
# RUN /usr/local/flutter/bin/flutter doctor -v
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor -v

# Enable flutter web
RUN flutter channel master
RUN flutter upgrade
RUN flutter config --enable-web

# Copy files to container and build
RUN mkdir /app/
COPY . /app/
WORKDIR /app/

# Record the exposed port
EXPOSE 3000

RUN ["chmod", "+x", "/app/server/startup.sh"]
ENTRYPOINT [ "/app/server/startup.sh"]