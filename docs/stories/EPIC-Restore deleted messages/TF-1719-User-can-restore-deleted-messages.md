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
   - Recipients: I can input name/email address, the system will display a suggestion list of matched emails. I can select from the list or input the recipients mannually 
   - Senders:  I can input name/email address, the system will display a suggestion list of matched emails. I can select from the list or input the senders mannually
   - Has attachment: a Checkbox. If it is checked, the system will find and restore email which contains attachments
- After input conditions, I click button Restore, the system will search for matched messages in in deleted vault. 
- When the search is in progress, there will be a toast message :"Recovery is in progress and might take time. Please wait a few minutes." 
- When the search is completed, the system will restore 5 (configurable by system) first messages in the result to a new system folder:"Restored messages"
- In this new system folder, I can see the list of recovered deleted messages:
   - With the folder, I can do actions :"Open in new tab"/"Mark as read"
   - With the emails, I can do actions: Spam/Unspam, Star/Unstar, Read/Unread, Move, Delete, Open in a new tab, Create a new rule with this email .

[Back to Summary](#summary)

## Screenshots

![Group 791](https://github.com/linagora/tmail-flutter/assets/68209176/6335f01f-22f1-4e08-ac16-ad9f58040983)

![Group 792](https://github.com/linagora/tmail-flutter/assets/68209176/9e18ec72-f21b-48af-aa10-ddb807179fdc)

![Group 797](https://github.com/linagora/tmail-flutter/assets/68209176/27d26826-3c35-4ecd-a850-91d8419ae02e)

![Group 794 (1)](https://github.com/linagora/tmail-flutter/assets/68209176/da4cece1-ec33-4c65-9a66-bc0d00e6af99)



[Back to Summary](#summary)

## Misc

None

[Back to Summary](#summary)
