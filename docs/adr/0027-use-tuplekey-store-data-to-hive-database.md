# 27. Use TupleKey store data to hive database

Date: 2023-04-27

## Status

Accepted

## Context

- Multiple accounts login at the same time in the same browser. The accounts will use the same database (`IndexDatabase`).
- To support multiple accounts

## Decision

- Use unique parameters (`AccountId`, `UserName`, `ObjectId(MailboxId/EmailId/StateType/...)`) to form a unique `key` for storage (called `TupleKey`).
- TupleKey has the format: `AccountId | UserName | [ObjectId]`;
- `HiveDatabase` includes many `Box`. Each box is a `Map<Key, Object>` with `key=TupleKey`.

## Consequences

- Each account will manage its own data storage boxes
