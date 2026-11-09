#!/bin/bash

WEBADMIN="http://localhost:8000"
BACKUP="/root/conf/integration_test/backup.zip"
DOMAIN="example.com"
USERS=("alice" "bob" "brian" "charlotte" "david" "emma")

# Create domain
curl -s -XPUT "$WEBADMIN/domains/$DOMAIN"

# Create users in parallel
for user in "${USERS[@]}"; do
  email="$user@$DOMAIN"
  curl -s -XPUT "$WEBADMIN/users/$email" \
    -d '{"password":"'"$user"'"}' \
    -H "Content-Type: application/json" 
done
wait

# Restore mailbox backup for bob
echo "Restoring mailbox for bob..."
curl -s -XPOST "$WEBADMIN/users/bob@$DOMAIN/mailboxes?task=restore&force=true" \
  --data-binary "@$BACKUP" \
  -H "Content-Type: application/zip" 
wait

# Create team mailbox
curl -s -XPUT "$WEBADMIN/domains/$DOMAIN/team-mailboxes/bob-guests" 
curl -s -XPUT "$WEBADMIN/domains/$DOMAIN/team-mailboxes/bob-guests/members/bob@$DOMAIN?role=member" 
curl -s -XPUT "$WEBADMIN/domains/$DOMAIN/team-mailboxes/bob-guests/members/alice@$DOMAIN?role=member"

# Let bob open alice's mailbox (delegation)
delegation_status=$(curl -s -o /dev/null -w "%{http_code}" -XPUT "$WEBADMIN/users/alice@$DOMAIN/authorizedUsers/bob@$DOMAIN")
if [ "$delegation_status" != "200" ] && [ "$delegation_status" != "201" ] && [ "$delegation_status" != "204" ]; then
  echo "Failed to grant delegation: HTTP $delegation_status" >&2
  exit 1
fi

# Set quota for bob
curl -s -XPUT "$WEBADMIN/quota/users/bob@$DOMAIN" \
  -d '{"count":200,"size":50000000}' \
  -H "Content-Type: application/json" &

wait
