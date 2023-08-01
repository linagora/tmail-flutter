# 30. Fix can not see link when type is text/plain in email view

Date: 2023-08-01

## Status

- Issue: 

[1881](https://github.com/linagora/tmail-flutter/issues/1881)
[2047](https://github.com/linagora/tmail-flutter/issues/2047)

## Context

- When `Content-Type=Text/Plain` the `url` and `email-addreess` links are not automatically `highlighted`.
- Some `url` links are `highlighted` when clicking, opening the content in the email view itself does not create a new tab.

## Root cause

- Because we perform `html escape` before creating `autolink`, it makes lost tags undetectable. Moreover, the detect function is ignored in some cases

## Decision

- Use linkify to detect `url/email/text` and return a list of corresponding elements.
```dart
   final elements = linkify(inputText);
```

- If element is `TextElement` we perform html escape for it.
- If element is `UrlElement` or `EmailElement` we make html link tag (`<a>`) for it.
```dart
  String _buildLinkTag({required String link, required String value}) {
     return '<a href="$link" target="_blank">$value</a>';
  }
```

## Consequences

- Accurately detect and fully highlight `url` and `email-address` links in email body when `Content-Type=Text/plain`
- Automatically open new tab when clicking on `url` link and open composer when clicking on `email-address`
