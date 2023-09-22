
 This guide will walk you through the process of using our email composition tool effectively.
 
 ###  Creating a New Email in web
1. Click on the "New Email" button.
2. A new email composer will appear.
. From: By default it will display your default identity. When you click on `Edit` icon (3.1)- a drop-down list of your identities will be shown and you can select one of them. The identities you can use in the `From` field can be edited on the [profile page](profile.md).
3. Fill in the recipient's email address in the "To" field.
4. Enter a subject for your email in the "Subject" field.
5. Adding Recipients
You can add multiple recipients by separating their email addresses with commas. Use the "CC" (Carbon Copy) and "BCC" (Blind Carbon Copy) fields for additional recipients as needed.
- (5.1)`CC`: Carbon Copy:  Anyone in this field will see the other recipients of the message.
- (5.2) `BCC`: Blind Carbon Copy: The recipients won't know that you added anyone to 'Bcc'.
6. Signature button: You can click on thí button to unfold/fold your signature. The setting of identities and its signature ycan be edited on the [profile page](profile.md).

![image](https://github.com/linagora/tmail-flutter/assets/68209176/b8a242bf-6667-4cbc-91d2-137fda1f1d23)


7. Text Formatting
Use the formatting options provided to style your email's text. These include :
- (7.1) `Style`
- (7.2) `Font famlily`
- (7.3) `Text color`
- (7.4) `Text background color`
- (7.5) `Bold`
- (7.6) `Italic`
- (7.7) `Underline`
- (7.8) `Strikethrough`
- (7.9) `Paragraph`
- (7.10) `Order list` 

![image](https://github.com/linagora/tmail-flutter/assets/68209176/a920992b-ecb6-4739-a2e2-73e3f6c17454)


8. Adding Attachments
To attach files, click on the `attachment icon` and select the files you want to include. 
9. Insert images
To insert images to the email body as an inline image, clock on `image icon` then select images that you want to include 
10. Code view
When you click on `Code view button`, the email your are writing is displayed in Code view mode. This option is helpfull for developpers who want to debug the sources of the generated email.
11. Sending Your Email
- Click the "Send" button to send your email. Once sent, it will appear in your "Sent" folder.
- You can also click button `Save to Draft` (12) then the email is moved to Draft folder, you can then open it again and continue composing it.
- If you click `Cancel button` (13), the email will be discarded 

![image](https://github.com/linagora/tmail-flutter/assets/68209176/ebe2839b-3899-4a38-ac36-6d1bb30a26a4)

14. Managing Sent Emails

To access sent emails or track the status of your sent email, navigate to the `Sent` folder (14) within your email client. Email currently being sent are located within  the `Outbox` (15) and will eventually be moved into the `Sent` folder.

16. Read receipt

This feature allows the sender of an email to know when the recipient has opened and read the email. It provides a way for the sender to confirm that the message has been received and viewed by the recipient.

Here's how read receipt  work:
- Sender Requests a Read Receipt: When composing an email, the sender can enable the option to request a read receipt by click on icon (16) then select option "Request read receipt" 
- When the recipient receives the email and opens it, they are typically presented with a message or notification asking if they want to send a read receipt back to the sender. The recipient can choose to either send the read receipt or decline the request.
- If the recipient chooses to send a read receipt, their email client will automatically generate and send a notification to the sender, indicating that the email has been opened and read.
- The sender receives the read receipt as a separate email or notification, confirming that the recipient has indeed read the email.
  
![image](https://github.com/linagora/tmail-flutter/assets/68209176/eccdd0b0-eaee-4af8-b5f7-4a9498a4d770)



