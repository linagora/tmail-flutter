# 108. Workplace call transport

Date: 2026-09-16

## Status

Accepted

## Context

- A Workplace call needs the same auth the Drive picker already uses.
- Bridge `fetchJSON` when the container app exposes it, otherwise an exchanged bearer token.
- Today that flow is private to the picker's composer extension, and hardcoded to `POST /intents`.
- A second caller is coming, so the flow lives outside the extension.

## Decision

### Scope

- Prepared here: a reusable Workplace transport.
- Not here: any new call sent over it.
- Nothing a user can see changes.

### One transport for every Workplace call

- The access mode stays a sealed pair: bridge (the container holds the session) or bearer token.
- A runner resolves the mode once per action, then hands it to that action.
- An action declares whether the bridge can serve it; a declared-unsupported action goes
  straight over the bearer token, no bridge round trip.
- A bridge failure inside an action the bridge does support still falls back to the bearer token.
- Every request the action sends rides that one mode, so an action costs at most one exchange.
- The bridge exists on web only, so every action on mobile resolves to the bearer token.
- A request executor sends whatever the caller describes.
- The Drive token is exchanged per action, kept in memory, never persisted or refreshed.
- The runner owns the exchange and its one OIDC refresh retry on a 400/401 subject-token
  error; that stays the only retry.
- The main app keeps supplying the OIDC token getter and refresh trigger to the composer
  extension, which passes both to the runner.

```
action:
  supportsBridge: bool               # declared per action, not discovered by failing
  call(accessMode)

run(platformUrl, action):
  if action.supportsBridge and bridge supported and available:
    try:   return action(BridgeAccessMode)
    catch: log, fall through
  token = exchange(oidcToken)        # per action, not stored
  return action(BearerTokenAccessMode(token))

send(platformUrl, accessMode, method, pathSegments, query, body, headers):
  bridge -> fetchJSON(method, path, body, headers)
  bearer -> dio(method, url, Authorization: Bearer, headers, body)
```

- The bridge body widens from a JSON map to any payload, so binary can ride the same path.

### Module boundary

- `workplace` owns the transport; the main app owns the composer wiring.
- Unchanged from ADR-0095 and ADR-0105.

## Consequences

- Adding a Workplace call is a request description, not another auth flow.
- Exchanging a token per action costs one extra round trip whenever the bridge is absent,
  which on mobile is every action.

## Open questions

- Whether the container-side `fetchJSON` accepts a binary body; it ships JSON-only today.
  The answer sets `supportsBridge` on the upload action; the transport is the same either way.

## Sources

- [tmail-flutter#4827](https://github.com/linagora/tmail-flutter/issues/4827): attach too big file
- [ADR-0095: External drive file picker integration](0095-external-drive-file-picker-integration.md)
- [ADR-0105: Attach drive file via JMAP-mediated upload](0105-attach-drive-file-via-jmap-mediated-upload.md)
- [ADR-0107: Workplace OIDC refresh via shared interceptor](0107-workplace-oidc-refresh-via-shared-interceptor.md)
- [ADR-0109: Oversize attachment recovery seam](0109-oversize-attachment-recovery-seam.md)
