# 108. Workplace call transport and oversize attachment recovery

Date: 2026-09-16

## Status

Accepted

## Context

- An attachment that exceeds the server size cap goes to Drive instead of a dead-end dialog.
- That upload needs the same auth the Drive picker already uses.
- Bridge `fetchJSON` when the container app exposes it, otherwise an exchanged bearer token.
- Today that flow is private to the picker's composer extension, and hardcoded to `POST /intents`.
- This decision covers the preparation only; the upload call itself lands after.

## Decision

### Scope

- Prepared here: a reusable Workplace transport, a recovery seam on the oversize path,
  a source-agnostic file body reader.
- Not here: the upload request, the magic folder, the link in the body.
- Nothing a user can see changes.

### One transport for every Workplace call

- The access mode stays a sealed pair: bridge (the container holds the session) or bearer token.
- A runner resolves the mode once per action, then hands it to that action.
- Every request the action sends rides that one mode, so an action costs at most one exchange.
- The bridge exists on web only, so every action on mobile resolves to the bearer token.
- A request executor sends whatever the caller describes.
- The Drive token is exchanged per action, kept in memory, never persisted or refreshed.
- The runner owns the exchange and its one OIDC refresh retry on a 400/401 subject-token
  error; that stays the only retry.
- The main app keeps supplying the OIDC token getter and refresh trigger to the composer
  extension, which passes both to the runner.

```
run(platformUrl, action):
  if bridge supported and available:
    try:   return action(BridgeAccessMode)
    catch: log, fall through
  token = exchange(oidcToken)        # per action, not stored
  return action(BearerTokenAccessMode(token))

send(platformUrl, accessMode, method, pathSegments, query, body, headers):
  bridge -> fetchJSON(method, path, body, headers)
  bearer -> dio(method, url, Authorization: Bearer, headers, body)
```

- The bridge body widens from a JSON map to any payload, so binary can ride the same path.

### Recovery before the failure dialog

- A rejected upload may be handed to a recovery first; the dialog is the fallback.
- A recovery that takes over owns every user-visible outcome, failure toasts included.
- It never falls back to the dialog.
- The validation request carries the picked files, so a recovery knows what to act on.

```
on ValidationRejected(failure):
  if recovery?.recover(failure, request) == true:
    return false                     # recovery owns the UX from here
  feedback.showFailure(failure)      # today's dialog
  return false
```

- A recovery is registered as one optional builder argument on the upload validation service,
  built per rejection from the composer's context; no builder argument means today's dialog.
- No recovery is registered yet, so the dialog is still what every rejection shows.
- Drive availability for the oversize path is the same gate as the Drive picker button:
  workplace FQDN, ecosystem flag, user preference.
- Unavailable means today's dialog.

### Module boundary

- `workplace` owns the transport; the main app owns the composer wiring and the recovery.
- Unchanged from ADR-0095 and ADR-0105.

## Consequences

- Adding a Workplace call is a request description, not another auth flow.
- Adding an alternative to a blocking upload dialog is one class plus one builder argument.
- Exchanging a token per action costs one extra round trip whenever the bridge is absent,
  which on mobile is every action.

## Open questions

- How the uploaded file's shareable link is obtained.
- Whether the container-side `fetchJSON` accepts a binary body; it ships JSON-only today.
- The magic-folder `POST /files` contract is not merged yet.

## Sources

- [tmail-flutter#4827](https://github.com/linagora/tmail-flutter/issues/4827): attach too big file
- [ADR-0095: External drive file picker integration](0095-external-drive-file-picker-integration.md)
- [ADR-0105: Attach drive file via JMAP-mediated upload](0105-attach-drive-file-via-jmap-mediated-upload.md)
- [ADR-0107: Workplace OIDC refresh via shared interceptor](0107-workplace-oidc-refresh-via-shared-interceptor.md)
- [cozy-stack#4921](https://github.com/linagora/cozy-stack/pull/4921): `magic_folder` on `POST /files`
