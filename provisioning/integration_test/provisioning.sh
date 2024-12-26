#!/bin/bash

# Define users and folders
users=("alice" "bob" "brian" "charlotte" "david" "emma")
bobFolders=("Search Emails" "Forward Emails" "Disposition")

# Add users
for user in "${users[@]}"; do
  james-cli AddUser "$user@example.com" "$user"
done

# Create folders for user Bob
for folderName in "${bobFolders[@]}"; do
  echo "Creating $folderName folder for user bob"
  james-cli CreateMailbox \#private "bob@example.com" "$folderName" &
done

# For test search email with sort order
# Import emails into 'Search Emails' folder for user Bob
for eml in {0..4}; do
  echo "Importing $eml.eml into 'Search Emails' folder for user bob"
  james-cli ImportEml \#private "bob@example.com" "Search Emails" "/root/conf/integration_test/eml/search_email_with_sort_order/$eml.eml" &
done

# For test forward email
# Import emails into 'Forward Emails' folder for user Bob
echo "Importing 0.eml into 'Forward Emails' folder for user bob"
james-cli ImportEml \#private "bob@example.com" "Forward Emails" "/root/conf/integration_test/eml/forward_email/0.eml"

# For test email with no-disposition inline image
# Import email into 'Disposition' folder for user Bob
echo "Importing no_disposition_inline.eml into 'Disposition' folder for user bob"
james-cli ImportEml \#private "bob@example.com" "Disposition" "/root/conf/integration_test/eml/no_disposition_inline/no_disposition_inline.eml"