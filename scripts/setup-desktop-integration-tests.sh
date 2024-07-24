#!/usr/bin/env sh

echo "$FRONTEND_CONFIG" > env.file
mkdir -p src/main/resources
echo "$FRONTEND_CREDS" > src/main/resources/config.properties
