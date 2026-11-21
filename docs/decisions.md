# Decisions

Decisions taken on tmail-flutter, oldest first. Append only: a decision that changes gets a new entry that replaces the old one and cites it. Entry format: the `twake-decisions` skill of [linagora/twake-guidelines](https://github.com/linagora/twake-guidelines/blob/main/skills/twake-decisions/SKILL.md).

Categories: UX, UI, Product, Architecture, Infra, Tech.

## 2026-11-21, [Architecture] Read requests are sent again once after a transport error

- Decision: the session request and `Mailbox/get` are sent again once, 500 ms later, when they fail with a socket or connection error; writes (`Email/set`, `EmailSubmission/set`, any `*/set`) are never sent again.
- Decided by: Crash-- (CTO), [fix plan of #5172](https://github.com/linagora/tmail-flutter/issues/5172#issuecomment-7058350249); the 500 ms delay: proposed by the agent ([Crash--/tmail-flutter#1](https://github.com/Crash--/tmail-flutter/pull/1)), confirmed by Crash-- (CTO) on 2026-11-21
- Why: on iOS the first requests after a long time in background can hit a dead socket and show the generic retry banner, while a new connection works at once.
- Scope: mobile and web, session and folder list loading.

## 2026-11-21, [Architecture] The ecosystem request is retried after a transport error

- Decision: on mobile, when `.well-known/linagora-ecosystem` fails with a network or transport error, it is requested again after 1 s, 4 s and 15 s; any other failure, and any failure on web, is final for the session.
- Decided by: Crash-- (CTO), [fix plan of #5172](https://github.com/linagora/tmail-flutter/issues/5172#issuecomment-7058350249); the delays and leaving web out: proposed by the agent ([Crash--/tmail-flutter#1](https://github.com/Crash--/tmail-flutter/pull/1)), confirmed by Crash-- (CTO) on 2026-11-21
- Why: the ecosystem carries the Sentry configuration; one failed request at launch kept Sentry paused and hid the "Error reporting" toggle for the whole session. On web a missing or CORS-blocked document fails the same way as a dropped connection, so retrying would only delay every ecosystem consumer.
- Scope: mobile, every ecosystem consumer (Sentry, app grid, premium CTA, Drive attachments, Scribe).

## 2026-11-21, [Product] A folder list that fails to load is reported to Sentry

- Decision: when the folders cannot be loaded, the failure is logged as an error (a Sentry event when reporting is on), except when the device has no network.
- Decided by: Crash-- (CTO), [fix plan of #5172](https://github.com/linagora/tmail-flutter/issues/5172#issuecomment-7058350249); the no-network exception: proposed by the agent ([Crash--/tmail-flutter#1](https://github.com/Crash--/tmail-flutter/pull/1)), confirmed by Crash-- (CTO) on 2026-11-21
- Why: the exception behind the generic retry banner shows up in Sentry.
- Scope: mobile and web, every screen that loads the folder list.

## 2026-11-21, [Product] Errors raised before Sentry is configured wait in memory

- Decision: the Sentry SDK still starts from a known configuration only (the ecosystem's, or the env one on web), and may run on the instance default before the user's choice is read. No error or message is sent until both the configuration and the user's choice are known (no server settings capability means no choice); until then they are kept in memory and sent once reporting is allowed. They are dropped without being sent when reporting is not allowed, when the ecosystem's Sentry configuration is invalid, when the user's choice cannot be read (later errors then follow the instance default), when the session ends, and in any case five minutes after the first one. At most 20 are kept. An explicit refusal drops them at once. This holds on web configured through env too: errors raised before sign-in wait for the user's choice, read after sign-in, so a failed sign-in is no longer reported.
- Decided by: Crash-- (CTO), [fix plan of #5172](https://github.com/linagora/tmail-flutter/issues/5172#issuecomment-7058350249); the limits (20 errors, 5 minutes) and the web env case: proposed by the agent ([#5173](https://github.com/linagora/tmail-flutter/pull/5173)), confirmed by Crash-- (CTO) on 2026-11-21
- Why: some customers have Sentry disabled, so nothing may leave the device before the decision, but the errors of the launch are the ones that explain what the user sees first.
- Scope: mobile and web, every error and message reported to Sentry.
