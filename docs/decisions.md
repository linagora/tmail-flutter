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

## 2026-11-27, [Architecture] Settings › Delegation › With me re-reads the session when its list of owners differs from the session

- Decision: when the With me list loads and names a different set of owners than the shown session's delegated accounts, the session is re-read once and handed to the dashboard, so the account switcher offers the same mailboxes as the list. A load that fails, or that a newer load replaced, triggers no re-read. Re-reading on resume and on `accountNotFound` stays with linagora/tmail-flutter#5162.
- Decided by: Dat Vu, in linagora/tmail-flutter#5188.
- Why: the session is read only at sign in, so a grant or a revoke made while the app runs reached the With me list but not the switcher, which then offered a mailbox the server refuses or hid one just granted.
- Scope: `delegated_to_me_notifier.dart`, `delegated_to_me_section.dart`.
