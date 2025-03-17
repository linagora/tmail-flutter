# Reading emails {#read}

This page explains how to read your emails and explains which actions can be performed on your emails.

**On Web**

![Group 22 (2)](https://github.com/user-attachments/assets/c563f638-b778-4541-b3b4-ac98562cb396)


**On mobile**

![Frame 24 (3)](https://github.com/linagora/tmail-flutter/assets/68209176/2ccd6fb9-96cc-4a9e-b89c-783c09fa0dc6)


The right panels allows one to read his email. It shows emails within a folder, organized by time.

Here are the information added to each mails in the mailbox listing:

 - (1) `From`: the identity (firstname, lastname and mail address) of the sender of the email.
 - (2) The `date` at which the email was sent
 - (3) The `subject` of the email
 - (4) If the email has `attachments` then the attachment icom will be displayed
 - (5) If the email is `starred`
 - (6) If the email is read or not
 - (7) If the email forwarded
 - (8) If you answered to this mail
 - (9) If you both answered and forwarded the mail

Note the button to reload and look for new emails on the server.
For mobile, you can scroll down to reload and get the new emails from the server.

## Open en email

**On web**

You can open emails by clicking on them:

![Group 25 (2)](https://github.com/user-attachments/assets/e48b113e-9ef8-4fa6-bf04-f79e3bd7f193)


**On mobile**

![Frame 25](https://github.com/linagora/tmail-flutter/assets/68209176/327e0aee-1513-4000-b524-58b188250112)


Here are the information you can see when opening an email:

 - (1) `From`: the identity (firstname, lastname and mail address) of the sender of the email.
 - (2) `To`: the identities of the people this email is written to.
 - (3) `Cc`: the identities of the people in copy of this email
 - (4) The `date` at which the email was sent
 - (5) The `folder` in which the email is located
 - (6) The `subject` of the email
 - (7) The `attachments` of the email. You can download them by clicking them.
 - (8) The body of the email, containing its main message. Long emails might require you to scroll in order to read them fully.
 - (9) If the email is `starred`
 - (10) The navigation arrows allowing to go directly to next or previous email.

If the sender requested a read receipt, then Twake-Mail will prompt you to send the receipt when you open the email. Twake-Mail will remember your decision.

![image 59](https://github.com/linagora/tmail-flutter/assets/68209176/47dfeb99-1801-419f-8d29-6bd84e5a3cb5)

![Frame 26](https://github.com/linagora/tmail-flutter/assets/68209176/24ba1c39-e0de-4900-ac6a-9003e822e173)



## Email actions

**On web**

When reading emails, a user can perform some actions on it.

Quick actions are available in one click and are shown when putting the mouse on an email item:

![Per email action](images/action1.png)

Available actions includes:

 - (1) Open this message in a new tab (instead than on the current one)
 - (2) Mark as read / mark as unread
 - (3) Move this message into another folder. It opens a dialog window to let you choose the target folder.
Note that on web this action can be performed via a drag and drop: take the email and drop it into the target mailbox.
 - (4) Move this email to the tash. Same as (3) but you do not have to select the target folder. Note that emails can only be deleted in the Trash (this action is then replaced by "Delete Permanently"
in this mailbox).
 - (5) Extra actions are also available: Open this email in a new tab and report this email as Spam (which moves this email into the Spam mailbox. THis email will eventually be reported as Spam to
our anti-spam).
 - (6) Mark this message as `starred`

One can select email by clicking on the sender icon:

![Group 2](https://github.com/user-attachments/assets/023f8b4d-9439-4f7f-af40-cc0378f2b187)


Actions on selected emails are applied on all selected mails and include:

 - (1) Mark as read / mark as unread
 - (2) Mark this message as `starred`
 - (3) Move this message into another folder. Note that on web this action can be performed via a drag and drop: take the email and drop it into the target mailbox.
 - (4) Report this email as Spam (which moves this email into the Spam mailbox. THis email will eventually be reported as Spam to our anti-spam).
 - (5) Move this email to the tash. Same as (3) but you do not have to select the target folder. Note that emails can only be deleted in the Trash (this action is then replaced by "Delete Permanently"
in this mailbox).

Actions can also be performed on opened emails:

![Group 5](https://github.com/user-attachments/assets/cfb4c6ed-9746-44d7-8fdb-2331cd0d213d)


Actions on opened email include:

 - (1) Reply all: It opens a composer, adds `Re:` prefix before the topics, set the sender and other recipients of the previous email as a `To` recipients and quotes the previous email.
 - (2) Reply to list:Allows you to reply to all recipients included in the mailing list 
 - (3) Reply: It opens a composer, adds `Re:` prefix before the topics, set the sender email and the sender of the previous as a "To" recipient and quotes the previous email
 - (4) Forward: It opens a composer, adds `Fwd:` prefix before the topics, quotes the previous email, and let you sepcify the recipients you want.
 - (5) New message:It opens a new composer 
 - (6) Move this message into another folder. It opens a dialog window to let you choose the target folder.
 - (7) Mark this message as `starred`
 - (8) Print: Clicking it will open the print preview window.
 - (9) Move this email to the trash. Same as (6) but you do not have to select the target folder. Note that emails can only be deleted in the Trash (this action is then replaced by "Delete Permanently"
in this mailbox).

Extra actions are also available. They are detailed below:

 - (10) Mark as read / mark as unread
 - (11) Report this email as Spam (which moves this email into the Spam mailbox. This email will eventually be reported as Spam to our anti-spam).
 - (12) Create an [email rule](profile.md#email-rule) for this email. Email rules allow to declare criteria upon which matching emails would be moved to a folder.
 - (13) Unsubscribe: Click this button to request removal from the sender’s mailing list. A popup will appear to confirm the unsubscription. 
 - (14) Archive message: This action will move the message to Archive Folder
 - (15) Download message as eml
 - (16) Edit as a new email: A new email composer will open with the original email's content prefilled. User can ddit the subject, recipients, or message body as needed.

**On mobile**

You can select email(s) by clicking on the sender icon:

![Frame 27](https://github.com/linagora/tmail-flutter/assets/68209176/3bab5ff7-be24-4886-8919-683c422164e5)

Actions on selected emails are applied on all selected mails and include:

 - (1) Mark as read / mark as unread
 - (2) Mark this message as `starred`
 - (3) Move this message into another folder. Note that on web this action can be performed via a drag and drop: take the email and drop it into the target mailbox.
 - (4) Report this email as Spam (which moves this email into the Spam mailbox. THis email will eventually be reported as Spam to our anti-spam).
 - (5) Move this email to the trash. Same as (3) but you do not have to select the target folder. Note that emails can only be deleted in the Trash (this action is then replaced by "Delete Permanently"
in this mailbox).

Actions can also be performed on opened emails:

![Frame 1](https://github.com/user-attachments/assets/7e76612a-054b-45a1-9f31-18141849de8f)


- (1) Reply all: It opens a composer, adds `Re:` prefix before the topics, set the sender email and all other recipients of the previous  as a `To` recipients and quotes the previous email.
- (2) Reply to list: If the email was sent to a mailing list (e.g., team@company.com), clicking "Reply to List" will send your response to the entire list instead of just the sender.
- (3) Reply : It opens a composer, adds `Re:` prefix before the topics, set the sender email and the sender of the previous as a "To" recipient and quotes the previous email
- (4) Forward:  It opens a composer, adds `Fwd:` prefix before the topics, quotes the previous email, and let you sepcify the recipients you want.
- (5) New message: It opens a new composer 
- (6) Move this message into another folder. It opens a dialog window to let you choose the target folder.
- (7) Mark this message as `starred`
- (8) Move this email to the trash. Same as (3) but you do not have to select the target folder. Note that emails can only be deleted in the Trash (this action is then replaced by "Delete Permanently"
in this mailbox).

 Extra actions are also available when you click on 3-dot button on top right. They are detailed below:

![Frame 2](https://github.com/user-attachments/assets/0b8d16fe-ed63-48fc-b170-a0787459f7e5)


 - (9) Mark as read / mark as unread
 - (10) Report this email as Spam (which moves this email into the Spam mailbox. This email will eventually be reported as Spam to our anti-spam).
 - (11) Create an [email rule](profile.md#email-rule) for this email. Email rules allow to declare criteria upon which matching emails would be moved to a folder.
 - (12) Unsubscribe: Click this button to request removal from the sender’s mailing list. A popup will appear to confirm the unsubscription.
 - (13) Archive message: This action will move the message to Archive folder.
 - (14) Edit as a new message: A new email composer will open with the original email's content prefilled. User can ddit the subject, recipients, or message body as needed.


