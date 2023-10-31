## [0.10.4] - 2023-10-31
### Added
- Communicating L18n to remote servers

### Fixed
- Mark as read multiple message have the trouble on mobile
- Empty trash have the trouble on mobile
- Upload image/attachment have the trouble on mobile

## [0.10.3] - 2023-10-27
### Fixed
- Build release on iOS

## [0.10.2] - 2023-10-27
### Added
- Change font size in composer
- New attachment view
- Scroll to top on web

### Fixed
- Message content is cutted
- Signature button is included in email content
- Download error when token refreshed
- Upload failed when token expired

## [0.10.1] - 2023-10-11
### Added
- Scroll up button
- Privacy policy

### Fixed
- Email content is cut
- Focus in email composer

## [0.10.0] - 2023-10-09
### Added
- \#2116 Apply new design composer
- \#2118 Support drag and drop attachments from my PC
- \#2172 Support drag and drop attachments from other mail
- \#2194 Add action new subfolder
- Translated Vietnamese/German

### Changed
- \#2125 README: refresh roadmap
- \#2126 README: Credit Linagora better

### Fixed
- Fix not found object in bindings
- Fix can not open new tab for email
- \#2120 Fix drag and drop text inside the composer on web
- \#1608 Set References and In-Reply-To fields
- \#2157 Remove collapsed/expanded signature in EmailView
- \#2168 Invalid recipient from mailto router
- \#2167 Support CTRL+SHIFT+Z shortcut in composer on web
- \#2176 Fix app grid on the tmail.linagora.com sometimes is outdated
- \#2160 \[Mobile\] A part of the bottom of email content has been cut off, only happen with long email html template
- \#2179 \[UI\] Some screen having menu label is overlap on Russian languages
- \#2180 \[UI\] Suggestion list being hidden once user use device with small screen
- \#2199 \[UX\] \[Suggestion\] User cannot see the email suggestion if that email is new with our system
- \#2202 \[Offline\] Sending email failed when network is corrupted but wifi still in full
- \#2189 \[Offline\] While app in offline, After click on send button in composer, dialog show, but when click outside the dialog, all disappear
- \#2188 \[Offline\] Sending queue item sent failed but still in Sending queue
- \#2190 \[Offline\] Offline proceed dialog is overlapped
- \#2187 \[Offline\] Click on back button in Sending Queue mailbox then close the app
- \#2182 \[BLUE-BAR\] No blue bar for Office 365 events

### Security
- \#2163 Add a security.md file

## [0.9.3] - 2023-09-19
### Fixed
- \[HOT-FIX\] Fix built release but nginx route 404 not found on web

## [0.9.2] - 2023-09-14
### Changed
- \#2134 \[WEB\] mailto URL
- Translate Russian/French/German
- \#2124 Add badges for downloads (#2140)
- \#2123 Change license to AGPL-V3 - drop the OpenPaaS clause

### Fixed
- \#1844 Fix \[AdvanceSearch\] User cannot get the advance searching result once user use Enter without the clicking Search button
- \#1845 Fix \[AdvanceSearch\] The searching result is not correct with the condition which mention in the description
- \#1977 Fix clickable logo
- \#1984 Fix \[Barcamp\] Counter for Trash/Spam + empty action for Trash/Spam
- \#2026 Fix \[COMPOSER\] Save as draft should not close the composer
- \#2129 Fix \[Attach image\] I cannot attach image
- \#2135 Add Splash Screen for user to prevent blank page in the first time loading TeamMail app
- \#2089 Add dash-dash-space to signature delimiter
- Fix the login screen freezes when pasting the link in the browser address bar
- Fix TextEditingController was used after being disposed in LoginView
- Fix oidc refresh token on mobile

## [0.9.1] - 2023-08-23
### Fixed
- \#1974 Fix refreshToken with OIDC on jmap.linagora.com/oidc
- \#2099 Fix quota information are missing

## [0.9.0] - 2023-08-18
### Added
- \#1710 Delete all spam emails
- \#2064 Display banner when the quota reaches the limit
- \#2078 Add calendar Yes/No/Maybe options

