# 68. Thread level actions

Date: 2025-08-18

## Status

Accepted

## Context

- When user send an email, a copy of that email is created in Sent mailbox
- If user sent an email, and recipients contains own user, there will be 2 emails in the thread, one in Sent mailbox, and another in Inbox mailbox (or the other mailbox if there is email rule for it).
- This cause the thread has 2 emails with the exact same content.
- Current solution is filtering out the email in Sent mailbox when displaying thread.
- However, the thread level actions are ignoring these filtered-out emails.

## Decision

- All thread level actions will be applied to all emails of thread.

## Consequences

- If user move emails of thread to other mailbox, there will be email duplication due to the filtering conditions are not met anymore.
