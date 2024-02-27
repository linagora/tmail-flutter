# 39. Logic for displaying PDF in new browser tab

Date: 2024-02-23

## Status

Accepted

## Context

- When user tap PDF attachment inside email web, the attachment should be automatically opened in new tab
- The attachment button in web at the moment can be tapped on itself, and also at the download icon inside it
- The behavior when tapping either of those places are the same

## Decision

Separate the business logic of both tappable places:

1. When download icon is tapped

- Create download anchor and click on it programmatically, triggering the download action of the browser
- After the browser download the file, browser will handle the file by its own settings & policies

2. When anywhere else inside the attachment button is tapped

- If attachment is PDF, trigger window.open from html.dart with `_blank` parameter so that the file is opened in new tab
- If attachment is not PDF, treat the action as if the download icon is tapped as case 1

## Consequences

- Different behaviors will be triggered depends on where user taps inside the attachment button on Twake Mail web