### Changed
- Upgrade flutter version to 3.10.6

### Fixed
- \#2047 Can not see the link when type is text/plain in email view
- \#1981 Spam banner is too big
- \#2066 Calendar not apply on version 0.8.9 when upgrade from old version
- \#2067 Disable swipe left/right to next/previous email in email view
- \#2068 Calendar banner widget is gray bar
- Change SERVER\_URL to deployment PR success
- \#1982 Change mailboxes label to folder
- \#1714 Refreshing mailbox: display an animation while loading
- \#2087 \[IOS/ ANDROID\] The Status Bar is missing when user change Dark theme mode in device system
- \#1983 Create folder - How to create filter easier
- \#2089 Fix pull-to-refresh in mailbox view
- \#2092 Signature delimiter should be dash - dash - space
- \#1961 Email text content could be temporarily truncated

## [0.8.9] - 2023-07-31
### Added
- Translate Russian and French
- Apply new view calendar event

### Fixed
- \#2052 Fix TeamMailbox email address alignment is incorrect
- If no refreshToken return, maybe the old refreshToken still available

## [0.8.8] - 2023-07-20
### Fixed
- \#2046 App crashes when login account information is incorrect on web

## [0.8.7] - 2023-07-19
### Fixed
- \#1912 Fix rendering issue on TMail when reading an email
- Fix re-login app when token expires in OIDC

## [0.8.6] - 2023-07-14
### Added
- \#1486 Support inserting images in identity

### Fixed
- \#1868 Hide parent - show child: nothing displayed in the side bad
- \#1898 There is no notification badge only on IOS
- \#1985 Hoover to see the selection
- \#1993 Has attachment checkbox is overflow once it be translated in russia
- \#1994 Long press to copy an email address
- \#2008 Instead of toasting for network connection, we should show a very small UI at the top of the list
- \#2030 Turn off composer logs by defaults

## [0.8.5] - 2023-07-14
### Added
- Translation (Arabic/Russian)

### Fixed
- \#1683 Remove Plain text option of message in VacationView
- \#1895 \[Animation\] The screen seem be black before loading the email content successfully

## [0.8.4] - 2023-07-07
### Fixed
- \#1932 Turn off notifications after emailing
- \#1963 Bypass the Screen with button Single sign-on when OIDC flow is detected
- \#1829 App crash upon 401
- \#1933 The inbox and sending queue is highlight once some emails in sending queue was sent in the same time
- \#1877 \[Composer\] Text Style is not changed correctly once user change the focus
- \#1952 Display signature in composer on mobile
- \#1974 RefreshToken with OIDC on jmap.linagora.com/oidc
- \#1708 \[UI\] \[Change languages\] Translating system mailboxes (INBOX, etc…)
- \#1957 \[RTL\] Email subjects are displayed overlap email content
- \#1957 \[RTL\] Name of attachments are reversed
- \#1958 \[RTL\] 'To' and 'Cc' fields are not displayed in the single line
- \#1959 \[RTL\] Invalid email red border is displayed over the address field
- \#1960 \[RTL\] Cannot edit signature in Profile Identity

## [0.8.3] - 2023-06-27
### Fixed
- \#1878 Fix font family not changed correctly in composer
- \#1913 Fix Email/changes is called multiple times when an error cannotCalculateChanges is returned
- \#1931 Fix user cannot do infinity scroll when he turn off network and reconnect again
- \#1923 Fix user cannot view that email content by click on the notification in Offline Mode

## [0.8.2] - 2023-06-15
### Fixed
- Fix select font style always default when changed
- Fix attachments not show when click ShowAll button
- Fix alignment delete button in attachment item file of email view in RTL mode
- Hide keyboard when open choose attachment dialog on mobile

## [0.8.1] - 2023-06-15
### Added
- Support RTL mode
- Dockerfile - Add new stage for minify js file
- \[Docs\] Configure OIDC
- Support configuration for OIDC scopes

