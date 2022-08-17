# 14. Refactor RefreshChange to sync State

Date: 2022-08-17

## Status

Accepted

## Context

- `State` is updated asynchronously on the server so after performing operations on `Email` the data is not fully updated.

## Decision

- Pass the initial `State` to the result after performing operations with `Email`
- Use `State` in the returned results to perform `RefreshChange` of `Email` and `Mailbox`

## Consequences

- `Email` and `Mailbox` data is fully updated.
- `State` is saved synchronously and up to date
