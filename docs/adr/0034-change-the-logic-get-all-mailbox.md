# 34. Change the logic to get all mailbox to avoid miss mailbox (#2536)

Date: 2024-02-05

## Status

Accepted

## Context

- Currently `MailboxRepository` get the data from local first:
    - if cache hit `(have mailbox + cache)`, `/changes` to update
    - if cache miss `(no mailbox, no state)`, `/get` to update view
  
What happen if cache hit, but not have all the data? Yep, this is the issue.

## Decision

- Change the logic to get all mailbox
    - Get from the local `(support quick response and offline mode)` -> yield to UI
    - Get `Mailbox/get` from JMAP to update the list of mailbox correctly -> yield to UI

## Consequences

- No more lost mailboxes. The latest mailbox list is always updated.
