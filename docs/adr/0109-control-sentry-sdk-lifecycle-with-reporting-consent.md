# 0109 - Control Sentry SDK Lifecycle with Reporting Consent

Date: 2026-09-16

## Status

Accepted

Web startup behavior is amended by [ADR-0110](0110-web-sentry-ecosystem-fallback-and-denied-default.md).

## Context

Reporting consent can change at runtime, while native crashes, hangs, ANRs, and sessions bypass Dart capture gates. Permanently disabling native integrations would block telemetry after opt-in.

## Decision

Sentry starts only with valid technical configuration and effective consent, and closes with `Sentry.close()` when denied or suspended. Mobile starts denied, while web starts allowed only with `SENTRY_ENABLED=true` and nonblank `SENTRY_DSN` and `SENTRY_ENVIRONMENT` in `env.file`.
Lifecycle transitions are serialized, initialization that finishes after revocation closes, and reinitialization never reruns the Flutter `appRunner`. Runtime capture gates and `beforeSend` callbacks remain active during transitions.

### Platform flows

#### Web

Any nonblank `SENTRY_ENABLED`, `SENTRY_DSN`, or `SENTRY_ENVIRONMENT` selects `env.file`, while ecosystem fallback requires all three values to be absent or blank.

```mermaid
flowchart TD
  W0["Load env.file"] --> W1{"Any Sentry env value nonblank"}
  W1 -- Yes --> W2{"SENTRY_ENABLED=true and DSN and environment nonblank"}
  W2 -- Yes --> W3["Start SDK, mount SentryWidget, reporting allowed"]
  W2 -- No --> W4["Use env, no fallback, SDK off, runTmail()"]
  W1 -- No --> W5["runTmail(), wait for ecosystem"]
  W5 --> W6{"Ecosystem enabled with DSN, environment, and consent"}
  W6 -- Yes --> W7["Start SDK after app startup"]
  W6 -- No --> W8["Keep SDK off"]
```

Disabled or incomplete env configuration installs no Sentry runtime configuration, so the reporting preference stays hidden. End-to-end tests also call `runTmail()` directly.

#### Mobile

```mermaid
flowchart TD
  M0["Start app with SDK off"] --> M1["Load ecosystem config"]
  M1 --> M2{"Valid config and current effective consent"}
  M2 -- Yes --> M3["Start SDK"]
  M2 -- No --> M4["Keep SDK off"]
```

After ecosystem loading, effective consent is `server sentryUserOptIn ?? ecosystem userOptInByDefault ?? false` on both platforms. A later server value overrides the ecosystem default. Ecosystem loading or unavailability suspends reporting, and an account change clears previous consent before the next account can report.

#### Reporting toggle in user settings

The toggle appears with server settings and a usable Sentry runtime configuration. It saves `true` when turned on and `false` when turned off, then applies the returned value only after server acknowledgment.

```mermaid
flowchart TD
  U0["User toggles error reporting"] --> U1["Save new sentryUserOptIn in server settings"]
  U1 --> U2{"Server update succeeds"}
  U2 -- No --> U3["Keep current consent and SDK state"]
  U2 -- Yes --> U4{"Platform"}
  U4 -- Web --> U5["SentryManager applies consent"]
  U4 -- Mobile --> U6["SentryEcosystem applies and persists consent"]
  U5 --> U7{"Config present, consent allowed, suspension cleared"}
  U6 --> U7
  U7 -- Yes --> U8["Start or keep SDK running"]
  U7 -- No --> U9["Close or keep SDK stopped"]
```

Web keeps the widget path chosen at startup. Mobile caches consent for background FCM, and iOS also updates the notification extension through Keychain.

Session Replay remains disabled because Sentry Flutter 9.8.0 cannot discard its buffer after revocation. Background FCM and the iOS extension treat missing, invalid, or unreadable persisted consent as denied, and timed-out setup cannot enable Sentry later. The extension also blocks reporting when its shared DSN or environment differs from the active SDK. If cache cleanup fails, the app attempts to publish a denied extension configuration and rethrows the cleanup error when publication succeeds. Keychain write failures reach the caller.

## Consequences

Valid configuration and consent permit Dart and platform telemetry, while denied consent stops the SDK. Resuming requires reinitialization, and events while stopped cannot be recovered.

### Trade-offs

- Valid web env configuration can report startup events, while ecosystem fallback waits for configuration and consent.
- An ecosystem default can apply before server consent loads, and a later server value may stop the SDK.
- Web ecosystem fallback lacks `SentryWidget` interaction breadcrumbs and tracing, while automatic screenshots are disabled in both web paths.
