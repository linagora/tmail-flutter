# 37. Only request full `Email/get` one-by-one

Date: 2024-02-19

## Status

Accepted

## Context

We use `Email/get` to get full email information to support reading emails in `offline` mode.
Therefore, it leads to request too many ids in `Email/get` at full level. `Back-End` have `limitation` for this leads to error

## Decision

- Get for maximum `5` latest email in `Email/changes`
- Execute `Email/get` at FULL level `one-by-one`

## Consequences

- Avoid BE errors and reading emails offline still works fine
