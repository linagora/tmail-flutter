# 0076 - Reduce Sentry Noise with Targeted Error Reporting

Date: 2026-04-02

## Status

Proposed

## Context

Sentry is currently receiving too many events with low diagnostic value, making it hard to triage real errors and draining the Sentry quota. After auditing all logging call sites, four root causes were identified:

### 1. `logTrace` sends messages to Sentry

The `_shouldReportToSentry` function in `app_logger.dart` includes `Level.trace`:

```dart
bool _shouldReportToSentry(Level level) {
  return level == Level.error ||
      level == Level.critical ||
      level == Level.trace; // ← problem
}
```

`logTrace` is used for **high-frequency diagnostics**:

| Call site | Frequency |
|-----------|-----------|
| `ThreadController` — email list count, scroll position, load-more trigger | Every time the email list changes or the user scrolls |
| `ThreadRepositoryImpl` — cache hit/miss stats, email state | Every email fetch |
| `AuthorizationInterceptors` — `validateToRefreshToken`, `validateToRetryWithNewToken` | Every 401 request |
| `SentryConfig.load` — dist/version | Every app startup |

These are pure debug/trace logs, not errors. They inflate Sentry event volume without providing actionable information.

### 2. `RemoteExceptionThrower` logs every network error before re-throwing

```dart
// remote_exception_thrower.dart
throwException(dynamic error, dynamic stackTrace) {
  logError(  // ← sends to Sentry
    'RemoteExceptionThrower::throwException():error: $error',
    exception: error,
    stackTrace: stackTrace,
  );
  // ... then re-throws as a typed exception
}
```

This causes every `DioException` to be sent to Sentry as an error, including **completely expected** situations:

| Typed exception after re-throw | Actual cause |
|--------------------------------|--------------|
| `NoNetworkError` | User has no internet |
| `ConnectionTimeout` | Slow network |
| `ConnectionError` / `SocketError` | Network dropped |
| `BadCredentialsException` (HTTP 401) | Expired token, retry flow already handles this |
| `BadGateway` (HTTP 502) | Transient server error |

### 3. `SendEmailExceptionThrower` logs network loss as an error

```dart
// send_email_exception_thrower.dart
if (realtimeNetworkConnectionStatus == false) {
  logError('SendEmailExceptionThrower::throwException(): No realtime network connection');
  throw const NoNetworkError();
}
```

Loss of network connectivity is a normal user-facing condition, not an application bug.

### 4. `tracesSampleRate` and `profilesSampleRate` set to 1.0 (100%)

Defaults in `SentryConfig`:

```dart
this.tracesSampleRate = 1.0,  // 100% transaction traces
this.profilesSampleRate = 1.0, // 100% profiling
```

Given the high request frequency of JMAP (push, sync, email fetch), 100% sampling is excessive and rapidly consumes Sentry quota.

## Decision

### 1. Remove `Level.trace` from `_shouldReportToSentry`

`logTrace` is a high-frequency diagnostic log — it is never appropriate to send to a monitoring system.

```dart
// core/lib/utils/app_logger.dart
bool _shouldReportToSentry(Level level) {
  return level == Level.error || level == Level.critical;
  // trace removed
}
```

**Impact:** Eliminates all noise from scroll diagnostics, cache stats, and token validation flows.

### 2. Replace `logError` with `logWarning` in `RemoteExceptionThrower` for typed errors

Only log at `error` level (which sends to Sentry) for errors that are **genuinely unexpected** — those that do not match any known typed exception.

```dart
// remote_exception_thrower.dart
throwException(dynamic error, dynamic stackTrace) {
  // No logging here — each branch decides for itself
  final networkConnectionController = getBinding<NetworkConnectionController>();
  if (networkConnectionController?.isNetworkConnectionAvailable() == false) {
    logWarning('RemoteExceptionThrower: No network connection');
    throw const NoNetworkError();
  }
  handleDioError(error);
}

void handleDioError(dynamic error) {
  if (error is DioException) {
    if (error.error is RefreshTokenFailedException) throw RefreshTokenFailedException();

    final statusCode = error.response?.statusCode;
    if (statusCode != null) {
      switch (statusCode) {
        case HttpStatus.internalServerError:
          logWarning('RemoteExceptionThrower: HTTP 500');
          throw const InternalServerError();
        case HttpStatus.badGateway:
          logWarning('RemoteExceptionThrower: HTTP 502');
          throw BadGateway();
        case HttpStatus.unauthorized:
          // 401 is handled by auth retry flow — no error log
          throw const BadCredentialsException();
        default:
          // Unknown status code → this is a real error
          logError('RemoteExceptionThrower: Unexpected HTTP $statusCode', exception: error);
          throw UnknownRemoteException(code: statusCode, message: error.response?.statusMessage);
      }
    }
    return _handleDioErrorWithoutResponse(error);
  }

  if (error is ErrorMethodResponseException) { /* ... keep as-is */ }

  // Unknown error → log as error
  logError('RemoteExceptionThrower: Unexpected error', exception: error, stackTrace: stackTrace);
  throw error;
}

void _handleDioErrorWithoutResponse(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
      logWarning('RemoteExceptionThrower: Connection timeout');
      throw ConnectionTimeout(message: error.message);
    case DioExceptionType.connectionError:
      logWarning('RemoteExceptionThrower: Connection error');
      throw ConnectionError(message: error.message);
    // ...
  }
}
```

