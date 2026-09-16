# 0109 - Control Sentry SDK Lifecycle with Reporting Consent

Date: 2026-09-16

## Status

Accepted

## Context

The Sentry reporting preference can change while the application is running.
Dart capture gates and `beforeSend` callbacks do not cover all autonomous native telemetry, such as crashes, Android ANRs, iOS hangs, and sessions.
Permanently disabling native integrations would prevent that telemetry, but would also remove native observability after the user opts in.

## Decision

Effective reporting consent controls the complete Sentry SDK lifecycle.

- When reporting is denied, the application does not initialize Sentry or closes the running SDK with `Sentry.close()`.
- When reporting is allowed, the application initializes Sentry with its native integrations enabled.
- Runtime capture checks and Dart `beforeSend` callbacks remain as defence in depth during asynchronous lifecycle transitions.
- Lifecycle transitions are serialized, and an SDK initialized after consent is revoked is closed before application capture paths can use it.
- Reinitialization never invokes the Flutter `appRunner` again.

Session Replay remains disabled because Sentry Flutter 9.8.0 cannot both stop recording and safely discard an existing Replay buffer when consent is revoked.
Background FCM handlers read persisted consent before each event and treat missing, invalid, or unreadable values as denied.
Timed-out background setup is invalidated and cannot later enable Sentry, while notification processing continues without telemetry.
The iOS notification service extension applies the same fail-closed rule from Keychain.

## Consequences

When consent is enabled, Dart and native reporting remain available; when it is disabled, both stop.
Re-enabling reporting requires another SDK initialization, and errors that occur while Sentry is stopped cannot be recovered.
