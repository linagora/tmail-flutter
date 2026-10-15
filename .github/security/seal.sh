#!/usr/bin/env bash
# Encrypts stdin to <out>: a random AES key wrapped with the report RSA public key.
# Output: line 1 = wrapped key, line 2 = ciphertext (both base64). build-report.sh opens it.
# Usage: seal.sh <out>   env: REPORT_PUBLIC_KEY (PEM)
set -euo pipefail
out=${1:?usage: seal.sh <out>}
K=$(openssl rand -hex 32); export K
{
  printf '%s' "$K" | openssl pkeyutl -encrypt -pubin -inkey <(printf '%s\n' "$REPORT_PUBLIC_KEY") \
    -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256 | openssl base64 -A
  echo
  openssl enc -aes-256-cbc -pbkdf2 -salt -a -A -pass env:K
} > "$out"
