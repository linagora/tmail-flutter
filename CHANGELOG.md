## [0.15.3] - 2025-04-22
### Fixed
- #3670 Forwarding email make attachment bar disappear
- #3661 Fix memory leak for file picker
- #3674 Refactor reply email base on thunderbird logic
- Handle session in case of using isolate for Mark as Read, Empty Trash, Empty Spam

## [0.15.2] - 2025-04-15
### Added
- #3578 Blue bar: free and busy status
- #3589 Add CalendarAttendance method
- #3591 Add Calendar Counter event action

### Fixed
- Mobile E2E tests: forward email,
- #3501 Inlined answer mus be shown on base level
- #3601 Height Limit in webview in iOS
- Try to wrap content for text/plain
- #3487 Error handling for some cases: get email content, refreshing, get mailbox
- #3623 Duplicate confirm buttons in creating identity
- #3640 Increase composer size in case of singel composer
- #3621 Fix search return wrong result with Doesn't have 
- #3622 Display exceeded image 
- #3507 Pull to refresh to resolve missing cache in mobile
- #3647 Disable email zoom in mobile
- Handling refreshToken in composers
- #3651 Support mailto url from Openpaas
- Reply to own sent email
- #3656 Fix identities was not updated between Settings and Dashboard 
- #3659 Cannot remove forward
- #3627 Standalize scrollbar for composer 
- Suppport preview image with mimeType application/octet-stream
- #3665 Autocomplete position

## [0.15.1] - 2025-04-01
### Changed
- Update User guide

### Fixed 
- Display name of auto completion
- #3584 PDF viewer in old Safari (16.6)
- #3585 Read receipt was not showed in mobile
- #3593 Close composer after reload maybe lost email

## [0.15.0] - 2025-03-19
### Added
- #1192 Support multiple composer
- #3450 Preview of other simple attachments (`image/*`, `text/plain`, `text/markdown`, `application/json`)
- Translation zh_Hans, ga, de

### Fixed
- #3410 Reduce color noise
- #3511 Android email view system back action
- #3502 Composer image loading icon
- #3533 Migrate android gradle plugins
- #3548 Handle exceeded quota
- Disable charset detector on iOS as workaround to fix build ios fail

## [0.14.15] - 2025-03-10
### Added
- #3349 Sender can set priority in composer
- #3349 Display priority in Email list 

### Fixed
- #3517 Fix "Reply to *me*" field is added when save an email as draft
- #3407 Enable SelectableText for email display name in EmailAddressDialogBuilder
- #3318 Fix black pixel when clicking on attachment with long name
- #3316 Fix inconsistent vacation message
- #3293 Fix blue bar cannot select action banner text
- #3461 Add sort by message size
- #3472 Only display attachment in one line
- #3514 Detect base64 image and transform to CID attachment
- #3539 Autocomplete not show display name
- #3539 Can not paste emails in mouse out focus and tab button

## [0.14.14] - 2025-02-25
### Added
- Translation vi, ta, ru, fr, de

### Fixed
- Send email in Cyrus


## [0.14.13] - 2025-02-19
### Fixed
- #3298 blink when refresh mail list
- #3291 Search with multiple from address
- #3264 Fix composer drag n drop
- #3292 Search by date and sort with relevance is not working
- #3294 Fix duplicate email in Blue bar: Mail to attendee
- #3295 Clickable in mail address in Blue bar
- #3296 Search with star filter
- #3315 Email display table correctly
- #3219 Display limit of email recovery
- #3275 iOS foreground desync
- #3312 Fix logout dialog for mobile app
- #3181 Display contact support for mobile
- #3290 Only show reconnection confirm dialog when composer is opened
- #3189 new option to enable/disable subaddressing for a personal folder
- #3260 Display App Grid Linagora Ecosystem
- #3454 Download all attachments as ZIP
- #2469 Fix email set into root mailbox's SENT instead of team mailbox's SENT (#3482)
- #3488 Add hide download taskbar feature
- #3466 Fix refresh folds folder
- #3444 Fix could not expand folder tree in folder visibility on iOS
- #2305 Cyrus support
- #3345 Fix sort order blinks when deleting emails in search

