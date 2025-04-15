# 59. Reply to own sent email

Date: 2025-04-15

## Status

Accepted

## Context

- User want to reply to own sent email, keeping all "To" recipients

## Decision

- PresentationEmailExtension._handleReply is modified
- When `isSender` is `true`, all "To" recipients will be kept

## Consequences

- When replying to own sent email, "Reply-To" email will no longer be considered
