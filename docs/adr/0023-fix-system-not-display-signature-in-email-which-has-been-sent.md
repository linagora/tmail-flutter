# 23. Fix system not display signature in email which has been sent

Date: 2023-04-21

## Status

- Issue: [#1778](https://github.com/linagora/tmail-flutter/issues/1778)

## Context

- Root cause: Due to a syntax error in javascript. In string contains the characters `'` and `"`

## Decision

- Use `template literals` to escape a string in JavaScript. Follow on [enough_html_editor#20](https://github.com/linagora/enough_html_editor/pull/20)

## Consequences

- Escape a string in JavaScript avoid signature display error when sending email on mobile.