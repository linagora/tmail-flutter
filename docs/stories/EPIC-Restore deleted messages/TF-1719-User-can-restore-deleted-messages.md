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
- When the recovery is in progress, there will be a progess bar running at top of screen that does not block user's actions. User can continue using Tmail while the recovery process is runing. 
- When the recovery is completed, the system will restore 5 (configurable by system) first messages in the result to a new system folder:"Recovered messages". There will be a toast message: "Recover deleted messages successfully". And an Open button. When I click this button, I am redirected to the folder Restored message 
- In this new system folder, I can see the list of recovered deleted messages:
   - With the folder, I can do actions :"Open in new tab"/"Mark as read"
   - With the emails, I can do actions: Spam/Unspam, Star/Unstar, Read/Unread, Move, Delete, Open in a new tab, Create a new rule with this email .

[Back to Summary](#summary)

## Screenshots

![Group 791 (2)](https://github.com/linagora/tmail-flutter/assets/68209176/20d9de2c-e183-4fe4-89b6-1adacedd2cc4)

![Group 792 (3)](https://github.com/linagora/tmail-flutter/assets/68209176/d8d3cd22-5392-49fa-8b8c-249d782f2d6c)

![Group 806](https://github.com/linagora/tmail-flutter/assets/68209176/f5b0b8fd-db61-44c8-a523-aa96200417f1)

![Group 807](https://github.com/linagora/tmail-flutter/assets/68209176/d7a65e38-e399-4719-a97d-6eee4a972ad3)


[Back to Summary](#summary)

## Misc

None

[Back to Summary](#summary)
