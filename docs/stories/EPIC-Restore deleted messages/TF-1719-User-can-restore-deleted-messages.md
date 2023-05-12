# Summary

* [Related EPIC](#related-epic)
* [Definition](#definition)
* [Screenshots](#screenshots)
* [Misc](#misc)

## Related EPIC
https://github.com/linagora/tmail-flutter/issues/1719

## Definition

- Given that I am a Tmail user and I have logged in successfully
- When I click on three-dot button of folder Trash, I can see a new option in context menu: Recover deleted messages 
- I select this option, a popup will be opened:
- In the popup, I can input fields:
   - Deletion date: 
      + Default option is "Last 1 year"
      + I can select other options: Last 7 days, Last 30 days, Last 6 months, Custom range 
      + When I select Custom range, a Date picker will be displayed that allow me to select From date and To date.
      + The date range is limited between today to one year ago. 
   - Reception date: 
      + Default option is "All time"
      + I can select other options: Last 7 days, Last 30 days, Last 6 months, Last year, Custom range 
      + When I select Custom range, a Date picker will be displayed that allow me to select From date and To date.
      + The date range is not limited 
   - Subject: a text field 
   - Recipients: I can input name/email address, the system will display a suggestion list of matched emails. I can select from the list or input the recipients mannually. I can input multiple recipients.
   - Sender:  I can input name/email address, the system will display a suggestion list of matched emails. I can select from the list or input the sender mannually. I can input only 1 sender.
   - Has attachment: a Checkbox. If it is checked, the system will find and restore email which contains attachments
- After input conditions, I click button Restore, the system will search for matched messages in in deleted vault. 
- When the search is in progress, there will be a progess bar with a message :"Recovery is in progress and might take time. Please wait a few minutes."  If I click Cancel button, the restoring process stops immediately. When I click on Close button, the popup is close but the recovery is still in progress. 
- When the search is completed, the system will restore 5 (configurable by system) first messages in the result to a new system folder:"Restored messages". There will be a toast message: "Restore deleted messages successfully".
- In this new system folder, I can see the list of recovered deleted messages:
   - With the folder, I can do actions :"Open in new tab"/"Mark as read"
   - With the emails, I can do actions: Spam/Unspam, Star/Unstar, Read/Unread, Move, Delete, Open in a new tab, Create a new rule with this email .

[Back to Summary](#summary)

## Screenshots

![Group 791](https://github.com/linagora/tmail-flutter/assets/68209176/6335f01f-22f1-4e08-ac16-ad9f58040983)

![Group 792 (1)](https://github.com/linagora/tmail-flutter/assets/68209176/9274a92c-1e22-4a94-b407-4c0f139c1e35)

![Group 797 (2)](https://github.com/linagora/tmail-flutter/assets/68209176/8f8cdc7f-6f08-40c7-880f-dc29ecb66f81)

![Group 799](https://github.com/linagora/tmail-flutter/assets/68209176/3cbfc742-2c8c-4097-99cc-0593dd9b337f)


[Back to Summary](#summary)

## Misc

None

[Back to Summary](#summary)
