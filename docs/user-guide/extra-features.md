# Extra features {#2}

This small page will present features specific to Twake-Mail.

## I. Team-mailboxes

 - "Team mailbox" typically refers to a shared mailbox or a collaborative inbox that multiple users or team members can access. A team mailbox is useful for managing emails collectively, allowing multiple team members to view, respond to, and manage emails in a shared space.

- The owner of the shared mailbox needs to grant permissions to other team members. This can usually be done through the mailbox settings by the administrator.

- Once permissions are set, team members can see the team-mailbox on foldet-tree on left panel. Each team-mailbox will contains:
  - (1) Team-mailbox name
  - (2) Email address of the team-maiilbox

![Group 194](https://github.com/linagora/tmail-flutter/assets/68209176/3a4c900e-0cf8-4266-a66d-e08d66317fc9)


### Read message in my team-mailbox:

- Every team-mailbox contains folders:
  - Inbox
  - Drafts
  - Outbox
  - Sent
  - Trash
- You can hide and show a team-mailbox in 2 ways:
   1. Click 3-dots button on the team-mailbox, then select option "Hide folder", then the team-mailbox will be hidden from th folder tree

![Group 194](https://github.com/linagora/tmail-flutter/assets/68209176/f157ca8f-6176-4447-b9ab-3d0194147dde)

   2. Click avatar on top right => Manage account => Folder visibility: This screen will list all the folders, including team-mailboxes. I can easily select Hide/Show

![image](https://github.com/linagora/tmail-flutter/assets/68209176/42b85296-8461-4e4d-b115-a8e2822f3918)

- You can mark star/unstar an email in the team-mailbox as other folders, then other members having access to the team-mailbox will see the message being star/unstar as well.
- You can mark message as read/unread in the team-mailbox as other folders, then other members having access to the team-mailbox  will see the message being read/unread as well.

### Team-mailbox identities 

- As a team-mailbox member, you can add a team mailbox as an identity  so that you can access and manage emails on behalf of that team mailbox.
- You can create a new identity for the team-mailbox, edit/delelte it in the same way [Manage sender's identities](https://github.com/linagora/tmail-flutter/blob/user-guide-skeleton/docs/user-guide/profile.md#identities)

### Send a message by team-mailbox

**1. Send a new message**

- When you click button "Compose", the he composer will be opened
- Whe nyou click to field "From", a drop-down list will be shown your list of identities  
- You can select your team-mailbox identity that you created before 
- Finish typing message and then choose Send.
- The recipients will see the team-mailbox address as the sender in the message.

 **2. Reply/Forward to the message**

- When you open one email of a team-mailbox, and click button Reply/Forward
- The composer will be opened with the quoted message
- In "From" field, select team-mailbox identity that you created before then input the mail content and Send.
  
## II. Auto-complete

- This is a feature designed to make composing and addressing emails more convenient. This feature predicts and suggests email addresses as you start typing in the "To," "Cc" (carbon copy), or "Bcc" (blind carbon copy) fields and the Search bar 
- When you start typing an email address, the system might suggest matches based on your contacts.
- Email Address Auto-Complete often relies on your existing contacts and address book ( mobile app).
- The existing contacts are contact from your company
- when you open TMail app for the first time, you will be asekd to allow Tmail to access to device's contacts. If you allow permisstion, then when you use auto-complete feature, it will rely on both your company's contacts and phone's contact 

![image](https://github.com/linagora/tmail-flutter/assets/68209176/19038361-b6f6-413a-aac1-ad352a001074)

![Frame 30](https://github.com/linagora/tmail-flutter/assets/68209176/d9ec88cc-153b-4500-84a5-4d23a019983c)


## III. Event information display

When you receive a calendar event invitation in an email, Twake Mail will display the event details in a format that allows you to easily review and respond to the invitation. 

**1. On Email listing**

On thread-view, You can see email of calendar events which having title include:

- (1) The icon indicator events in front of email title

- (2) The icon indicator .ics file which having in events email

- (3) The event name on subject

- (4) The event short description

- (5) The host name (sender) email who be created an event

- (6) The event status (New / Updated / Canceled)

**2. Calendar event  on details-view**

On details-view of an email, you can see description of calendar events which having description include:

- (1) The Calendar icon indicator event date

- (2)The event name on subject

- (3) The notification with color to describe each event status

- (4) The mini tips information of event (When event will be started!? Who are invited !? Where is the event place!?)
  
- (5) Yes/No/Maybe/Mail to attendees buton: You can click one of these button to response to the event invitation. When you click on "Mail to attendees", a new email composer is opened, with all attendees auto-filled as recipients. 

- (6)  The description will be demonstrated in email body

![Group 195](https://github.com/linagora/tmail-flutter/assets/68209176/674f9118-c3d4-4834-b018-153f2b17324a)

![Group 5 (1)](https://github.com/user-attachments/assets/4e60aa71-0e1c-4c3e-9637-a31afb538117)

![Group 6 (2)](https://github.com/user-attachments/assets/3a8b3554-055d-45c8-bcad-7918429dbdad)

## IV. Get help or report a bug

A question mark (?) icon is located at the top right of the screen. When you click on it, a new email composer will open. The 'To' field is pre-filled with the Twake support team's email address. You can describe your question or the bug you encountered and send the email for assistance.

![Group 13](https://github.com/user-attachments/assets/0fc6bafa-e551-49ed-867b-2c64033738e4)


