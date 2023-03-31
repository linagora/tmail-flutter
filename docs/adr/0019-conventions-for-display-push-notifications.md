# 19. Conventions for display push notifications

Date: 2023-03-31

## Status

Accepted

## Context

In response to user experience, push notifications should display correctly.

## Decision

Let's not put notifications if:

- The email is in one of these mailbox: `Sent, Draft, Outbox, Trash, Spam`
- The email is `seen`

## Consequences

- Increase user experience.
