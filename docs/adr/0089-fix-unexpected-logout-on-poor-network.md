# 0089. Fix Unexpected Logout on Poor Network

Date: 2026-05-18

## Status

Accepted

## Context

On poor network (train, tunnel, intermittent WiFi), users are logged out mid-session even though their session and refresh token are valid. Two independent bugs allow `clearDataAndGoToLoginPage()` to fire on transient network failures.

### Bug 1 — Interceptor propagates original 401 response on network failure during token refresh/retry

`lib/features/login/data/network/interceptors/authorization_interceptors.dart`

When a token refresh or request retry fails due to a network error (timeout, connection drop), the catch block calls `err.copyWith(error: refreshError)`. `copyWith` replaces only the `error` payload; the original `response` field — the 401 that triggered the flow — is preserved. Downstream, `RemoteExceptionThrower` inspects the response status code, sees 401, and converts it to `BadCredentialsException` → `clearDataAndGoToLoginPage()`.

```dart
// refresh failure path
} catch (refreshError) {
  // ...
  } else {
    // BUG: err still carries original 401 response
    return super.onError(err.copyWith(error: refreshError), handler);
  }
}

// retry failure path
} catch (retryError) {
  return super.onError(
    err.copyWith(error: retryError), // same bug
    handler,
  );
}
```

This affects three code paths:
- **Path 1:** Access token expired → server returns 401 → refresh HTTP call times out.
- **Path 2:** Server-side session invalidation (server restart, forced logout) returns 401 while local token is still valid. `validateToRefreshToken` does not check local token expiry, so it fires unconditionally and times out on a poor network.
- **Path 3:** Two concurrent JMAP requests both get 401 → one completes refresh → second request's retry times out → same 401 preserved → logout.

### Bug 2 — `handleGetSessionFailure` logs out for any exception type

`lib/features/base/reloadable/reloadable_controller.dart`

On app start or resume, `getSessionAction()` fetches the JMAP session. On mobile, `GetSessionInteractor` falls back to Hive session cache on failure. If the cache is empty (fresh install, or wiped by Bug 1's `cachingManager.clearAll()`), `GetSessionFailure(ConnectionTimeout)` is emitted. The handler calls `clearDataAndGoToLoginPage()` unconditionally:

```dart
void handleGetSessionFailure(GetSessionFailure failure) {
  if (failure.exception is! BadCredentialsException) {
    toastManager.showMessageFailure(failure);
  }
  clearDataAndGoToLoginPage(); // called for ALL exception types
}
```

`validateUrgentException` does not include `ConnectionTimeout`, `SocketError`, or `UnknownRemoteException`, so these fall through to `handleGetSessionFailure` and cause logout.

## Decision

### Fix 1 — Strip 401 response from DioException on network-only failure

When `refreshError.response == null` (no HTTP response = pure network error), construct a fresh `DioException` without the original 401 `response` field. Apply the same pattern to the retry failure catch block. Checking `response == null` correctly covers all network-layer failures — timeouts, send/receive timeouts, socket errors — while leaving real HTTP error responses (400, 401, 5xx) to propagate normally.

```dart
// Refresh failure path
} else if (refreshError.response == null) {
  return super.onError(
    DioException(
      requestOptions: err.requestOptions,
      type: refreshError.type,
      error: refreshError.error,
      message: refreshError.message,
    ),
    handler,
  );
} else {
  return super.onError(err.copyWith(error: refreshError), handler);
}

// Retry failure path
} catch (retryError) {
  if (retryError is DioException && retryError.response == null) {
    return super.onError(
      DioException(
        requestOptions: err.requestOptions,
        type: retryError.type,
        error: retryError.error,
        message: retryError.message,
      ),
      handler,
    );
  }
  return super.onError(err.copyWith(error: retryError), handler);
}
```

### Fix 2 — Guard `handleGetSessionFailure` against network exceptions

Check `exception is NetworkException` before reaching `clearDataAndGoToLoginPage()`. `ConnectionTimeout`, `SocketError`, `ConnectionError`, and `NoNetworkError` all extend `NetworkException`. On a network exception, show a toast and return — no logout. The guard belongs in `handleGetSessionFailure` to keep the fix local and reviewable.

```dart
void handleGetSessionFailure(GetSessionFailure failure) {
  final exception = failure.exception;
  if (exception is NetworkException) {
    toastManager.showMessageFailure(failure);
    return; // transient — stay logged in
  }
  if (exception is! BadCredentialsException) {
    toastManager.showMessageFailure(failure);
  }
  clearDataAndGoToLoginPage();
}
```

## Consequences

- Network timeouts during token refresh or retry no longer cause logout; a connectivity error is propagated instead.
- Session fetch failure on poor network shows a toast; user stays logged in.
- Fix 1 does not change behaviour when the refresh or retry receives an actual HTTP error response (400, 401, 5xx) — those still propagate correctly.
- Fix 2 does not affect `validateUrgentException` — that early-exit path is unchanged.
