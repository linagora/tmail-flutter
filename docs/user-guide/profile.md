# Profile

After logged in your Tmail account, click on avatar on top right then select option "Manage account"

![image](https://github.com/linagora/tmail-flutter/assets/68209176/f702aeab-b931-4c69-a75e-b6ec73c0cc02)


The profile page allows you to:

 - [Manage your senders identities and signatures](#identities)
 - [Set up email rules to automatically sort your mails](https://github.com/linagora/tmail-flutter/edit/user-guide-skeleton/docs/user-guide/profile.md#email-rules)
 - [Set up forwards to a third party email service](https://github.com/linagora/tmail-flutter/edit/user-guide-skeleton/docs/user-guide/profile.md#forwards)
 - [Enable your vacation mode](https://github.com/linagora/tmail-flutter/edit/user-guide-skeleton/docs/user-guide/profile.md#vacation-mode)
 - [Manage folder visibility](https://github.com/linagora/tmail-flutter/edit/user-guide-skeleton/docs/user-guide/profile.md#folder-visibility)
 - [Change your language settings](https://github.com/linagora/tmail-flutter/edit/user-guide-skeleton/docs/user-guide/profile.md#language-settings)
 - [This menu also enables you to log out from tmail](https://github.com/linagora/tmail-flutter/edit/user-guide-skeleton/docs/user-guide/profile.md#logout)

![image](https://github.com/linagora/tmail-flutter/assets/68209176/16c6182e-f434-43e8-ab45-b4c6d757b1ff)

## Identities

Email identities allow you to manage multiple personas from a single email account. This can be useful for personal, professional, or organizational purposes. Each identity can have its own name and signature.
When you're in Profle page, you can see your identity list

### 1. Create a new identity 

- (1) Click on "Create New Identity" button
- (2) Enter the name for the identity.
- (3) Email: Specify the email address associated with this identity. You can select one email from drop-down list. 
- (4) Reply to:  Specify the email address that will appear on recepient's composer when he reply to your email 
- (5) BCC: When you compose a new email wiht this identity, the emails in this field will be added to "Bcc" field of composer automatically
- (6) Customize the signature if needed.
- (7) Set as default identity: When an identity is set as dedault, its settings such as signature, BCC... will be used when you compose a new email. You can still change to a non default identity by selecting it in the composer.
- (8) Click button Create to save the new identity.

![image](https://github.com/linagora/tmail-flutter/assets/68209176/44f74874-2eff-4aa5-97e5-a267d5a26b71)

![image](https://github.com/linagora/tmail-flutter/assets/68209176/9a02fdae-6aa6-46c2-b599-1bc4d54fb717)

- You can include an image in signature of the identity, .eg company logo, product logo, project logo.... The image is sent in every email, so it should be an small image (less than 16KB).

![image](https://github.com/linagora/tmail-flutter/assets/68209176/f114e9c6-5674-42cb-9fc7-6d7404bc972f)


### 2. Edit an existing identity 

- On identity listing you click on the one that you want to Edit then select Edit button
- Modify the fields Name, Reply to, Bcc, or signature as required.
- Save your changes.

![image](https://github.com/linagora/tmail-flutter/assets/68209176/5d49cb1b-796a-4815-8ec8-174bef26da66)

### 3. Delete an Identity

- On identity listing you click on the one that you want to Delete Then select Delete button

- Confirm the deletion.

![image](https://github.com/linagora/tmail-flutter/assets/68209176/4c2204fd-2c5a-4096-a15f-02f804daa6dd)


## Email rules

- Email rules, also known as filters are powerful tools that allow you to  manage your inbox by automatically sorting, moving to a folder, forwarding, or taking other actions on incoming emails.
- In Manage account page, When select "Email rules" on the left menu, you can see the list of current rules
  
![image](https://github.com/linagora/tmail-flutter/assets/68209176/922d39d4-33c4-4800-9638-28bdb82812a2)

### 1. Create a rule

- (1) Click on `Add Rule` button
- (2) Name your rule for easy identification.
- (3) Define the conditions that trigger the rule (e.g., sender, Recipient, subject...).
- (4) Specify the actions to be taken when the conditions are met (e.g., move to a folder, mark as read).
- (5) Save the new rule.

![image](https://github.com/linagora/tmail-flutter/assets/68209176/9940da6b-528d-40d6-8a76-5e8d5d09d1a2)

- The new rule will be applied for upcoming emails. The order to applied email rules is from the latest created date to the earliest created date of filters. 

### 2. Edit an Existing Email Rule

- On the email rule listing, Select the rule you want to edit.
- Modify the conditions or actions as needed.
- Save your changes.

![image](https://github.com/linagora/tmail-flutter/assets/68209176/dd5e483c-9bf4-43dc-9b86-8901632da863)

### 3. Delete an email rule

- On Email rules listing you click on Delete icon beside the one that you want to Delete
- Confirm the deletion.
  
![image](https://github.com/linagora/tmail-flutter/assets/68209176/af475797-0afe-47d8-b060-8ec5b50f8fbc)

## Forwarding

- This feature allows you to automatically send emails you receive to another email address.
- In Manage account page, When select "Forwarding" on the left menu, you can see the list of forwarding email addresses. 
  
![image](https://github.com/linagora/tmail-flutter/assets/68209176/13fc8571-c56e-48d7-9f0a-4c00225ea763)

### 1. Add the forwarding addesses

(1) Enter the email address to which you want to forward your emails.
(2) Choose whether to keep a copy of forwarded emails in your original inbox (recommended for backup).
(3) Click `Add recipient` buton to save your changes.

![image](https://github.com/linagora/tmail-flutter/assets/68209176/991f8824-a22f-4848-9efc-f3a1f9b32e43)

### 2. Delete forwading addesses

- If you no longer wish to forward your email, you can remove the forwarding email address.
- You can click Delete icon in each forwading addess or select multiple addesses (1) then click button `Remove` (2)
- Confirm the deletion (3)

![image](https://github.com/linagora/tmail-flutter/assets/68209176/e85ae04c-ce1d-4c68-8b5a-c3afebcc34b5)

![image](https://github.com/linagora/tmail-flutter/assets/68209176/5e50a51d-024f-4bb1-abd9-2dd10dbb0ca0)


## Vacation

- Automatic vacation replies are messages that are sent automatically to anyone who emails you while you're on vacation.
- Setting up automatic vacation reply is a convenient way to inform your contacts that you're away and won't be able to respond to emails promptly.
- On Manage accout page, YOu can select tab "Vacation" on left meny to access vacation reply settings

![image](https://github.com/linagora/tmail-flutter/assets/68209176/f2743333-bc42-4cc7-a50e-81121c43a355)


## Folder visibility

TODO

## Language settings

TODO

## Logout

TODO

