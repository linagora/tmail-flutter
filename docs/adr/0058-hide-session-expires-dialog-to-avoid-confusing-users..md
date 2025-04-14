# 58. Hide session expires dialog to avoid confusing users

Date: 2025-04-14

## Status

Accepted

## Context

Why did we use Session Expires dialog before, to solve data loss problems when connection is lost:

- Data loss when connection is lost [#2928](https://github.com/linagora/tmail-flutter/issues/2928)
- Poor network in the train take me to login page [#2965](https://github.com/linagora/tmail-flutter/issues/2965)
- Finner handling of reconnection  [#3290](https://github.com/linagora/tmail-flutter/issues/3290)

But displaying a dialog with such text is confusing to many users,
who worry about whether the data has actually been saved.

## Decision

Hide Session Expires dialog:
- If composer is open, it will automatically save data and reconnect immediately
- If composer is closed, it will automatically reconnect immediately.

## Consequences

Every time the session expires, the system automatically reconnects and restores the old data.