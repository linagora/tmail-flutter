# Stage 1 - Install dependencies and build the app
# This matches the flutter version on our CI/CD pipeline on Github
FROM cirrusci/flutter:3.7.5 AS build-env

# Set directory to Copy App
WORKDIR /app

COPY . .

# Precompile tmail flutter
RUN bash prebuild.sh && flutter build web --profile

# Stage 2 - Minify the js files
FROM node:alpine AS minify-env

RUN npm install uglify-js -g
#ADD /source /tmp/web
COPY --from=build-env /app/build/web /tmp/web
RUN cd /tmp/web && for f in main.dart.js *.js; do uglifyjs $f -c toplevel,sequences=false,conditionals=true,booleans=true -m -o $f; done

# Stage 3 - Create the run-time image
FROM nginx:mainline
RUN chmod -R 755 /usr/share/nginx/html && apt install -y gzip
COPY --from=build-env /app/server/nginx.conf /etc/nginx
COPY --from=minify-env /tmp/web /usr/share/nginx/html

# Record the exposed port
EXPOSE 80

# Before stating NGinx, re-zip all the content to ensure customizations are propagated
CMD gzip -k -r -f /usr/share/nginx/html/ && nginx -g 'daemon off;'
