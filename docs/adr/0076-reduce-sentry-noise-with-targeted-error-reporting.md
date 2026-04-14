# 0076 - Reduce Sentry Event Volume

Date: 2026-04-02

## Status

Proposed — needs ADR-0078 to be implemented first

## Context

Sentry is receiving too many low-value events, making it hard to triage real errors and draining quota. Four root causes were identified:

1. **`logTrace` sends Sentry events.** `_shouldReportToSentry` includes `Level.trace`, which is called on every scroll, cache hit, and token validation — high-frequency diagnostics with no actionable value.

2. **`RemoteExceptionThrower` calls `logError` before re-throwing.** Every `DioException` — including expected ones like no internet, connection timeout, and HTTP 401 — is sent to Sentry before being re-thrown as a typed exception.

3. **`SendEmailExceptionThrower` calls `logError` for network loss.** Loss of connectivity is a normal user-facing condition, not an application bug.

4. **`tracesSampleRate` and `profilesSampleRate` are set to 1.0 (100%).** Given JMAP's high request frequency (push, sync, email fetch), 100% sampling rapidly consumes quota.

## Decision

### 1. Remove `Level.trace` from Sentry reporting

`logTrace` calls will no longer create Sentry events. Trace context is preserved as Sentry Breadcrumbs — stored locally and attached automatically to the next error event (see ADR-0078 for the implementation mechanism).

### 2. Log expected network errors as warnings, not errors

In `RemoteExceptionThrower`, replace the blanket `logError` at the top of `throwException` with per-branch logging:

- `NoNetworkError`, `ConnectionTimeout`, `ConnectionError` → `logWarning`
- HTTP 401 (`BadCredentialsException`) → no log (handled by auth retry flow)
- HTTP 403, 404, 429 and other unlisted 4xx → `logWarning` (client errors, not application bugs)
- HTTP 500, 502 and other 5xx → `logWarning`
- Unknown HTTP status or unrecognised error → `logError` (genuinely unexpected; should appear in Sentry)

In `SendEmailExceptionThrower`, replace `logError` for no realtime network with `logWarning`.

### 3. Add `ignoredExceptions` as a safety net

Configure the Sentry SDK to drop expected exception types at the SDK level. This acts as a second line of defence if a call site accidentally logs them as errors:

```dart
options.addIgnoredExceptionType(NoNetworkError);
options.addIgnoredExceptionType(ConnectionTimeout);
options.addIgnoredExceptionType(ConnectionError);
options.addIgnoredExceptionType(SocketError);
```

### 4. Drop HTTP 4xx and 5xx events in `beforeSend`

Extend `_beforeSendHandler` to return `null` for HTTP 4xx and 5xx events by default.

This is a second line of defence: Decision 2 already routes these to `logWarning` (which never creates Sentry events), but `beforeSend` filtering guards against future regressions where a call site accidentally uses `logError` for an expected HTTP error.

**Exception:** authentication-critical 4xx events must be retained. Specifically, HTTP 400 responses from the refresh-token and retry-flow paths in `AuthorizationInterceptors` are genuine failure signals that require developer visibility. These call sites must tag the event so `beforeSend` allows them through:

```dart
logError(
  'Refresh token request failed',
  exception: exception,
  extras: {'auth_critical': true},
);
```

The `beforeSend` handler checks for `extras['auth_critical'] == true` and skips the filter for those events. This allowlist must be documented in code alongside the `beforeSend` implementation so future maintainers do not inadvertently suppress or re-add these events.

Note: the `AuthorizationInterceptors` call sites described in the **Unchanged** section below require a one-line update to add this tag — they are not truly unchanged, just unchanged in log *level*.

### 5. Reduce performance sampling rates

Lower `tracesSampleRate` and `profilesSampleRate` from `1.0` to `0.1` in `SentryConfig`. 10% sampling is sufficient to detect performance regressions without exhausting quota.

## Consequences

**Benefits:**
- Sentry events reflect genuine, actionable bugs — not connectivity noise or routine diagnostics.
- Quota savings from both event filtering and reduced sampling.
- Trace context (from `logTrace`) remains available in Sentry, attached to actual error events.

**Trade-offs:**
- Routine network errors (`NoNetworkError`, `ConnectionTimeout`) are no longer visible in Sentry. Use `logWarning` + LogTracking export for analysis if needed.
- New `logError` call sites must be intentional — only use when the error requires developer action.

**Unchanged:**
- `FlutterError.onError`, `PlatformDispatcher.instance.onError`, and `runZonedGuarded` continue to use `logError` — unhandled errors must always be monitored.
- `AuthorizationInterceptors` `logError` for refresh token failure (HTTP 400) and retry failure remains.

## Logging Guidelines

| Situation | Log function | Sentry result |
|-----------|--------------|---------------|
| App crash / unhandled exception | `logError` / `logCritical` | ✅ Event |
| Refresh token failure, retry failure | `logError` + `auth_critical: true` tag | ✅ Event (allowlisted in `beforeSend`) |
| Unknown HTTP status or unrecognised error | `logError` | ✅ Event |
| HTTP 4xx (excl. auth-critical), network loss, timeout | `logWarning` | ❌ Not sent |
| HTTP 5xx (known: 500, 502; unknown: other 5xx) | `logWarning` | ❌ Not sent |
| Diagnostic info (scroll, cache, counts) | `logTrace` | 🔶 Breadcrumb only |
| Normal flow information | `logInfo` | ❌ Not sent |
