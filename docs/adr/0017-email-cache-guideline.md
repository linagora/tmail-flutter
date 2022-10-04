# 17. Email cache guideline

Date: 2022-10-04

## Status

Accepted

## Context

The logic of Email cache is complicated to follow by all developers

## Decision

Brief the logic flows to easier in following the changes of cache implementation

- Email Caches of each mailbox will be filled by `ThreadConstants.defaultLimit` items at the first time open this mailbox.
- `State` of `Email` will be cached at the first time cache is filled.
- Email Caches of all mailbox will be synchronized by `Email/changes` in the case `State` of `Email` is available in local.
Only items in cache will be updated by `changes`, other will be ignored
- After any operations (CRUD with Mailbox, Email), `refreshChanges` is invoked to synchronize the cache
- To guarantee the single of truth, UI only display the final result which fetches from the cache, does not directly show the result come from the back-end

## Consequences

- Any change to `ThreadRepository::getAllEmail` and `ThreadRepository::refreshChanges` should be updated in this ADR