### Fixed
- Fix disable connected network toast notification

## [0.8.0] - 2023-06-12
### Added
- \#1786 Write stories for swipe in email item in ThreadView
- Support Sending emails when offline
- Support manage the sending queue
- Support view/modify SendingQueue entries

### Fixed
- \#1862 Fix right click on email item in email list view
- \#1851 Fix \[COMPOSER\] Selected rich text menu do not match current text status
- \#1851 Fix \[COMPOSER\] Need to apply color twice for bold

## [0.7.11] - 2023-06-05
### Changed
- Upgrade version flutter-typeahead

## [0.7.10] - 2023-06-05
### Added
- Keep N recently opened email in the cache
- Reading recent emails when on slow network/offline
- Config work manager on mobile

### Changed
- Split the test report job for forks

### Fixed
- Force browsers to re-validate cache before reuse

## [0.7.9] - 2023-05-08
### Added
- \#1792 Add option 'Empty Trash' in folder menu

### Changed
- \#1755 Use TupleKey('ObjectId\|AccountId\|UserName') store data to cache

### Fixed
- \#1385 Fix \[Email rule\] Icon edit and delete might be seen as disable
- \#1677 Fix \[ManageAccount\]\[Forwarding\] Email validation is not working well
- \#1687 Fix \[UI\] Unread counter and mailbox name are displayed not in single line
- \#1735 Fix filters not applied to search
- \#1743 Fix horizontal scroll bar in Email detail view
- \#1798 Fix \[Toast\] Error message is displayed behind the keyboard on IOS platform only
- \#1803 Fix advanced search can't clear 'Have the world'
- \#1806 Fix impossible to disable used fonts in email composer

## [0.7.8] - 2023-04-24
### Added
- Added workflow to create a deployment on PR

### Fixed
- \#1711 Fix the label is displayed overlap the button in France, Italian, Russia languages
- \#1740 Fix double scrollbar in composer web
- \#1759 Fix reply all do not always include me in recipients
- \#1763 Fix duplicated email suggestion in the list
- \#1767 Fix Reply/Forward: original message should be marked, not the sent one
- \#1778 Fix system not display signature in email which has been sent
- \#1779 Fix logic of replacing dot in long email

## [0.7.7] - 2023-04-14
### Added
- \#1599 Remove notification when read and delete permanent email
- \#1100 Display Answered / Forwarded keywords
- \#1600 No notification for content of Draft, Sent, Outbox, email already seen

### Changed
- \#1598 Dismiss should mark emails in the spam box as seen

### Fixed
- \#1613 When network is down, Tmail shouldn't prompt for a password
- \#1699 Support hide suggestion when scrolling list email to, cc, bcc.
- \#1681 Add a dot at the end of the description
- \#1687 Set name email and counter displayed in a single line
- \#1685 Fix hover and click to button show all or hide attachments
- \#1694 The Cancel/Save button is hidden in IdentityCreatorView
- \#1688 \[Identity\] \[Crashed\] Tmail UI is broken after user create identity successfully by html style
- \#1684 \[Identity\] User click on blank area but system redirect user to 404 not found page <weird link>
- \#1679 \[Identity\] Button 'X' : Sometime it's hidden, sometime it's displayed
- \#1693 \[Identity\] There are 2 cursors on Create Identity screen
- \#1667 \[Energy-Economy\] Do not request spam on every email I move
- \#1698 \[Mailbox\] System not redirect correct url when user double click many times to view email in mailbox
- \#1677 \[ManageAccount\]\[Fowarding\] Email validation is not working well
- \#1655 Add a line break after signature in composer
- \#1665 App grid: Manage 3 apps and less beautifully
- \#1544 \[UX\] User can not move to another fields by press TAB
- \#1663 \[Compose\] Use cannot click to compose after system display an error message
- \#1654 \[SLO\] Redirect to SLO page of the OIDC provider
- \#1631 \[Notification\] User cannot receive new email notification
- \#1666 \[COMPOSER\] Keyboard overriding rich text context menu on mobile
- \#1569 \[BackgroundApp\] Android system keeps showing an app that run at background
- \#1749 \[Drats\] User cannot save drafts or send email if that email already at drafts mailbox

