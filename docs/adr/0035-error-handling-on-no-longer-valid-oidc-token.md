# 35. OIDC Token Refresh Mechanism in AuthorizationInterceptors

Date: 2024-02-15
Updated: 2026-02-09

## Status

Accepted (supersedes [ADR-0031](0031-fix-refresh-token-with-oidc.md))

## Context

Multiple issues drove the evolution of the refresh token logic:

1. **Concurrent 401s caused logout** ([#1974](https://github.com/linagora/tmail-flutter/issues/1974)) — parallel requests with stale headers all triggered independent refresh attempts.
2. **Ugly error on expired token** ([#2592](https://github.com/linagora/tmail-flutter/issues/2592)) — users saw a red error instead of a silent redirect.
3. **400 on refresh not handled** — when the refresh token itself was revoked/expired, the server returned 400 (invalid_grant) but the interceptor did not distinguish this from transient errors, leading to confusing failures.
4. **Server-side revocation before local expiry** — relying on local `isExpired` check caused the interceptor to skip refresh when the server had already revoked the token.

## Decision

`AuthorizationInterceptors` extends `QueuedInterceptorsWrapper` (Dio). The `onError` handler processes errors one at a time with the following ordered checks:

1. **`_refreshAttemptedKey` guard** — if the request already attempted a refresh/retry, skip everything and propagate the error. Prevents infinite loops.
2. **`validateToRetryTheRequestWithNewToken`** (checked first) — if `_token` was already updated by a preceding queued request, retry immediately with the new token. No refresh call needed.
3. **`validateToRefreshToken`** — if status is 401, auth type is OIDC, and access/refresh tokens are present, attempt refresh. The local `isExpired` check was **removed**; we trust the server's 401.
   - **Success (different token):** update `_token`, persist to cache, mark `_refreshAttemptedKey`, retry.
   - **Success (same token — duplicate):** propagate original error, no retry.
   - **`DioException` 400:** call `clear()` (wipe auth state) and reject with `RefreshTokenFailedException` — triggers silent logout.
   - **`DioException` other:** propagate original error, preserve OIDC state.
4. **Outer catch:** `ServerError`/`TemporarilyUnavailable` wrapped in `DioException`; other exceptions forwarded via `err.copyWith`.

## Consequences

- Queued requests after a successful refresh retry without redundant refresh calls.
- 400 from the OIDC provider causes immediate session cleanup and silent redirect to login.
- No infinite retry loops thanks to the `_refreshAttemptedKey` per-request flag.
- Server-side token revocation is handled correctly regardless of local expiry time.
