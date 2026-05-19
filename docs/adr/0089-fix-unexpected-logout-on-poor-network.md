# 0089. Fix Unexpected Logout on Poor Network (Mobile Only)

Date: 2026-05-18
Updated: 2026-05-19

## Status

Accepted

## Context

On poor network (train, tunnel, intermittent WiFi), mobile users are logged out mid-session even though their session and refresh token are valid. The bug was reported on mobile only. Web is unaffected — the fixes are intentionally scoped to `PlatformInfo.isMobile` to minimise review surface and avoid changing web behaviour that was not reported broken.

Two independent bugs allow `clearDataAndGoToLoginPage()` to fire on transient network failures.

### Bug 1 — Interceptor propagates stale 401 on network failure during token refresh/retry

`lib/features/login/data/network/interceptors/authorization_interceptors.dart`

When token refresh or retry fails due to network error, the catch block calls `err.copyWith(error: refreshError)`. `copyWith` replaces only the `error` payload; the original `response` field (the 401 that triggered the flow) is preserved. Downstream, `RemoteExceptionThrower` sees 401 → `BadCredentialsException` → logout.

Affects three paths on mobile:
- **Path 1:** Access token expired → refresh HTTP call times out.
- **Path 2:** Server-side session invalidation returns 401; `validateToRefreshToken` fires unconditionally, times out on poor network.
- **Path 3:** Two concurrent requests both get 401 → one completes refresh → second retry times out → stale 401 preserved → logout.

**Additional finding — outer `catch` also affected (mobile OIDC only):**

On mobile OIDC, `_authenticationClient.refreshingTokensOIDC()` calls `_appAuth.token()` via MethodChannel (native AppAuth SDK — not Dio). Network failure from native SDK propagates as `PlatformException` or `FlutterAppAuthPlatformException`. Neither is a `DioException`, so both bypass the inner `on DioException catch` and reach the outer `catch`. The old `else` branch there also called `err.copyWith(error: e)`, preserving the stale 401. Only the explicit `ServerError`/`TemporarilyUnavailable` check was correct; all other non-DioException types were broken. This path does not exist on web (no native AppAuth SDK).

### Bug 2 — `handleGetSessionFailure` logs out for any exception type (mobile only)

`lib/features/base/reloadable/reloadable_controller.dart`

On app start/resume, `getSessionAction()` fetches JMAP session. On mobile, `GetSessionInteractor` falls back to Hive cache on failure. If cache is empty (fresh install or wiped by Bug 1's `cachingManager.clearAll()`), `GetSessionFailure(ConnectionTimeout)` is emitted. The handler calls `clearDataAndGoToLoginPage()` unconditionally for all exception types. `validateUrgentException` does not include `ConnectionTimeout`, `SocketError`, or `UnknownRemoteException`, so these fall through and cause logout. Web does not use Hive session cache, so the original logout-on-failure behaviour is correct there.

## Decision

All fixes are guarded by `PlatformInfo.isMobile`. Web retains the original logic.

### Fix 1 — Mobile only: pass refresh errors directly without preserving stale 401 response

Root cause: `copyWith` leaves the original `response` (the 401) intact.

**Mobile behaviour:**
- **Refresh failure path (inner catch, `response == null`):** create fresh `DioException` without any response.
- **Refresh failure path (`response != null`, non-400):** pass `refreshError` directly — own response, not stale 401.
- **Retry failure path:** if `DioException`, pass directly; otherwise wrap in fresh `DioException` with no response.

**Web behaviour (unchanged):** `err.copyWith(error: refreshError/retryError)` — original logic preserved.

### Fix 2 — Mobile only: guard `handleGetSessionFailure` against network exceptions

Check `PlatformInfo.isMobile && exception is NetworkException` before `clearDataAndGoToLoginPage()`. `ConnectionTimeout`, `SocketError`, `ConnectionError`, `NoNetworkError` all extend `NetworkException`. On mobile network exception: show toast, return — no logout.

**Web behaviour (unchanged):** any non-BadCredentials exception still calls `clearDataAndGoToLoginPage()`.

### Fix 3 — Mobile only: strip stale 401 in outer catch for non-DioException network errors

Outer `catch` in `onError` handles all non-DioException types (`FlutterAppAuthPlatformException`, `PlatformException`, `OAuthAuthorizationError`).

**Mobile behaviour:** if `e` is a `DioException` with non-null response, pass `e` directly; otherwise wrap in fresh `DioException` with no response. Subsumes the old `ServerError`/`TemporarilyUnavailable` branch and covers all future non-DioException types.

**Web behaviour (unchanged):** `if (e is ServerError || e is TemporarilyUnavailable)` → fresh `DioException`; else → `err.copyWith(error: e)`.

## Consequences

- **Mobile:** Network timeouts during token refresh or retry no longer cause logout; connectivity error propagates instead.
- **Mobile:** `FlutterAppAuthPlatformException` and `PlatformException` from `_appAuth.token()` (OIDC, no internet) no longer cause logout.
- **Mobile:** Session fetch failure on poor network shows toast; user stays logged in.
- **Web:** All three paths are unchanged — no behavioural difference from before this PR.
- Real HTTP error responses (400, 401, 5xx) from refresh endpoint or original request still propagate correctly on both platforms.
- Fix 2 does not affect `validateUrgentException` — that early-exit path is unchanged.
