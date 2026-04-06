# 75. Move Access Token from Persistent Storage to Session Storage on Web

Date: 2026-04-06

## Status

Accepted

## Context

Issue [#3348](https://github.com/linagora/tmail-flutter/issues/3348): closing and reopening the browser kept the user logged in because the OIDC access token was persisted to disk. Closing the browser should require re-authentication; refreshing or opening a new tab within the same session should not.

## Decision

On web, store the access token in `sessionStorage` (cleared when the browser closes) instead of persistent storage. Metadata needed for token refresh (tokenId, refreshToken) remains on disk. Native platforms are unaffected.

## Consequences

- Closing the browser clears the access token; re-login is required (or silent refresh if the refresh token is still valid).
- Page refresh and new tabs within the same session work without re-authentication.
- The access token never touches disk on web, reducing the persistent attack surface.
