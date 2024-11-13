#!/bin/bash

# Define users and folders
users=("alice" "bob" "brian" "charlotte" "david" "emma")

# Add users
for user in "${users[@]}"; do
  james-cli AddUser "$user@example.com" "$user"
done

# Create search folder for user Bob
james-cli CreateMailbox \#private "bob@example.com" "search"

# Import emails into search folder for user Bob
for eml in {0..4}; do
  echo "Importing $eml.eml into search folder for user bob"
  james-cli ImportEml \#private "bob@example.com" "search" "/root/conf/integration_test/search_email_with_sort_order/eml/$eml.eml" &
done
