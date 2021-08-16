# Tmail Flutter mobile application

![LOGO](https://user-images.githubusercontent.com/6928740/129552343-31e21182-d07c-4f2a-bc83-4f9be70d1693.png)

This project aims at providing a multi-plateform mobile email application, running the [JMAP protocol](https://jmap.io/) and will also deliver additional 
features to the [TMail back-end](https://github.com/linagora/tmail-backend).

Here is how TMail looks like on a phone:

![Screenshots Mobile](https://user-images.githubusercontent.com/6928740/129556356-3099bc0f-2af8-4635-afc2-6ccb385abd03.jpg)


Here is how TMail looks like on a tablet:

![Screenshot Tablet](https://user-images.githubusercontent.com/6928740/129555644-229abd19-d1db-4d31-bfe1-3f1f7e59804c.png)

## FAQ

### **Why did you choose JMAP?**

That is a good question! **IMAP** is THE ubiquitous protocol people use to read their emails, THE norm.

Yet **IMAP** had been designed in another age, which resulted in a chatty patchwork of extensions. **IMAP** lacks decent synchronisation primitives to address real-time challenges modern mobile fleet requires, it consumes a lot of bandwith, requires a lot of roundtrips which means high latency.

We are not alone to say this! Big players of the field started their own [proprietary](https://developers.google.com/gmail/api) [protocols](https://docs.microsoft.com/en-us/exchange/clients/exchange-activesync/exchange-activesync?view=exchserver-2019) to address IMAP flaws, and inter-operable standard was yet to be found...

This, is where **[JMAP](https://jmap.io/)** comes to play! **JMAP** builds on decades of experience, and beautifully addresses these challenges using `HTTP` and `JSON` standards. Not only does it make applications easier to develop, we also strongly believes it results in an improved experience for the end user.

### **Can I use TMail with *any* JMAP server?**

Yes, you can use the TMail application with any JMAP server and benefits from **Tmail** ergonomy and ease of use.

### **I don't understand your crap... I need help using your App! HELP MEEEEEE...**

Don't worry, we are here!

We plan on writing a user documentation, helping you navigating around the application, and detailing the few configurations you have to perform.

If what you are looking for is not in the *user guide* then ask us directly in the [issues](https://github.com/linagora/tmail-flutter/issues) first, we would be glad to help. But also glad to improve our documentation and maybe tweak slightly our UI (user interface).

### **What plateforms do you (plan to) target?**

First, we target Android, IOS mobiles. We also take care of tablets and large rendering space early on in the development process.

Then, we plan on introducing a desktop application.

This versatility is enabled by the use of the [Flutter framework](https://flutter.dev/).

### **What would your roadmap look like?**

First, we plan to write a simple, multi-plateform JMAP email client. This includes reading your mails and mailboxes, managing them, sending emails, searching your emails. This will likely keep us busy by the end of 2021.

Then, we have plan for multiple features including:

  - Support for TMail encrypted mailbox (GPG)
  - Support for TMail shared mailboxes
  - Support for TMail filters
  - Interactions with some other software from [Linagora](https://linagora.com) including:
      - Sending attachments via [LinShare]() file sharing platform.
      - Transfering some attachments you received to [LinShare](https://www.linshare.org/fr/accueil/) file sharing platform.
      - Discussing some emails you received via [Twake](https://twake.app/en/) chat.

### **Any chance to support JMAP extension for calendar, contacts?**

No we do not plan to support such extensions, that are currently not standardized as RFCs, nor implemented on the TMail backend.

### **Your work is awesome! I would like to help you. What can I do?**

Thanks for the enthousiasm!

There are many ways to help us, and amongst them:

   - **Spread the word**: Tell people you like **TMail**, on social medias, via blog posts etc... 
   - **Give us feedbacks**... It's hard to make all good decisions from the first time. It is very likely we can benefit from *your* experience. Did you encountered annoying bugs? Do you think we can better arrange the layout? Do you think we are missing some features critical to you? Tell us in the [issues](https://github.com/linagora/tmail-flutter/issues).
 - I can code! **I wanna help ;-)**. Wow thanks! Let's discuss your project together in the [issues](https://github.com/linagora/tmail-flutter/issues) to get you on track!
