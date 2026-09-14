# 0107. Route Workplace's OIDC refresh through the main interceptor

Date: 2026-09-07

## Status

Accepted

## Context

Workplace's Drive `token_exchange` request runs on `WorkplaceDio`, a bare `Dio()` instance with no interceptors. A 401 on that request (a stale OIDC id token) has no refresh-and-retry path, unlike the main app's Dio, which refreshes via `AuthorizationInterceptors`. `AuthorizationInterceptors` lives in the main app package; `workplace` is a separate package that cannot depend on it.

## Decision

- `AuthorizationInterceptors` exposes `requestTokenRefresh()`, a dedup-guarded public entry point backed by an in-flight `Future<TokenOIDC>`. Any caller — the interceptor's own reactive `onError` path or an external caller — joins the same in-flight refresh instead of starting a second one.
- `requestTokenRefresh()` owns the fatal-vs-transient outcome of a refresh for every caller: a server rejection (RFC 6749 400/401-equivalent, classified by the existing web/mobile classifiers) clears the session and throws `RefreshTokenFailedException`; transient failures are rethrown untouched.
- Same-token detection is not centralized: JMAP's own `onError` path and the Workplace wiring each compare the token they had before the refresh against the value `requestTokenRefresh()` returns, since they check different fields.
- Every session carries a generation counter. Clearing a session bumps it before wiping caches, and each write a refresh makes (token persistence, account persistence, iOS keychain sharing) re-checks the counter first; a write that lands after the session it started for was cleared rolls itself back (best-effort) and throws `StaleSessionRefreshException` instead of resurrecting a wiped session.
- A `RefreshTokenFailedException` (the only fatal type that crosses the caller boundary) reaches `MailboxDashBoardController`'s `BaseController` handling (`validateUrgentException` / `handleUrgentException`), the same path the interceptor's own rejected requests take.
- `ComposerAttachmentExtensionRegistry`'s Workplace wiring passes an `oidcRefreshTrigger` callback into `WorkplaceComposerAttachmentExtension`, alongside the existing `oidcTokenGetter`, mirroring the same callback-injection pattern across the package boundary.
- `WorkplaceComposerAttachmentExtension._exchangeAccessToken` catches a 401 from the token-exchange call and retries exactly once with a token refreshed via `oidcRefreshTrigger`, guarded by a `refreshAttempted` flag to prevent looping.

## Consequences

- A stale OIDC id token on the Workplace exchange-token request self-heals via one retry instead of surfacing as a generic toast.
- A 401 on the main Dio and a 401 on Workplace's Dio racing at the same time still trigger exactly one refresh call against the server; both callers resolve to the same new token.
- `WorkplaceDio` remains a plain, interceptor-free `Dio()`; only the exchange-token call site gains retry logic, not every Workplace request.
- Fatal-vs-transient classification for a dead refresh token lives in one place, so it forces logout consistently regardless of which request discovered it; a same-token response is still each caller's own concern to detect and retry against.
- A session cleared while a refresh is still writing never ends up looking authenticated: the generation check catches every write site the refresh can land on.
