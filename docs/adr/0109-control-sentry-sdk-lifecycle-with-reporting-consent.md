# 0109 - Control Sentry SDK Lifecycle with Reporting Consent

Date: 2026-09-16

## Status

Accepted

Web startup and the initial consent default were amended by
[ADR-0110](0110-web-sentry-ecosystem-fallback-and-denied-default.md).

## Context

The Sentry reporting preference can change while the application is running.
Dart capture gates and `beforeSend` callbacks do not cover all autonomous native telemetry, such as crashes, Android ANRs, iOS hangs, and sessions.
Permanently disabling native integrations would prevent that telemetry, but would also remove native observability after the user opts in.

## Decision

Effective reporting consent controls the complete Sentry SDK lifecycle.

- In-memory reporting consent starts denied. Technical configuration alone never permits reporting.
- When reporting is denied, the application does not initialize Sentry or closes the running SDK with `Sentry.close()`.
- When reporting is allowed and a valid, enabled technical configuration is available, the application initializes Sentry with its platform integrations enabled.
- Runtime capture checks and Dart `beforeSend` callbacks remain as defence in depth during asynchronous lifecycle transitions.
- Lifecycle transitions are serialized, and an SDK initialized after consent is revoked is closed before application capture paths can use it.
- Reinitialization never invokes the Flutter `appRunner` again.

### Platform flows

| Step | Web | Mobile |
| --- | --- | --- |
| Startup | Load `env.file` and start with the SDK stopped. A valid, enabled env config mounts `SentryWidget` through the web `appRunner` while consent is resolved; missing, disabled, or incomplete env config uses `runTmail()` to mount `TMailApp` directly. End-to-end tests call `runTmail()` directly. | Start the app with Sentry stopped. |
| Technical configuration | If any of `SENTRY_ENABLED`, `SENTRY_DSN`, or `SENTRY_ENVIRONMENT` is nonblank, use env as the source. It must have `SENTRY_ENABLED=true` and nonblank DSN and environment; a disabled or incomplete env config does not fall back. Only when all three values are absent or blank, use the validated ecosystem config. | Use the ecosystem config; it must have `enabled: true` and nonblank DSN and environment. |
| Reporting | Initialize Sentry only when the selected config is valid and enabled and effective consent allows reporting. Suspend or close the SDK when consent is denied or ecosystem resolution becomes loading or unavailable. | Initialize Sentry only when the ecosystem config is valid and enabled and effective consent allows reporting. Suspend or close the SDK when consent is denied or ecosystem resolution becomes loading or unavailable. |

On both platforms, effective consent is `server sentryUserOptIn ?? ecosystem userOptInByDefault ?? false`. A non-null server value always takes precedence, and technical availability (`enabled`, DSN, and environment) does not override this result. The ecosystem can supply the reporting default even when env supplies web's technical config. Reporting stays suspended while ecosystem ownership is being resolved. An account change clears the previous account's consent before the new account can report.

Session Replay remains disabled because Sentry Flutter 9.8.0 cannot both stop recording and safely discard an existing Replay buffer when consent is revoked.
Background FCM handlers read persisted consent before each event and treat missing, invalid, or unreadable values as denied.
Timed-out background setup is invalidated and cannot later enable Sentry, while notification processing continues without telemetry.
The iOS notification service extension applies the same fail-closed rule from Keychain.
It also blocks reporting when the shared DSN or environment no longer matches the active NSE SDK instance, instead of reinitializing the global SDK.
Cache cleanup failures publish a denied NSE configuration before the original error is propagated, and shared Keychain write failures are surfaced to the caller.

## Consequences

With valid technical configuration and affirmative consent, supported Dart and platform telemetry can be reported. When consent is denied, the SDK stays stopped or closes.
Resuming reporting after a stop requires another SDK initialization, and errors that occur while Sentry is stopped cannot be recovered.

### Trade-offs

- Events that occur before the SDK starts cannot be recovered. This includes web startup events even when `env.file` contains a valid Sentry configuration.
- If the ecosystem default allows reporting, it can apply until the server-stored user consent is loaded. A later server value takes precedence and may stop the running SDK on either platform.
- Web retains `SentryWidget` for a valid env configuration, including while the SDK waits for consent. Ecosystem fallback starts without it, so widget interaction breadcrumbs, tracing, and screenshot support are unavailable in that path; exception reporting still works.
