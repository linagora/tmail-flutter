#!/usr/bin/env bash

docker run -d -p 2023:80 -v "$PWD"/env.file:/usr/share/nginx/html/assets/env.file linagora/tmail-web
curl localhost:2023

mvn test
