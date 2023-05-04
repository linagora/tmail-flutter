# Summary

* [Related EPIC](#related-epic)
* [Definition](#definition)
* [Screenshots](#screenshots)
* [Misc](#misc)

## Related EPIC

* TODO: {link}

## Acceptance Criteria: 
```
GIVEN I'm a Tmail user
AND There are existed unread emails on my mailbox
WHEN I swipe left to right on an email rows
THEN I see the email row is swiped as blue background color belong with "read email icon"
AND System mark an email as read

GIVEN I'm a Tmail user
AND There are existed read emails on my mailbox
WHEN I swipe left to right on an email rows
THEN I see the email row is swiped as blue background color belong with "unread email icon"
AND System mark an email as unread

GIVEN I'm a Tmail user
AND There are existed emails on my mailboxes
WHEN I swipe right to left on an email rows
THEN I see the email row is swiped as blue background color belong with "Move email icon"
AND System display a list mailbox dialog to let user select the email moving desitination
AND System display a checked icon belong to mailbox in the list which indicate user that email is in what mailbox at the moment

GIVEN I'm a Tmail user
WHEN I swipe right to left on an email rows
AND I select one mailbox in the list
THEN The email is moved with the toast message
```

## Definition

**UC1. As I am a user, I want to swipe left to right to mark an email as read without opening this email
On thread-view, when I swipe left to right on email which be unread state, I can see:
**Configs in Swipe Options**: Swipe left to right = Read/Unread

- The icon indicator this is unread email
- The background color is blue 

**Expected:** User mark an email as read successfully.

**UC2.  As I am a user, I want to swipe left to right to mark an email as unread without opening this email
On thread-view, when I swipe left to right on email which be unread state, I can see:
**Configs in Swipe Options**: Swipe left to right = Read/Unread

- The icon indicator this is read email
- The background color is blue 

**Expected:** User mark an email as unread successfully.

**UC3.  As I am a user, I want to swipe right to left to move an email
On thread-view, when I swipe right to left on email in my mailbox, I can see:
**Configs in Swipe Options**: Swipe right to left = Move email

- The icon indicator this is Move email
- The background color is blue
- The list of mailboxes will be displayed
- The checked icon will be displayed which indicator that email is in what mailbox at the moment

**Expected:**  
I see the email row is swiped as blue background color belong with "Move email icon" 
AND System display the list of mailboxes wit checked icon belong to mailbox which include that email.

**UC4.  As I am a user, I want to swipe right to left in email of my mailboxes
On thread-view of Archive folder, when I swipe left to right / right to left then the archived email is moved to inbox

**Expected:** 
This email is moved to selected mailbox. System display a toast message.



[Back to Summary](#summary)

## Screenshots: 

![image](https://user-images.githubusercontent.com/124866146/235097306-615f0b87-5fe2-456b-b830-072ddc348059.png)

![image](https://user-images.githubusercontent.com/124866146/235097387-fb616f8f-ff50-4dfe-8e2b-44a5bca3aba4.png)

![image](https://user-images.githubusercontent.com/124866146/236110914-0b53392a-161a-4f25-85d9-abb06706d82a.png)

![image](https://user-images.githubusercontent.com/124866146/236111202-a4154949-5512-4287-bc78-d85ad6ad610a.png)

![image](https://user-images.githubusercontent.com/124866146/236111590-6d85c76f-e9ab-4128-ae11-060c3186085f.png)





[Back to Summary](#summary)

## Misc

None

[Back to Summary](#summary)
