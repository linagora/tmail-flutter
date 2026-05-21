# 0089. Fix Unexpected Logout on Poor Network

Date: 2026-05-18
Updated: 2026-05-21

## Status

Accepted

## Context

On poor network (train, tunnel, intermittent WiFi), users were logged out mid-session even though their session and refresh token were valid.

Two independent bugs allow `clearDataAndGoToLoginPage()` to fire on transient network failures.

### Bug 1 — Interceptor propagates stale 401 on network failure during token refresh/retry

`lib/features/login/data/network/interceptors/authorization_interceptors.dart`

When token refresh or retry fails due to network error, the catch block called `err.copyWith(error: refreshError)`. `copyWith` replaces only the `error` payload; the original `response` field (the 401 that triggered the flow) is preserved. Downstream, `RemoteExceptionThrower` sees 401 → `BadCredentialsException` → logout.

Affects three paths:

- **Path 1:** Access token expired → refresh HTTP call times out.
- **Path 2:** Server-side session invalidation returns 401; `validateToRefreshToken` fires unconditionally, times out on poor network.
- **Path 3:** Two concurrent requests both get 401 → one completes refresh → second retry times out → stale 401 preserved → logout.

**Additional finding — outer `catch` also affected:**

On mobile OIDC, `_authenticationClient.refreshingTokensOIDC()` calls `_appAuth.token()` via MethodChannel (native AppAuth SDK — not Dio). Network failure from native SDK propagates as `PlatformException` or `FlutterAppAuthPlatformException`. Neither is a `DioException`, so both bypass the inner `on DioException catch` and reach the outer `catch`. The old `else` branch called `err.copyWith(error: e)`, preserving the stale 401.

### Bug 2 — `handleGetSessionFailure` logs out for any exception type

`lib/features/base/reloadable/reloadable_controller.dart`

On app start/resume, `getSessionAction()` fetches JMAP session. On mobile, `GetSessionInteractor` falls back to Hive cache on failure. If cache is empty (fresh install or wiped by Bug 1's `cachingManager.clearAll()`), `GetSessionFailure(ConnectionTimeout)` is emitted. The handler called `clearDataAndGoToLoginPage()` unconditionally for all exception types. `validateUrgentException` does not include `ConnectionTimeout`, `SocketError`, or `UnknownRemoteException`, so these fall through and cause logout.

## Decision

### Fix 1 — Unified: pass error/refresh errors without preserving stale 401 response

Root cause: `copyWith` leaves the original `response` (the 401) intact.

**All platforms (unified behaviour):**

- **Refresh failure path (inner catch, `response == null`):** create fresh `DioException` without any response.
- **Refresh failure path (`response != null`, non-400):** pass `refreshError` directly — own response, not stale 401.
- **Retry failure path:** if `DioException`, pass directly; otherwise wrap in fresh `DioException` with no response.
- **Outer catch:** if `e is DioException && e.response != null`, pass `e` directly; otherwise wrap in fresh `DioException` with no response.

Dead code removed: `if (refreshError is ServerError || refreshError is TemporarilyUnavailable)` in `_handleDioRefreshError` — `refreshError` is typed as `DioException`, those types don't extend it, so the check could never be true.

### Fix 2 — All platforms: guard `handleGetSessionFailure` against network exceptions

Check `exception is NetworkException` before `clearDataAndGoToLoginPage()`. `ConnectionTimeout`, `SocketError`, `ConnectionError`, `NoNetworkError` all extend `NetworkException`. On network exception: show toast, return — no logout on any platform.

## Consequences

- **All platforms:** Network timeouts during token refresh or retry no longer cause logout; connectivity error propagates instead.
- **All platforms:** `FlutterAppAuthPlatformException` and `PlatformException` from `_appAuth.token()` (OIDC, no internet) no longer cause logout.
- **All platforms:** Session fetch failure on poor network shows toast; user stays logged in.
- Real HTTP error responses (400, 401, 5xx) from refresh endpoint or original request still propagate correctly on all platforms.
- Fix 2 does not affect `validateUrgentException` — that early-exit path is unchanged.
