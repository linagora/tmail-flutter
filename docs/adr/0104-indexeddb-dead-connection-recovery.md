# 104. IndexedDB Dead-Connection Recovery in HiveCacheClient

Date: 2026-07-21

## Status

Proposed

## Context

Issue #4717: on web, `InvalidStateError` from `storage_backend_js.dart getStore` — users stuck on a spinner while JMAP returned 200.

Cause: a 401 makes every pending controller start its own logout; one close lands on another's in-flight write.

Two Hive facts:

- **A close unregisters the box first.** Deliberate close → unregistered; a connection dying alone → still registered; the web backend never tells Hive.
- **Error text is all we get.** A DOMException stringifies as `"<name>: <message>"` — name fixed by WebIDL, message browser-specific prose.

## Decision

**`TwakeAppManager.runClearDataOnce` serialises logout** — this is what fixes #4717.

**`HiveCacheClient` retries once** for a connection killed from outside while the box stays registered — otherwise every later operation breaks until reload. Closing it unregisters the box, so the retry reopens live.

All must hold:

| Guard | Rule |
|---|---|
| Platform | `isWeb` first — elsewhere text matching yields false positives |
| Error | DOMException name, known messages as fallback |
| No close since | `closeGeneration` captured before the operation. Changed = logout ran underneath, so a retry would write pre-logout data into the cache it cleared. The registry cannot see this: logout navigates instead of reloading, so the login screen reopens the box, which reads "open" again |
| Box registered | Secondary: catches a direct `closeBox()`, which bumps no count |
| Not closed | Never retry Hive's own `Box has already been closed.` |

**One recovery per box, keyed on `tableName`** — bindings share one connection, so otherwise one caller closes what another just reopened. Not the `isolated` flag: on web `IsolatedHive` delegates to `Hive`, one registry.

**Never close a box already replaced.** `_recoveries` keeps each box's latest recovery as a token: same as captured → discard; different → join it.

**Retry safety:** key-addressed operations only — never `box.add()` or read-modify-write.

## Consequences

- Mobile and desktop untouched — the platform gate rethrows first.
- **Residual leak, outside this ADR:** teardown clears the boxes *then* closes Hive; a write landing in that window succeeds, so no guard applies.
- **Upgrade tripwire — the reason for this ADR.** On each `hive_ce` upgrade, re-check that DOMExceptions arrive unwrapped (wrapped = recovery stops *silently*) and that web shares one registry.
- VM tests cover logic, not platform: not error strings, IndexedDB semantics, or the registry.
