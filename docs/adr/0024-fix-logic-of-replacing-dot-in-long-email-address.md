# 24. Fix logic of replacing dot in long email address

Date: 2023-04-21

## Status

- Issue: [#1779](https://github.com/linagora/tmail-flutter/issues/1779)

## Context

- Root cause: When we use the `overflow=TextOverflow.ellipsis` property for the `Text` widget for long texts, it will result in incorrect string breaks. Since string contains some characters that are supposed to be word breaks in the string. The characters `space` and `-`

## Decision

- Convert those special characters to unicode. 
- Flutter is working on fixing that bug and is expected to be updated in version `3.10`. Follow on [flutter#18761](https://github.com/flutter/flutter/issues/18761)

## Consequences

- Text overflow with ellipsis worked correctly
