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
