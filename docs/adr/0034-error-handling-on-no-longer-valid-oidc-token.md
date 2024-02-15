# 34. Error handling on no longer valid OIDC token (Issue #2592)

Date: 2024-02-15

## Status

Accepted

## Context

- When my OIDC token is expired, I see an awful red error message while being redirected

## Decision

- When my OIDC token is expired, I am just redirected to the OIDC provider portal. No need to show an awful error.

## Consequences

- In case of receiving a `BadCredentials` error, the system automatically logs out and returns to the login screen without any notification to the user.