## [0.7.6] - 2023-04-06
### Added
- \#1510 right click for app grid item
- Handle text, contact in Share with TeamMail in Android
- Translation
- \#1581 Support RTL
- \#1606 support relative path in Session

### Changed
- \#1487 upgrade to Flutter 3.7.5
- Update the error handler with BadCredentialException
- Increase minimum supported iOS version to 11
- Cache settings for nginx
- \#997 new design for date-range-picker

### Fixed
- Auto scroll when expand mailbox
- \#1472 fix position of Toast in mobile
- \#1513 richtext toolbar is lost in mobile
- \#1477 fix search
- \#1521 fix can not scroll to read long email in Android
- \#1527 fix focus in composer
- \#1162 fix open link
- \#1549 fix overlapped long text
- \#1539 support space for inputing name in auto suggestion in Search
- \#1528 input indicator is cut at the bottom of composer
- \#1594 can not send email because Controller is killed
- Fix drag n drop email
- \#1573 fix cursor in Android
- \#1611 prevent blocking when user input html in vacation
- \#1604 missing capability for team mailbox
- \#1440 user can not sign in with OIDC when press back button in auth page
- \#1657 fix broked infinite scroll

### Removed
- Remove menu action of Team Mailbox
- \#1508 setBackgroundMessageHandler
- \#1512 remove plain text input for signature
- \#1469 remove animation when navigating screen

[0.10.4]: https://github.com/linagora/tmail-flutter/releases/tag/v0.10.4
[0.10.3]: https://github.com/linagora/tmail-flutter/releases/tag/v0.10.3
[0.10.2]: https://github.com/linagora/tmail-flutter/releases/tag/v0.10.2
[0.10.1]: https://github.com/linagora/tmail-flutter/releases/tag/v0.10.1
[0.10.0]: https://github.com/linagora/tmail-flutter/releases/tag/v0.10.0
[0.9.3]: https://github.com/linagora/tmail-flutter/releases/tag/v0.9.3
[0.9.2]: https://github.com/linagora/tmail-flutter/releases/tag/v0.9.2
[0.9.1]: https://github.com/linagora/tmail-flutter/releases/tag/v0.9.1
[0.9.0]: https://github.com/linagora/tmail-flutter/releases/tag/v0.9.0
[0.8.9]: https://github.com/linagora/tmail-flutter/releases/tag/v0.8.9
[0.8.8]: https://github.com/linagora/tmail-flutter/releases/tag/v0.8.8
[0.8.7]: https://github.com/linagora/tmail-flutter/releases/tag/v0.8.7
[0.8.6]: https://github.com/linagora/tmail-flutter/releases/tag/v0.8.6
[0.8.5]: https://github.com/linagora/tmail-flutter/releases/tag/v0.8.5
[0.8.4]: https://github.com/linagora/tmail-flutter/releases/tag/v0.8.4
[0.8.3]: https://github.com/linagora/tmail-flutter/releases/tag/v0.8.3
[0.8.2]: https://github.com/linagora/tmail-flutter/releases/tag/v0.8.2
[0.8.1]: https://github.com/linagora/tmail-flutter/releases/tag/v0.8.1
[0.8.0]: https://github.com/linagora/tmail-flutter/releases/tag/v0.8.0
[0.7.11]: https://github.com/linagora/tmail-flutter/releases/tag/v0.7.11
[0.7.10]: https://github.com/linagora/tmail-flutter/releases/tag/v0.7.10
[0.7.9]: https://github.com/linagora/tmail-flutter/releases/tag/v0.7.9
[0.7.8]: https://github.com/linagora/tmail-flutter/releases/tag/v0.7.8
[0.7.7]: https://github.com/linagora/tmail-flutter/releases/tag/v0.7.7
[0.7.6]: https://github.com/linagora/tmail-flutter/releases/tag/v0.7.6