### Added
- #3278 Handle open app from TWP page
- Upgrade with Flutter 3.24.5

## [0.14.12] - 2025-01-23
### Fixed 
- #3267 Preview HTML for mobile

## [0.14.11] - 2025-01-21
### Fixed
- #3430 Reply/Forward indicator will be synced after sent email
- #3408 Support load more in auto complete
- #3337 Reduce unnessary JMAP request for vacation when open Setting pages
- #3424 Preserve format for text/plain email

### Added
- #3416 Preview EML
- #3267 Preview HTML
- #3406 Edit as a email
- #3427 Print composing

## [0.14.10] - 2025-01-10
### Fixed
- Editor height is infinite

## [0.14.9] - 2025-01-10
### Fixed
- #3396 Call latest change and update relevant state (ca51f78f0)

## [0.14.8] - 2025-01-09
### Fixed
- #3396 Fetch latest change when open the app 
- #3385 Fix loading forever after delete all email in one folder
- #3323 Handle reconnect websocket in somecases: laptop in sleep, network change
- #3413 Add Reply to list button
- #3399 Fix focus in composer in mobile browser

## [0.14.7] - 2025-01-05
### Fixed
- Delegate cache control from Flutter to browser

## [0.14.6] - 2025-01-03
### Fixed
- #3372 Paging empty trash
- #3370 Limit Email/set with limit is min of (50, maxObjectsInSet)
- #3379 Show replyAll button in case recipients not include me
- #3385 Realtime update UI base on Email/set
- #3344 Paste recipients to composer

## [0.14.5] - 2024-12-26
### Fixed 
- #3336 Make Echo ping of web socket optional
- #3347 Format Calendar event description
- #3341 Enable Web socket for mobile in foreground
- #3334 Remove all own resynch after any actions in mailbox, email
- #3333 Remove Mailbox/query for spam banner when reload app
- #3332 Remove resynch when switching mailbox
- #3372 Remove Mailbox resynch when Emptying trash
- #3369 Display CID without disposition as an attachment

### Added
- #3181 Contact support 

## [0.14.4] - 2024-12-18
### Fixed
- #3349 Sanitize HTML when forward/reply/replyAll an email
- #3349 Sanitize HTML when print email
- #3349 Add recipients information to the email body when forward/reply/replyAll an email

## [0.14.3] - 2024-12-16
### Fixed
- Disable Spell check API 

## [0.14.2] - 2024-11-20
### Added
- #3010 Highlight search result with SearchSnippet method
- Translate vi, ru, fr

### Fixed
- #3253 Fix body content is lost
- Close keyboard when login in iOS
- #3250 Fix share file from external app to Twake Mail
- #2528 Sorting email by order ids list of Email/query
- #3221 handle mailto with additional cc and bcc
- #3276 Fix debouncer in Quick Search web app
- #3256 Fix cache config for static file in web app

## [0.14.1] - 2024-11-13
### Changed
- Integrate with TWP production

## [0.14.0] - 2024-11-09
### Added
- #2387 TWP Registration from mobile 
- #3157 Web socket to replace FCM in web app
- #2953 Mobile integration test with Patrol 

### Fixed
- #3244 `To` filter should apply also for `cc` `bcc`
- #3243 some tags still be in sanitizing
- #3178 Only Space in Name verification for Identity, Rule Filter, Vacation
- 3D links not work on mobile
- Focus problem in `tab` in Basic Auth login form
- #3225 Print button blink blink
- #3222 Hide reply calendar event action button
- #3247 Cc is lost if open email from Quick search result
- #3200 Update option menu for personal folders
- Support German

## [0.13.6] - 2024-11-07
### Fixed
- Remove app grid in mobile

## [0.13.5] - 2024-10-24
### Fixed
- Sanitize html 

## [0.13.4] - 2024-10-17
### Added
- Configuration for deploy platform 

### Fixed
- Change logos to beta and move position of version label on web

