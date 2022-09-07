# 10. Crash app when open web_view on android device

Date: 2022-07-20

## Status

Open

## Context

- When using a `WebView` inside of a `Scrollview`, some content renders a completely distorted page and some content even crashes the app.
This problem only affects Android the same app, on iOS the same code results in a correctly rendered web page.
Rendering the same content also works fine on Android, when not embedding the `WebView` inside of a scrollview.

- Flutter version has problem: >= `3.0.0`
- Library `webview_flutter` version used: `3.0.0`

## Decision

- Temporary solution: Set maximum height of `WebView` on `Android` device equal to device physical size height

## Consequences

- Email content is displayed well on `Android` devices. No more distortion and crashes
- The content scroll bar appears inside the email detail display.

## Reference

- [Issue detail](https://github.com/flutter/flutter/issues/104889)
