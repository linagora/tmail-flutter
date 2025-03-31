# 60. Cozy integration env

Date: 2025-04-15

## Status

Accepted

## Context

- Cozy script needs to be loaded optionally

## Decision

- `COZY_INTEGRATION` is added to env
  - Set it to `true` if you want to load cozy script
  - Set it to `false` or left it as is if you don't want to load cozy script

## Consequences

- Cozy script can be loaded optionally
