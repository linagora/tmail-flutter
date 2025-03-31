# 58. Fix iOS email view gone blank with large HTML content

Date: 2024-04-05

## Status

- Issues: 
  - [iOS Email view gone blank with large HTML content #3601](https://github.com/linagora/tmail-flutter/issues/3601)

## Context

- On iOS, when using an `InAppWebView` inside a `SingleChildScrollView`, the height of the `SingleChildScrollView` depends on the `InAppWebView`. 
Continuously updating the height of the `InAppWebView` up to a certain limit can cause the `SingleChildScrollView` to fail to render, 
resulting in the content of the `InAppWebView` not being displayed.

## Decision

- Workaround:

Set the maximum display height for content on iOS to `22,000` (not an absolute limit, but verified across various emails and found to be the most reasonable value).
If the email content exceeds this height, a `View entire message` button will be displayed at the bottom of the email.
When users click this button, they will be able to view the full email content, similar to previewing an EML file.


## Consequences

- All emails display fine on iOS
