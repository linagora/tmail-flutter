#!/bin/bash

# Define users and folders
users=("alice" "bob" "brian" "charlotte" "david" "emma")
bobFolders=("Search Emails" "Forward Emails" "Disposition" "MailBase64" "Calendar")

# Add users
for user in "${users[@]}"; do
  james-cli AddUser "$user@example.com" "$user"
done

# Create folders for user Bob
for folderName in "${bobFolders[@]}"; do
  echo "Creating $folderName folder for user bob"
  james-cli CreateMailbox \#private "bob@example.com" "$folderName"
done

# Function to check if mailbox exists
function wait_for_mailbox() {
  local email="$1"
  local folder="$2"
  local retries=10
  local count=0

  while [ $count -lt $retries ]; do
    if james-cli ListUserMailboxes "$email" | grep -q "$folder"; then
      echo "Mailbox '$folder' for user '$email' is ready."
      return 0
    fi
    echo "Waiting for mailbox '$folder' to be created..."
    sleep 2
    ((count++))
  done

  echo "Error: Mailbox '$folder' for user '$email' was not created in time."
  return 1
}

# Ensure all mailboxes exist before importing emails
for folderName in "${bobFolders[@]}"; do
  wait_for_mailbox "bob@example.com" "$folderName" || exit 1
done

# For test search email with sort order
# Import emails into 'Search Emails' folder for user Bob
for eml in {0..4}; do
  echo "Importing $eml.eml into 'Search Emails' folder for user bob"
  james-cli ImportEml \#private "bob@example.com" "Search Emails" "/root/conf/integration_test/eml/search_email_with_sort_order/$eml.eml"
done

# For test forward email
# Import emails into 'Forward Emails' folder for user Bob
echo "Importing forward.eml into 'Forward Emails' folder for user bob"
james-cli ImportEml \#private "bob@example.com" "Forward Emails" "/root/conf/integration_test/eml/forward_email/forward.eml"

# For test email with no-disposition inline image
# Import email into 'Disposition' folder for user Bob
echo "Importing no_disposition_inline.eml into 'Disposition' folder for user bob"
james-cli ImportEml \#private "bob@example.com" "Disposition" "/root/conf/integration_test/eml/no_disposition_inline/no_disposition_inline.eml"

# For test reply email with image base64
# Import email into 'MailBase64' folder for user Bob
echo "Importing 0.eml into 'MailBase64' folder for user bob"
james-cli ImportEml \#private "bob@example.com" "MailBase64" "/root/conf/integration_test/eml/reply_email_with_image_base64/0.eml"

# For test calendar event
# Import email into 'Calendar' folder for user Bob
echo "Importing calendar eml into 'Calendar' folder for user bob"
james-cli ImportEml \#private "bob@example.com" "Calendar" "/root/conf/integration_test/eml/calendar/calendar_counter.eml"