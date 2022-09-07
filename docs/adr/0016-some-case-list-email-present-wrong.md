# 16. Fix some wrong cases email list presents

Date: 2022-09-13

## Status

- Issue: Mailbox A has cache with more than 20 filtered emails.
Then come back this mailbox in the next time, read-emails are not showed correctly.

## Context

- Root cause: list email cached not enough.


## Decision

- Fill the cache with the first page of this mailbox at the first time open this mailbox.
- Get only the first page in the cache when open mailbox

## Consequences

- Email list presents correctly