## [0.13.3] - 2024-10-16
### Fixed
- \#3002 \[SEARCH\] More filters
- \#3004 \[SEARCH\] Fix open close advanced search looses data
- \#3005 \[SEARCH\] Easily clear From and To search result header
- \#3006 \[SEARCH\] mail address handling in quick search bar
- \#3007 \[SEARCH\] Support drag and drop between From & To field
- \#3025 \[SEARCH\] Mark as read/unread/important/unimportant action refresh email view, reset selection in Search
- \#3192 \[SEARCH\] Update highlight style as design
- \[SEARCH\] Add suggestion for From/To dialog when input is new email address
- \#3045 Hide compose button situationally on mobile
- Show app version on login view
- \#2983 Fix download EML with special character
- Fix alignment receive time in email view
- Remove space when subject is empty or null
- Remove blink blink of next & previous button in Email View
- Fix hyperlink iOS still show full link
- Replace dart:ui to dart:ui\_web when platformViewRegistry in dart:ui is deprecated
- \#3183 Clean up draft after email sent
- \#3034 Prevent duplicate draft warning
- \#3171 Fix duplicate signature button on Composer view changed
- Simplified the prebuild script
- Translation vi, ru, fr, de

## [0.13.2] - 2024-09-18
### Added
- User guide
- Todo list for Release

### Fixed
- Fix identity creator view on mobile
- #3088 Ending date of date picker is not correct
- #3077 Remove stacktrace from error toast
- #3113 Cannot empty spam on mobile by isolate
- #2769 Weird toast when upload attachment failed on mobile by isolate
- #3082 Caching editor when user edit identity
- Replace !is with is!
- #3051 Prevent creating email rule with no action
- #3035 Store identity in draft
- #3087 Add email address to the suggestion list when user input email address in the composer
- #3123 Fix load more button show irrelevant
- #2903 Fix 3D links in email
- #2602 Detect charset for text attachment
- #2965 Handle error for checking OIDC failure
- #3114 Prevent buttons is covered by keyboard in identity creator view 
- #2940 Add speller check for some other place: identity creator, subject email composer, vacation form
- Update README.md
- Translation vi, ru, fr, 

## [0.13.1] - 2024-08-28
### Fixed
- Get SMime signature status in headers parsed value

## [0.13.0] - 2024-08-23
### Added
- #2857 New icon for Twake Mail
- #3023 Display SMime signature status in headers email
- #2975 Change the layout main screen in mobile app
- #3042 Support PublicAsset in Signature

### Changed
- Upgrade jmap_dart_client v0.2.0

### Fixed
- #2973 Adjust remove button in rule creator
- #2806 Disable reload button of mailbox list in desktop layout
- #2925 Handle of loading email list when switch mailbox
- #2976 New design for email list in desktop layout
- URL concat for APIs endpoint 
- #2893 Standardize Appbar and App grid
- #2676 Handling create identity with empty name
- #2724 Fix automatically scroll down when user edit Identity
- #2721 Fix show list email when user changed filter or sort order on iOS
- #2951 Remove `Clean` button, `Empty Trash/Spam now` banner and `Filters` when there is no email in `Spam/Trash` folder
- #2949 remove duplicated information in email of calendar event
- #2931 Filter empty name identity 

## [0.12.1] - 2024-07-18
### Fixed
- Upgrade minimumOS version to 12.0 [iOS]

## [0.12.0] - 2024-07-18
### Added
- #2988 Upgrade to Flutter 3.22.2
- Translation vi, ru, fr, mfe

### Fixed
- #2907 Disable `YES/NO/MAYBE` action for events when missing `METHOD/ORGANIZER/ATTENDEES`
- #2945 Quick select for Request Read Receipt
- #2989 Drag n Drop text in Email composer
- #2946 Copy action for own email address in User information
- #3000 Long list of recipients in reading email
- #2871 Plain notificaiton for iOS
- #2929 Button is truncated in French or long text in Vacation banner 
- #2972 Change color for `Clean` button
- #2928 Detect session expired and notice to user
- #2930 Inline image in Draft 
- MarkAsSpam not displayed when editing rule filter

## [0.11.5001] - 2024-07-05
### Added
- #2877 Notification settings inside app
- #2901 Store composer cache to prevent user losts input when token need refresh

