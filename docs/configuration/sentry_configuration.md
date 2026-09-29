## Configuration for Sentry

### Context

- **Twake Mail** uses **Sentry** for error and performance reporting when configuration and consent allow it.

### How to config

1. Set web values in [`env.file`](https://github.com/linagora/tmail-flutter/blob/master/env.file).

   ```bash
   SENTRY_ENABLED=true
   SENTRY_DSN=<your_sentry_dsn>
   SENTRY_ENVIRONMENT=<environment_name>
   ```

   Web starts Sentry at startup only with `SENTRY_ENABLED=true` and nonblank DSN and environment, then sets `isReportingAllowed=true` in memory.

2. Choose web fallback or disable Sentry.

   Any nonblank value among the three variables selects `env.file`. `SENTRY_ENABLED=false`, `SENTRY_ENABLED=`, or a missing `SENTRY_ENABLED` prevents env startup. A selected but disabled or incomplete env config hides the reporting preference and never falls back. Set `SENTRY_ENABLED=false` to disable web Sentry regardless of the other values. Web falls back to the ecosystem only when all three values are absent or blank.

3. Configure the ecosystem and consent.

   Web fallback and Sentry on mobile require ecosystem `enabled` set to `true`, nonblank DSN and environment, and effective consent. After ecosystem loading, consent is `server sentryUserOptIn ?? ecosystem userOptInByDefault ?? false`. If the Sentry section is missing, web env reporting defaults to `false`, while web fallback and mobile keep the SDK off.

4. Verify.

   With valid configuration and consent, trigger a sample error and verify that it appears in Sentry.
