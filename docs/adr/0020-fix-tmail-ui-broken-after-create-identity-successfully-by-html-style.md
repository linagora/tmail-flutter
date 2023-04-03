# 20. Fix Team Mail UI is broken after user create identity successfully by html (#1688)

Date: 20223-04-03

## Status

- Issue: [#1688](https://github.com/linagora/tmail-flutter/issues/1688)

## Context

- Root cause: Flutter was unable to create enough overlay surfaces. This is usually caused by too many platform views being displayed at once.

## Decision

- Use `pointer_interceptor` version `v0.9.1`

## Consequences

- No more UI loss errors
