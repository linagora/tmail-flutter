# 69. Logger Standardization and Logging Best Practices

Date: 2025-08-18

## Status

Accepted

## Context

The `tmail-flutter` application uses a custom `app_logger` abstraction to unify logging across platforms (Web and Mobile) and environments (debug vs production).

Over time, logging usage became inconsistent:
- `logError` was used in non-critical or recoverable scenarios.
- Error-level logs generated excessive noise in monitoring tools (e.g. Sentry).
- There was no clear, documented guideline describing when to use each log level.
- Reviewers requested a descriptive piece of developer documentation explaining good logging practices.

As part of PR #4205, the logging system was refactored to normalize log severity usage and prepare the codebase for reliable integration with Sentry and similar monitoring tools.

## Decision

### Defined log levels and intent

| Level | Function | Intended usage |
|------|---------|----------------|
| critical | logCritical | System-level, unrecoverable failures (extremely rare) |
| error | logError | Critical, actionable failures that must be monitored |
| warning | logWarning | Recoverable issues or degraded behavior |
| info | logInfo / log | Normal application lifecycle events |
| debug | logDebug | Developer debugging information |
| trace | logVerbose | High-volume diagnostic logs |

### Restriction of logError usage

`logError` is restricted to infrastructure-level classes where failures are non-recoverable and must be monitored.

Allowed classes:
- AuthorizationInterceptors
- CacheExceptionThrower
- RemoteExceptionThrower

All other cases must use `logWarning`.

### Logger behavior

- Platform-aware formatting (Web vs Mobile)
- Consistent message normalization
- Debug-only printing unless explicitly enabled

### Error boundary

Global error handling is implemented via `initLogger`, ensuring framework and async errors are logged as warnings rather than errors.

## Consequences

### Benefits
- Reduced noise in error monitoring
- Clear logging conventions
- Improved reviewability
- Better Sentry signal quality

### Trade-offs
- Stricter logging rules
- Reduced visibility for non-critical failures

## Developer Logging Guidelines

- Use logError only for critical, non-recoverable issues
- Use logWarning for handled or recoverable failures
- Avoid logging sensitive data
- Prefer descriptive messages with context
