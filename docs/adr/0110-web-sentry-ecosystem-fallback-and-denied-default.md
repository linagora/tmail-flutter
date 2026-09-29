# 0110 - Web Sentry Ecosystem Fallback and Reporting Defaults

Date: 2026-09-28

## Status

Accepted

## Context

Web selects a Sentry configuration source before ecosystem and server consent load.

## Decision

- Any nonblank `SENTRY_ENABLED`, `SENTRY_DSN`, or `SENTRY_ENVIRONMENT` selects `env.file`, and initialization requires `SENTRY_ENABLED=true` and nonblank DSN and environment. If env is selected but invalid or disabled, Sentry stays off without ecosystem fallback.
- When all three env values are absent or blank, web uses ecosystem configuration and starts the SDK later only with `enabled` set to `true`, nonblank DSN and environment, and effective consent.
- A valid env configuration starts with `isReportingAllowed=true` in memory, and after ecosystem loading consent is `server sentryUserOptIn ?? ecosystem userOptInByDefault ?? false`. A missing Sentry ecosystem section supplies `false` as the default.
- Ecosystem loading or unavailability suspends reporting, reload retains the current identity in memory but clears the active scope, and an account change clears identity and explicit consent.
- Valid env configuration mounts `SentryWidget`, while all other web paths mount `TMailApp` through `runTmail()`, and ecosystem fallback can start the SDK later without widget integrations.

## Consequences

Valid env configuration can report startup events, while ecosystem fallback cannot recover events before its SDK starts.
Invalid env configuration installs no runtime Sentry configuration, so the reporting preference stays hidden.
Ecosystem fallback lacks automatic interaction breadcrumbs and tracing, while automatic screenshots are disabled in both web paths.
Mobile continues to use ecosystem configuration.