### 3. Replace `logError` with `logWarning` in `SendEmailExceptionThrower` for network loss

```dart
// send_email_exception_thrower.dart
if (realtimeNetworkConnectionStatus == false) {
  logWarning('SendEmailExceptionThrower: No realtime network connection');
  throw const NoNetworkError();
}
```

### 4. Add `ignoredExceptions` in Sentry initialization

Configure the Sentry SDK to drop exception classes that are **fully handled at the presentation layer**:

```dart
// sentry_initializer.dart
options.addIgnoredExceptionType(NoNetworkError);
options.addIgnoredExceptionType(ConnectionTimeout);
options.addIgnoredExceptionType(ConnectionError);
options.addIgnoredExceptionType(SocketError);
```

This acts as a second line of defense: if any call site accidentally calls `logError` with these exceptions, the Sentry SDK will drop them before they are sent.

### 5. Add `beforeSend` filter for HTTP 4xx client errors

Extend `_beforeSendHandler`:

```dart
static Future<SentryEvent?> _beforeSendHandler(SentryEvent event, Hint? hint) async {
  // Drop 4xx errors — these are client-side errors handled by the domain layer
  final statusCode = event.request?.other?['statusCode'] as int?;
  if (statusCode != null && statusCode >= 400 && statusCode < 500) {
    return null; // Drop event
  }

  event.request = _sanitizeRequest(event.request);
  event.exceptions = _deminifyExceptions(event.exceptions);
  return event;
}
```

### 6. Reduce `tracesSampleRate` and `profilesSampleRate`

Update `SentryConfig` defaults:

```dart
SentryConfig({
  // ...
  this.tracesSampleRate = 0.1,  // 10% instead of 100%
  this.profilesSampleRate = 0.1, // 10% instead of 100%
  // ...
});
```

10% is sufficient to detect performance regressions in production without burning through quota.

## Consequences

### Benefits

- **Significant reduction in Sentry event volume**: Eliminates all `logTrace` events (scroll, cache stats, token flow) and routine network errors
- **Higher signal-to-noise ratio**: Sentry alerts genuinely reflect bugs requiring action, not diluted by connectivity issues
- **Sentry quota savings**: From both event filtering and reduced sample rates
- **Critical errors still captured**: Unexpected HTTP errors, unhandled exceptions, `FlutterError`, `PlatformDispatcher` errors — all still sent in full

### Trade-offs

- **Reduced visibility into routine network errors**: The team will no longer see `NoNetworkError` / `ConnectionTimeout` in Sentry — use `logWarning` + log export (LogTracking) if analysis is needed
- **Care required when adding new `logError` calls**: Only use `logError` when the error is genuinely unexpected and requires action from the dev team

### Unchanged

- Global error handlers (`FlutterError.onError`, `PlatformDispatcher.instance.onError`, `runZonedGuarded`) continue to use `logError` — these are truly unhandled errors that must be monitored
- `AuthorizationInterceptors::logError` for **refresh token 400** and **retry failure** remains — these are serious auth errors requiring attention
- `CacheExceptionThrower` should be evaluated separately in a follow-up ticket

## Logging Guidelines After This ADR

| Situation | Log function | Sent to Sentry? |
|-----------|--------------|-----------------|
| App crash / unhandled exception | `logError` / `logCritical` | ✅ Yes |
| Refresh token failure (HTTP 400) | `logError` | ✅ Yes |
| Retry request failure | `logError` | ✅ Yes |
| HTTP 5xx from server | `logWarning` | ❌ No |
| HTTP 4xx (401, 404, ...) | `logWarning` | ❌ No |
| Network connectivity loss | `logWarning` | ❌ No |
| Connection timeout / socket error | `logWarning` | ❌ No |
| Diagnostic info (scroll, cache, count) | `logTrace` | ❌ No |
| Normal flow information | `logInfo` | ❌ No |
