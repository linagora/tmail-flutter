# Summary

* [Related EPIC](#related-epic)
* [Definition](#definition)
* [Screenshots](#screenshots)
* [Misc](#misc)

## Related EPIC

https://github.com/linagora/tmail-flutter/issues/1638

## Definition

**UC1. Assign a label for messages in thread-view**

- Given that I am a Tmail user and I have logged in successfully
- On thread-view, I select one or multiple messages
- On action bar, I can see an icon Label
- I click on this icon, there will be a popup that listing all current labels
- I can select one or multiple label then click button Apply
- Then selected labels will be appeared on message as tags, on both thread-view and message content view

![image](https://user-images.githubusercontent.com/68209176/228160592-91c5428e-0e36-4edc-a589-ea474408c0e1.png)

**UC2. Assign a label for messages in message detail view**

- Given that I am a Tmail user and I have logged in successfully
- I click on one message and the content will be opened
- On action list on top of screen, I can see an icon Label
- I click on this icon, there will be a popup that listing all current labels
- I can select one or multiple label then click button Apply
- Then selected labels will be appeared on this message as tags, on both thread-view and message content view

![image](https://user-images.githubusercontent.com/68209176/228160873-4046f365-8693-45a1-b088-38b248ddb964.png)


**UC3. Remove a label on a message**

- Given that I am a Tmail user and I have logged in successfully
- On thread-view I click on one message that currently have some label, the content view of this message is opened.
- On content view, I click on the label, there will be a drop-down list with 2 available options: Go to label and Remove label
- I select option “Remove label”
- The label is removed from this message and there will be a toast notification 
“[Label name] is removed from this email]” and Undo button
- If I click Undo, the label is back to this email again.

![image](https://user-images.githubusercontent.com/68209176/228167740-50be89b5-f3d4-44b3-8f22-012848ade474.png)

![image](https://user-images.githubusercontent.com/68209176/228167811-e89bfe40-29e1-495b-b2a3-26f38060e89f.png)


[Back to Summary](#summary)

## Screenshots

None

[Back to Summary](#summary)

## Misc

None

[Back to Summary](#summary)
