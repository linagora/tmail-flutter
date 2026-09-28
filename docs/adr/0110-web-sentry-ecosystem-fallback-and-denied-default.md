# 0110 - Web Sentry Ecosystem Fallback and Denied Reporting Default

Date: 2026-09-28

## Status

Accepted

## Context

Web deployments previously used only `env.file` for Sentry's technical configuration.
An instance without Sentry env values could not initialize Sentry even when its ecosystem provided a valid configuration.
Reporting consent in memory also started as allowed before either consent source was resolved.

## Decision

- On web, any non-empty `SENTRY_ENABLED`, `SENTRY_DSN`, or `SENTRY_ENVIRONMENT` value makes env the technical configuration source.
  An explicit `SENTRY_ENABLED=false` or incomplete env configuration therefore does not fall back to the ecosystem.
- When all three env values are absent or blank, web uses the existing ecosystem Sentry setup and validation path.
  The SDK starts only with a valid, enabled ecosystem configuration and effective reporting consent.
- Runtime configuration and in-memory reporting policy both default to denied.
  Env configuration alone never grants reporting consent.
  Effective consent remains `server sentryUserOptIn ?? ecosystem userOptInByDefault ?? false`.
- Ecosystem resolution suspends reporting.
  A web ecosystem reload retains the current user's identity in memory for reapplication while clearing the active Sentry scope and breadcrumbs.
  An account change clears the previous account's identity and explicit consent before the next account can report.
- A valid, enabled web env config keeps the existing `SentryWidget` app runner, even while the SDK waits for consent.
  With no valid env config, web mounts `TMailApp` directly through `runTmail()`; end-to-end tests also call that function directly.
  Ecosystem fallback can start the SDK later without `SentryWidget`, so automatic user interaction breadcrumbs and user interaction tracing are unavailable in that path.
  Automatic screenshots are disabled in both paths by the current configuration.
  Exception reporting remains available after the SDK starts with consent.

## Consequences

Web Sentry may initialize after the app starts, once ecosystem configuration and consent become available.
Events before that point are not reported.
Mobile keeps using its existing ecosystem configuration path.
A deployment that wants ecosystem fallback must remove or blank all three Sentry env values.
