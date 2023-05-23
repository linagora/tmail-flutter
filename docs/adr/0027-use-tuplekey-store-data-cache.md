# 27. Use TupleKey store data cache

Date: 2023-04-27

## Status

Accepted

## Context

- Multiple accounts login at the same time in the same browser. The accounts will use the same database (`IndexDatabase`).

## Decision

- Use unique parameters (`AccountId`, `UserName`, `ObjectId(MailboxId/EmailId/StateType`) to form a unique `key` for storage (called `TupleKey`).
- TupleKey has the format: `ObjectId | AccountId | User`;
- `HiveDatabase` includes many `Box`. Each box is a `Map<Key, Object>` with `key=TupleKey`.

## Consequences

- The correct `mailbox` and `email` lists are obtained for each account
