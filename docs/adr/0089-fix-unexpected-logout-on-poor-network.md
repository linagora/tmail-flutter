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

**Additional finding — outer `catch` also affected (`FlutterAppAuthPlatformException`):**

The `on DioException catch (refreshError, st)` block only handles `DioException`. On mobile with OIDC, `_authenticationClient.refreshingTokensOIDC()` calls `_appAuth.token()`, which is a MethodChannel bridge to the native AppAuth SDK — not a Dio HTTP call. When there is no internet, the native SDK failure propagates through `MethodChannelFlutterAppAuth.invokeMethod()` as either a raw `PlatformException` (when the native side sends no structured details, i.e. `e.details == null`) or a `FlutterAppAuthPlatformException` (when structured details are present but carry no OAuth `error` code for a transport failure). In both cases `handleException()` in `AuthenticationClientInteractionMixin` passes the exception through unchanged — raw `PlatformException` does not match the `is FlutterAppAuthPlatformException` check, and `FlutterAppAuthPlatformException` with `platformErrorDetails.error == null` exits without mapping.

Neither exception type is a `DioException`, so both bypass the inner `on DioException catch` entirely and propagate to the outer `catch (e, stackTrace)` block. The original `else` branch there also called `err.copyWith(error: e)`, preserving the 401 response and triggering the same logout path. The only case that correctly stripped the 401 was the explicit `ServerError`/`TemporarilyUnavailable` check; all other non-DioException types were broken.

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

### Fix 1 — Strip 401 response from DioException on network-only failure (inner catch)

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

### Fix 3 — Strip 401 response in outer catch for non-DioException network errors

The outer `catch (e, stackTrace)` in `onError` previously used `err.copyWith(error: e)` for all exceptions that were not `ServerError`/`TemporarilyUnavailable`. This is wrong for `FlutterAppAuthPlatformException` and any other non-DioException thrown during token refresh on poor network. The only case where preserving the original response is meaningful is when `e` is itself a `DioException` that carries a real HTTP error response. All other cases should produce a fresh `DioException` without the 401.

```dart
// Outer catch — replaces the old ServerError/TemporarilyUnavailable + else split
if (e is DioException && e.response != null) {
  return super.onError(err.copyWith(error: e), handler);
}
return super.onError(
  DioException(requestOptions: err.requestOptions, error: e),
  handler,
);
```

This subsumes the old `ServerError`/`TemporarilyUnavailable` branch (those are not `DioException`, so `e is DioException` is false → fresh `DioException`) and covers `FlutterAppAuthPlatformException` and any other future non-DioException.

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
- `FlutterAppAuthPlatformException` from `_appAuth.token()` on mobile (OIDC, no internet) no longer causes logout — covered by Fix 3.
- Session fetch failure on poor network shows a toast; user stays logged in.
- Fix 1 does not change behaviour when the refresh or retry receives an actual HTTP error response (400, 401, 5xx) — those still propagate correctly.
- Fix 3 preserves the original `err` response only when `e` itself is a `DioException` with a non-null HTTP response, which cannot happen from inside the `on DioException catch` block (those are already handled there). The condition is thus effectively always false for exceptions that reach the outer catch from the refresh path, but is retained as a safe guard.
- Fix 2 does not affect `validateUrgentException` — that early-exit path is unchanged.
