# 66. Robust OIDC Guessing

Date: 2025-06-27

## Status

Accepted

## Context

- The users are forced to manually enter the server url when the app fails to lookup the oidc configuration

## Decision

- The app will try to guess the oidc url based on the email address with common prefixes
  - `email.domain`
  - `jmap.email.domain`
  - `autodiscover.email.domain`

## Consequences

- The oidc discovery is more robust
