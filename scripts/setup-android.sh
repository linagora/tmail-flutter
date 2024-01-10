#!/usr/bin/env sh

echo "$PLAY_STORE_UPLOAD_KEY_BASE64" | base64 --decode > app/keystore.jks
echo "$PLAY_STORE_KEY_INFO_BASE64" | base64 --decode > key.properties
