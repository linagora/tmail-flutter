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

### Platform flows

| Web | Mobile |
| --- | --- |
| Load technical config from `env.file`<br>↓<br>Initialize Sentry before `appRunner` when the env config is valid and enabled<br>↓<br>Apply account reporting consent as it becomes available<br>↓<br>Stop reporting when neither the server nor ecosystem provides consent | Start the app without Sentry<br>↓<br>Load technical config from the ecosystem<br>↓<br>Keep Sentry stopped when the config is missing, invalid, or unavailable<br>↓<br>Initialize Sentry when the config is valid and effective consent allows reporting |

Once account policy is resolved, effective consent is `server sentryUserOptIn ?? ecosystem userOptInByDefault ?? false`. A non-null server value always takes precedence, and technical availability (`enabled`, DSN, and environment) does not override this result. Reporting is suspended when ecosystem resolution starts or later becomes loading or unavailable.

Session Replay remains disabled because Sentry Flutter 9.8.0 cannot both stop recording and safely discard an existing Replay buffer when consent is revoked.
Background FCM handlers read persisted consent before each event and treat missing, invalid, or unreadable values as denied.
Timed-out background setup is invalidated and cannot later enable Sentry, while notification processing continues without telemetry.
The iOS notification service extension applies the same fail-closed rule from Keychain.
It also blocks reporting when the shared DSN or environment no longer matches the active NSE SDK instance, instead of reinitializing the global SDK.
Cache cleanup failures publish a denied NSE configuration before the original error is propagated, and shared Keychain write failures are surfaced to the caller.

## Consequences

When consent is enabled, Dart and native reporting remain available; when it is disabled, both stop.
Re-enabling reporting requires another SDK initialization, and errors that occur while Sentry is stopped cannot be recovered.

### Trade-offs

- Web provides earlier observability: when enabled by `env.file`, Sentry can capture supported automatic and explicit events before account consent is resolved. Events sent before a later denial cannot be recalled.
- Mobile does not report before a valid ecosystem config initializes Sentry, so earlier events are lost. If the ecosystem default allows reporting, it may apply until server-stored user consent is loaded.
