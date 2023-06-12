## [0.8.0] - 2023-06-12
### Added
- TF-1786 Write stories for swipe in email item in ThreadView
- Support Sending emails when offline
- Support manage the sending queue
- Support view/modify SendingQueue entries

### Fixed
- TF-1862 Fix right click on email item in email list view
- TF-1851 Fix \[COMPOSER\] Selected rich text menu do not match current text status
- TF-1851 Fix \[COMPOSER\] Need to apply color twice for bold

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

[0.8.0]: https://github.com/linagora/tmail-flutter/releases/tag/v0.8.0
[0.7.11]: https://github.com/linagora/tmail-flutter/releases/tag/v0.7.11
[0.7.10]: https://github.com/linagora/tmail-flutter/releases/tag/v0.7.10
[0.7.9]: https://github.com/linagora/tmail-flutter/releases/tag/v0.7.9
[0.7.8]: https://github.com/linagora/tmail-flutter/releases/tag/v0.7.8
[0.7.7]: https://github.com/linagora/tmail-flutter/releases/tag/v0.7.7
[0.7.6]: https://github.com/linagora/tmail-flutter/releases/tag/v0.7.6