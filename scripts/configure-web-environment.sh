#!/usr/bin/env sh

set -eux
sed -i "s|SERVER_URL=.*|SERVER_URL=https://apisix.upn.integration-open-paas.org/|g" env.file
sed -i "s|DOMAIN_REDIRECT_URL=.*|DOMAIN_REDIRECT_URL=https://$GITHUB_REPOSITORY_OWNER.github.io/${GITHUB_REPOSITORY##*/}/$FOLDER|g" env.file
echo "URL=https://$GITHUB_REPOSITORY_OWNER.github.io/${GITHUB_REPOSITORY##*/}/$FOLDER" >> $GITHUB_OUTPUT
