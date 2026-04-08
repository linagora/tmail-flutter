# 0078 - app_logger Handler Pipeline

Date: 2026-04-03

## Status

Proposed

## Context

`app_logger.dart` has one function, `_internalLog`, that handles five distinct concerns: formatting messages, printing to the console, deciding whether to send to Sentry, calling `SentryManager.captureException`, and providing the public API. This leads to three problems:

- **Not extensible:** Adding a new log destination (e.g., Sentry Breadcrumbs, file logger) requires modifying `_internalLog` directly.
- **Invisible coupling:** Whether `logTrace` sends a Sentry event is not visible at call sites — it was added silently to `_shouldReportToSentry`, which is how ADR-0076 root cause #1 occurred.
- **Untestable:** `_internalLog` depends on `SentryManager.instance` and `html.window.console` directly, with no injection point.

ADR-0076 requires `logTrace` to add a Sentry Breadcrumb instead of a full event.
This change cannot be made cleanly without an extension point in the logger.

The intended behaviour is: each `logTrace()` call stores a breadcrumb locally inside Sentry's buffer; when `logError()` is eventually called, Sentry automatically attaches all accumulated breadcrumbs to that error event, providing the full call trail leading up to the failure — without sending any quota-consuming events for the trace calls themselves.

```
logTrace("fetching mailbox list")   ──► [Breadcrumb #1 stored in Sentry buffer]
logTrace("cache miss, going remote") ──► [Breadcrumb #2 stored in Sentry buffer]
logError("JMAP request failed")     ──► [Sentry Event]
                                            └─ breadcrumbs: [#1, #2]  ← attached automatically
```

## Decision

Refactor `app_logger.dart` to a **handler pipeline**. Each log destination becomes a `LogHandler` implementation registered at startup. The public API (`logError`, `logTrace`, etc.) is unchanged.

### Core abstractions

```dart
// log_handler.dart
abstract interface class LogHandler {
  bool handles(Level level);
  void handle(LogRecord record);
}
```

`AppLoggerRegistry` holds a list of handlers and dispatches each `LogRecord` to all handlers where `handles()` returns `true`. The `_shouldReportToSentry` function is deleted — each handler owns its own filter rule.

### Handlers

| Handler | `handles()` | Behaviour |
|---------|-------------|-----------|
| `ConsoleLogHandler` | all levels | `print()` or `html.window.console.*` (filtered by debug mode / `webConsoleEnabled`) |
| `SentryEventHandler` | `error`, `critical` | `captureException` if exception present; `captureMessage` otherwise |
| `SentryBreadcrumbHandler` | `trace` | `Sentry.addBreadcrumb()` — zero quota cost; attached to next error event |

`captureMessage` is not assigned to a dedicated level. `SentryEventHandler` selects between `captureException` and `captureMessage` based on whether the `LogRecord` contains an exception object. This keeps `logError` as a single API regardless of whether the caller has an exception.

### File structure

```
core/lib/utils/
├── app_logger.dart               ← public API only; delegates to AppLoggerRegistry
└── logging/
    ├── log_record.dart           ← data class
    ├── log_handler.dart          ← abstract interface
    ├── app_logger_registry.dart  ← dispatch orchestrator
    ├── handlers/
    │   ├── console_log_handler.dart
    │   ├── sentry_event_handler.dart
    │   └── sentry_breadcrumb_handler.dart
    └── formatters/
        ├── log_formatter.dart
        ├── web_console_formatter.dart
        └── mobile_console_formatter.dart
```

### Registration

Handlers are registered once at app startup in `app_runner.dart`. Sentry handlers check `isSentryAvailable` internally, so they can be registered before Sentry initialises.

```dart
AppLoggerRegistry.instance
  ..registerHandler(ConsoleLogHandler(formatter: ...))
  ..registerHandler(SentryBreadcrumbHandler(SentryManager.instance))
  ..registerHandler(SentryEventHandler(SentryManager.instance));
```

**Idempotency and duplicate prevention:**

`registerHandler` checks handler identity by runtimeType before adding. Registering the same handler type a second time (e.g., due to a hot restart or repeated bootstrap call) is a no-op — the existing registration is kept and no duplicate is added. This prevents double console output and duplicate Sentry captures without requiring callers to guard the registration site.

For test isolation, `AppLoggerRegistry.resetForTesting()` clears all registered handlers. Tests that need a clean registry must call this in `setUp` / `tearDown`. Production code must never call `resetForTesting`.

## Implementation

| Phase | Scope | Notes |
|-------|-------|-------|
| 1 + 2 | Skeleton + ConsoleLogHandler | One PR. Zero behavior change. `_internalLog` delegates to registry; console output restored via handler. |
| 3 | SentryEventHandler + SentryBreadcrumbHandler | Behavior-changing PR. `logTrace` → breadcrumb. `_shouldReportToSentry` deleted. |
| 4 | ADR-0076 call-site fixes | Parallel to Phase 3. `RemoteExceptionThrower`, `SendEmailExceptionThrower`, `SentryInitializer`. |
| 5 | Tests | `AppLoggerRegistry.resetForTesting()`, unit tests per handler, dispatch integration test. |
| 6 (optional) | `FileLogHandler` for `LogTracking` | Wraps the existing file logger; no changes to `LogTracking` itself. |

> ⚠️ Phase 1 must not be merged to production without Phase 2 — the registry starts empty, causing all logs to be dropped.

## Consequences

**Benefits:**
- Adding a new log destination requires only a new `LogHandler` and one registration line — no changes to existing code.
- Each handler is independently testable via constructor injection.
- The public API (`logError`, `logTrace`, etc.) is stable across all 188+ call sites.

**Trade-offs:**
- Slightly more indirection for a straightforward log call. Acceptable given the extensibility gain.
- `AppLoggerRegistry` uses a static singleton (not GetX) because the logger must be available before GetX initialises.

**Behavior change: `logError` without an exception object**

The current `app_logger.dart` always calls `captureException(exception ?? rawMessage, ...)` — passing the raw message string as the exception value when no exception object is present.

`SentryEventHandler` will instead call `captureMessage` when the `LogRecord` contains no exception. This means:

- **Before:** `logError('something went wrong')` → appears in Sentry as an *exception* with `rawMessage` as the exception value.
- **After:** `logError('something went wrong')` → appears in Sentry as a *message* event.

This is semantically correct — a string-only log is not an exception — but it is a visible change: Sentry dashboards, issue grouping, and alerts filtered by event type (exception vs. message) may need to be reviewed after rollout.
