#!/usr/bin/env bash

docker run -d -p 2023:80 --name tmail-web -v "$(pwd)/env.file:/usr/share/nginx/html/assets/env.file" linagora/tmail-web
mvn test
