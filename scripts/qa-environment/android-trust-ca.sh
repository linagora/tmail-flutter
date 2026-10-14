#!/bin/bash
#
# Makes the emulator $ANDROID_SERIAL trust a CA certificate as a system one, until its next boot:
# Android ignores the user CAs for an app without a network security configuration, Flutter's
# dart:io reads /system/etc/security/cacerts and Java (AppAuth) the conscrypt APEX copy of it
# (Android 14+). Both get a tmpfs copy with the CA added, bind mounted in the namespace of zygote,
# hence of the apps started afterwards. Needs `adb root`: an emulator image other than
# google_play. Run again, it adds the CA to the copy already there.
#
#   ANDROID_SERIAL=emulator-5554 scripts/qa-environment/android-trust-ca.sh <ca.pem>
#
set -euo pipefail

CA="${1:?the CA certificate, PEM}"
export ANDROID_SERIAL="${ANDROID_SERIAL:?the emulator, e.g. emulator-5554}"
export PATH="${ANDROID_HOME:-$HOME/Android/Sdk}/platform-tools:$PATH"

# Android names the certificates after their old (MD5) subject hash, OpenSSL after the new one:
# the CA goes under both
HASHES="$(openssl x509 -in "$CA" -noout -subject_hash_old).0 $(openssl x509 -in "$CA" -noout -subject_hash).0"

if [ "$(adb shell id -u | tr -d '\r')" != 0 ]; then
  adb root >/dev/null
  adb wait-for-device
  for _ in $(seq 1 30); do
    [ "$(adb shell id -u 2>/dev/null | tr -d '\r')" = 0 ] && break
    sleep 1
  done
fi
[ "$(adb shell id -u | tr -d '\r')" = 0 ] || { echo "adb root refused on $ANDROID_SERIAL (a google_play image?)" >&2; exit 1; }

adb push "$CA" /data/local/tmp/twake-qa-ca.pem >/dev/null 2>&1
adb shell HASHES="'$HASHES'" sh <<'EOF'
set -e
STORE=/data/local/tmp/twake-qa-cacerts
if ! grep -q " $STORE " /proc/mounts; then
  mkdir -p "$STORE"
  mount -t tmpfs tmpfs "$STORE"
  if [ -d /apex/com.android.conscrypt/cacerts ]; then
    cp /apex/com.android.conscrypt/cacerts/* "$STORE"/
  else
    cp /system/etc/security/cacerts/* "$STORE"/
  fi
fi
for name in $HASHES; do
  cp /data/local/tmp/twake-qa-ca.pem "$STORE/$name"
done
chown root:root "$STORE" "$STORE"/*
chmod 755 "$STORE"
chmod 644 "$STORE"/*
chcon -R u:object_r:system_security_cacerts_file:s0 "$STORE" 2>/dev/null ||
  chcon -R u:object_r:system_file:s0 "$STORE"
# The apps are forked from zygote: its mount namespace is theirs
for zygote in $(pidof zygote64) $(pidof zygote); do
  for target in /system/etc/security/cacerts /apex/com.android.conscrypt/cacerts; do
    [ -d "$target" ] || continue
    if ! nsenter --mount=/proc/$zygote/ns/mnt -- grep -q " $target tmpfs " /proc/self/mounts; then
      nsenter --mount=/proc/$zygote/ns/mnt -- mount --bind "$STORE" "$target"
    fi
  done
done
EOF
echo "    $(basename "$CA") trusted by $ANDROID_SERIAL until its next boot"
