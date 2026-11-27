# Decisions

Decisions taken on tmail-flutter, oldest first. Append only: a decision that changes gets a new entry that replaces the old one and cites it. Entry format: the `twake-decisions` skill of [linagora/twake-guidelines](https://github.com/linagora/twake-guidelines/blob/main/skills/twake-decisions/SKILL.md).

Categories: UX, UI, Product, Architecture, Infra, Tech.

## 2026-11-24, [Infra] A fork pull request runs no code before a linagora member vouches for its head commit

- Decision: replaces the fork check of the PR image delivery, which let any fork run its tests and was approved by a comment tied to no commit: the Jenkinsfile starts with an `Authorize fork` stage: a pull request from a fork runs nothing of its own (build, tests, scripts, post actions) unless the fork owner is a linagora member, or a member approved its head commit, submitted a review "Build this please" on it, or commented "Build this please <sha>" with its full id. No credential is bound at pipeline level; `github` and `dockerHub` are bound only around the steps that use them (`withGithubCredential`, `withDockerHubLogin` with a throwaway Docker config). The block holding these helpers is the same in the Jenkinsfiles of twake-contacts-frontend, twake-calendar-frontend, twake-calendar-side-service, webadmin-proxy, tmail-flutter, esn-sabre, tmail-backend and twake-mail-admin, and is changed in all of them.
- Decided by: Benoit Tellier, after the twake-qa security review of twake-calendar-side-service (SEV-1, 2026-11-23); the pipeline of twake-contacts-frontend is the model.
- Why: the agents are persistent and shared, so code of a pull request that runs before the check can read a credential bound later in the same build, or leave a process behind for a later one. A review is tied to a commit by GitHub, unlike a comment, so a commit pushed after the approval is not built until a member reviews it again.
- Scope: `Jenkinsfile` and `JenkinsfileMobile`. The backend teardown in `post` runs only for an authorized build.

## 2026-11-25, [Architecture] On web basic auth, a sign out in one tab invalidates the login copy of every other tab through a marker in localStorage

- Decision: the basic-auth login of a tab lives in its sessionStorage next to a tag holding the sign-out marker (`basicAuthSignOutMarker` in localStorage) it was saved under. A user sign out replaces the marker. A tab whose tag no longer matches the marker rejects its requests, removes its own login copy and tag, and goes to the login page. Only the marker is read for this check, and the tab never clears shared data (Hive, marker, composer snapshots).
- Decided by: Dat H. Pham, in linagora/tmail-flutter#5163.
- Why: sessionStorage is per tab, so no other tab learns of a sign out, and the password stayed usable in the tabs left open. Another tab may already be signed in again, so a leaving tab must not touch shared data.
- Scope: web basic auth only; OIDC and mobile are unchanged. `authentication_info_cache_manager.dart`, `sign_out_marker_storage.dart`, `basic_auth_tab_guard.dart` and the request interceptors.

## 2026-11-25, [UX] A tab signed out from another tab keeps its open drafts

- Decision: before a tab with a revoked login goes to the login page, it saves a reload snapshot of every open composer. It leaves without the browser leave prompt.
- Decided by: Dat H. Pham, in linagora/tmail-flutter#5163.
- Why: the user loses nothing typed, and the dashboard prompt cannot trap a tab that has already dropped its login.
- Scope: `basic_auth_tab_guard.dart`, `composer_manager.dart`.

## 2026-11-25, [UX] On web basic auth, a same-origin app route opened in a new tab inherits the login

- Decision: same-origin app routes open in a new tab without `noopener`, so the tab inherits a copy of the sessionStorage login and does not ask for it again. Other links and print tabs open with `noopener`. A tab with an opener removes the composer and identity drafts it copied, then detaches the opener.
- Decided by: Dat H. Pham, in linagora/tmail-flutter#5163.
- Why: the new tab keeps working without a second sign in, and a draft stays owned by the one tab that created it.
- Scope: `app_route_tab_environment.dart`, `html_utils.dart`, `child_tab_session_cleaner.dart`, `mailbox_action_handler_mixin.dart`, `email_action_controller.dart`.

## 2026-11-21, [Architecture] Read requests are sent again once after a transport error

- Decision: the session request, `Settings/get` and `Mailbox/get` are sent again once, 500 ms later, when they fail with a socket or connection error; writes (`Email/set`, `EmailSubmission/set`, any `*/set`) are never sent again.
- Decided by: Crash-- (CTO), [fix plan of #5172](https://github.com/linagora/tmail-flutter/issues/5172#issuecomment-7058350249); the 500 ms delay: proposed by the agent ([Crash--/tmail-flutter#1](https://github.com/Crash--/tmail-flutter/pull/1)), confirmed by Crash-- (CTO) on 2026-11-21; `Settings/get` included: Dat H. Pham, in linagora/tmail-flutter#5173
- Why: on iOS the first requests after a long time in background can hit a dead socket and show the generic retry banner, while a new connection works at once. A failed `Settings/get` in the same burst would also drop the Sentry reports kept since launch.
- Scope: mobile and web, session, server settings and folder list loading.

## 2026-11-21, [Architecture] The ecosystem request is retried after a transport error

- Decision: on mobile, when `.well-known/linagora-ecosystem` fails with a socket or connection error, it is requested again after 1 s, 4 s and 15 s; any other failure, and any failure on web, is final for the session.
- Decided by: Crash-- (CTO), [fix plan of #5172](https://github.com/linagora/tmail-flutter/issues/5172#issuecomment-7058350249); the delays and leaving web out: proposed by the agent ([Crash--/tmail-flutter#1](https://github.com/Crash--/tmail-flutter/pull/1)), confirmed by Crash-- (CTO) on 2026-11-21; the socket or connection error limit: Dat H. Pham, in linagora/tmail-flutter#5173
- Why: the ecosystem carries the Sentry configuration; one failed request at launch kept Sentry paused and hid the "Error reporting" toggle for the whole session. On web a missing or CORS-blocked document fails the same way as a dropped connection, so retrying would only delay every ecosystem consumer. A launch without network or a timeout is final too: it would keep every ecosystem consumer loading for the whole retry time.
- Scope: mobile, every ecosystem consumer (Sentry, app grid, premium CTA, Drive attachments, Scribe).

## 2026-11-21, [Product] A folder list that fails to load is reported to Sentry

- Decision: when the folders cannot be loaded, the failure is logged as an error (a Sentry event when reporting is on), except when the device has no network.
- Decided by: Crash-- (CTO), [fix plan of #5172](https://github.com/linagora/tmail-flutter/issues/5172#issuecomment-7058350249); the no-network exception: proposed by the agent ([Crash--/tmail-flutter#1](https://github.com/Crash--/tmail-flutter/pull/1)), confirmed by Crash-- (CTO) on 2026-11-21
- Why: the exception behind the generic retry banner shows up in Sentry.
- Scope: mobile and web, every screen that loads the folder list.

## 2026-11-21, [Product] Errors raised before Sentry is configured wait in memory

- Decision: the Sentry SDK still starts from a known configuration only (the ecosystem's, or the env one on web), and may run on the instance default before the user's choice is read. No error or message is sent until both the configuration and the user's choice are known (no server settings capability, or no settings stored on the server, means no choice); until then they are kept in memory and sent once reporting is allowed. They are dropped without being sent when reporting is not allowed, when the ecosystem's Sentry configuration is invalid, when the user's choice cannot be read (later errors then follow the instance default), when the session ends, and in any case five minutes after the first one. At most 20 are kept. An explicit refusal drops them at once. Errors the Sentry SDK captures by itself (uncaught errors) are not kept: they follow the instance default. This holds on web configured through env too: errors raised before sign-in wait for the user's choice, read after sign-in, so a failed sign-in is not reported.
- Decided by: Crash-- (CTO), [fix plan of #5172](https://github.com/linagora/tmail-flutter/issues/5172#issuecomment-7058350249); the limits (20 errors, 5 minutes) and the web env case: proposed by the agent ([#5173](https://github.com/linagora/tmail-flutter/pull/5173)), confirmed by Crash-- (CTO) on 2026-11-21; the SDK-captured errors: Dat H. Pham, in linagora/tmail-flutter#5173
- Why: some customers have Sentry disabled, so nothing may leave the device before the decision, but the errors of the launch are the ones that explain what the user sees first.
- Scope: mobile and web, every error and message reported to Sentry.

## 2026-11-27, [Architecture] A folder list that failed to load is loaded again when the internet is back

- Decision: after a folder list load fails, the folders are loaded again each time the connection state turns connected, until a load succeeds.
- Decided by: Dat H. Pham, in linagora/tmail-flutter#5173.
- Why: a launch during an outage left the list on the spinner after the connection returned, until the user tapped Retry.
- Scope: mobile (internet checker: the internet is reachable) and web (connectivity: any connection but none), the mailbox list.