### Fixed
- #2644 Warning when sending large Email
- #2677 Handle sending/saving email failed with progress dialog
- #2684 Select text in Blue bar
- #2717 Improving Composer UI in mobile to have more space to input recipients
- #2671 Handle signature sometimes disappear
- #2215 Communicating l10n to remote servers
- #2919 Handle composer stability: memory leak, inout many recipients
- #2868 Bold curso should correspond to the typing text
- #2827 Prevent clicking reply before content is loaded
- #2532 Update Attachment flow in mobile app
- #2584 Improve composer mobile in toolbox (Text style, Attachment, Inline image)
- #2475 Rich text not work in composer

## [0.11.4002] - 2024-06-04
### Added
- #2764 Add PDFViewer to view preview PDF in email
- Translate vi, ru, fr


## [0.11.4001] - 2024-05-22
### Fixed
- #2890 Remove fake reason in parsing cancelled calendar event

## [0.11.4] - 2024-05-22
### Fixed
- #2599 Prevent notification flood by set silent for all notification except group notification
- #2860 Improve notification for iOS to update with APN requirements
- #2850 Replace new TWP app's icons
- #825 Download email as EML file
- #2858 Store CalendarEvent actions in `keywords`
- #2859 Insert l10n in CalendarEvent actions
- Translation vn, fr

### Added
- #2425 CalendarEvent actions: Adccept/Maybe/Reject

## [0.11.3-patch4-16] - 2024-05-07
### Fixed
- #2835 Change properly exception handler for AuthenticationOIDCDatasource
- #2830 Add forward recipient directly when click on Add recipient button

## [0.11.3-patch4-15] - 2024-05-18
### Fixed
- Upgrade AppAuth library in iOS
- Fix iOS build

## [0.11.3-patch4-14] - 2024-05-03
### Fixed
- FR translation for read receipt
- #2810 Handle crashed when no browser available for OIDC
- #2533 Using `pagehide` instead of `beforeunload` to remove listener in composer to prevent memory leak
- #2835 Fix multiple requests in onError queue make the refreshToken logic failed
- #2831 Custom message for forwarding warning message
- #2830 Improve adding recipient in forwarding
- #2836 Remove button with no effect on mobile

## [0.11.3-patch4-13] - 2024-04-15
### Fixed 
- #2533 Remove iframe listener in composer (memory leak in composer)
- #2533 Remove file picker memory leak in composer
- #2758 Use web view to display calendar description
- #2785 Prevent user try to click on print email too early
- #2310 Fix Hive check in some browser block web app loading

## [0.11.3-patch4-12] - 2024-04-05
### Fixed
- #2774 Try to display big signature fit in composer
- #2772 Fix printing a blank page in center of printed email
- #2628 Disable PDF viewer in Web app
- #2773 Fix text overflow in warning dialog of forwarding feature
- #2533 Fix memory leak in Composer and Email view
- Handle service worker in web app
- Fix reload app still keep composer open

## [0.11.3-patch4-11] - 2024-04-01
### Fixed
- #2460 Implement realtime update for web app in background
- #2646 Change term `Select All` to `Select all message of this page`
- #2694 Clear sort order in search when select another mailbox
- #2754 Add handler to preview PDF in Edge, Opera
- #2735 Add gesture back for composer in Android 14
- #2658 Fix background color in data time picker

## [0.11.3-patch4-10] - 2024-03-22
### Fixed
- #2730 Fallback value for Always read receipt settings is false
- #2628 Disable view PDF file in mobile
- #2726 Remove logo in printed email
- #2737 View PDF in js to support download with name

## [0.11.3-patch4-9] - 2024-03-15
### Added
- Always settings for read receipt request
- Translate en, fr, ru, vi

### Fixed
- Copy/Drop text from LibreOffice files to composer
- Download PDF file from Chrome viewer
- Download attachment for mobile
- Small improvement for Printing email

## [0.11.3-patch4-7] - 2024-03-08
### Fixed
- #2597 Handle one action in the same time in composer
- Handle crash in composer when try to open/close composer many times

### Added
- #2628 Download and Open PDF file: Open by clicking on file - Download by clicking on download icon
- #2613 Warning when forwarding email to external email address
- #2520 Print email in PDF 

