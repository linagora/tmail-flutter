# 10. Crash app when open web_view on android device

Date: 2022-07-20

## Status

Open

## Context

- When using a webview inside of a scrollview,
some content renders a completely distorted page and some content even crashes the app.
This problem only affects Android the same app, on iOS the same code results in a correclty rendered web page.
Rendering the same content also works fine on Android, when not embedding the webview inside of a scrollview.

- Flutter version has problem: 3.0.3

## Decision

- When using a webview inside of a scrollview,
some content renders a completely distorted page and some content even crashes the app.
This problem only affects Android the same app, on iOS the same code results in a correclty rendered web page.
Rendering the same content also works fine on Android, when not embedding the webview inside of a scrollview.

## Consequences

- From now we waiting web_view lib update and for android device if content of web_view has max height is 6000,

## Reference

- [Issue detail](https://github.com/flutter/flutter/issues/104889)