## [0.11.3-patch4-6] - 2024-02-26
### Fixed
- #2326 Display total count of Draft 
- #2362 Auto load more in big screen
- #2465 Fix wrong time format in Blue bar
- #2633 Fix blink blink in composer [Web]
- #2599 Resolve notification flood in Android

## [0.11.3-patch4-5] - 2024-02-21
### Fixed
- #2611 Get only one by one in FULL level when receive changes in notification
- #2502 Fix all day event in Blue bar
- Fix text disappear in redirect banner
- #2610 Standardize the way to display attachment
- Translate Vietnamese
- Translate French
- Translate Russian
- Translate Arabic
- #2537 Fix app crash when trying attach file in mobile-browser

## [0.11.3-patch4] - 2024-02-19
### Fixed
- #2564 Change logic empty folder (Spam/Trash) to avoid cache still has data
- #2464 Fix wrong iOS notification when Email changes
- #2596 mailto with multiple recipients
- #2560 Fix wrong focus in composer make it can not close
- #2536 Change the logic to get all mailbox
- #2592 Hide toast message when get error token expired
- #2565 Redirect banner on mobile web app
- #2479 Hide marAsSpam action in `Email_view` & team-mailbox
- #2540 Fix selected Email address at `to/cc/bcc` fields are moving too close to the bottom of input field
- #2460 Cancel deleting firebase token after logout
- #2539 Fix selected email address at `to/cc/bcc` fields are having weird border
- #2538 Fix email suggestion list is having weird white overlapping
- #2531 Fix cannot see all recipients list if email have a lot of recipients

## [0.11.3] - 2024-01-12
### Fixed
- Get plain notification on iOS

## [0.11.2] - 2024-01-12
### Changed
- Disable Work Manager in sending email automatically

## [0.11.0] - 2024-01-09
### Added
- Larger scrollbar in email list view on web
- Archive messages
- Email recovery

### Changed
- Upgrade flutter version 3.16.0
- Schedule build to run on workday end (11:00 UTC)
- App Icon, Splash Screen, App Name, Notification Icon

### Fixed
- Sorting in search
- Attachments are not displayed
- Read receipt includes weird attachments that are impossible to download
- Jumping screen when clicking on Cc, Bcc
- Missing body when read mail with ics attachment
- User cannot see the suggestion when recipient is longer than 10 on mobile
- Recipient list in field Cc is not in correct position
- Large image in identity
- Cannot upload svg image as signature
- Native browser navigation
- Filter in quick search result on browser
- Duplicate searching result after load more
- Notification on mobile (Android/iOS)
- Change language setting subtitle
- Cannot clickable signature button in composer if the body is longer than 1 line

## [0.10.5] - 2023-11-21
### Added
- Support multiple condition/actions for Filter Rule
- Support Cyrus/Stalwart server
- Sorting search results
- Autocompleting people in quick search
- JMAP endpoint auto discovery
- Unsubscribe from email/mailing lists

### Fixed
- Suggestion displayed on top when having many recipients
- Add field 'From' to composer
- Change input suggestion field for fields 'From/To' in advance search
- Spam banner
- Mark as read when moved to spam
- User has been log out once the network connection is not stable
- Offline mode on iOS
- Selection mode when dragging and moving email

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

[0.13.4]: https://github.com/linagora/tmail-flutter/releases/tag/v0.13.4
[0.13.3]: https://github.com/linagora/tmail-flutter/releases/tag/v0.13.3
[0.11.4002]: https://github.com/linagora/tmail-flutter/releases/tag/v0.11.4002
[0.11.4001]: https://github.com/linagora/tmail-flutter/releases/tag/v0.11.4001
[0.11.3]: https://github.com/linagora/tmail-flutter/releases/tag/v0.11.3
[0.11.2]: https://github.com/linagora/tmail-flutter/releases/tag/v0.11.2
[0.11.0]: https://github.com/linagora/tmail-flutter/releases/tag/v0.11.0
[0.10.5]: https://github.com/linagora/tmail-flutter/releases/tag/v0.10.5
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