# 112. Save web composer snapshots synchronously for page reload

Date: 2026-09-25

## Status

Accepted

## Context

Issue #4815: on web, reload can lose an open composer because `unload` removes the previous cache before an asynchronous save that the browser may terminate.
Only reload in the same tab needs recovery; tab close, crashes, and Android's separate recovery path (ADR-0086) are out of scope.

## Decision

- Web bindings register a handler that builds the snapshot and writes it synchronously to `sessionStorage` in `beforeunload`, using the synchronous storage option from ADR-0009; mobile registers nothing.
- The interactor stays synchronous, because the browser does not wait for a `Future` or `Stream` during unload.
- Missing editor content, an unresolved identity, or failed restoration keeps the previous snapshot.
- Uploaded inline images are stored as `cid:` references, sharing the synchronous matching step of the send path, so restore does not list them as attachments.
- Restoration keeps the snapshot to survive a second reload; a normal close removes it.
- Explicit logout closes composers, then removes the account's snapshots; session expiry keeps them for re-login.
- No autosave timers or dirty flags are added.

## Consequences

- Editing has no storage I/O; a large snapshot may briefly delay reload.
- Recovery is not guaranteed when storage is full or disabled, which is most likely with images not yet uploaded (still base64), or when a new composer reloads before its editor loads.
- A restored composer does not mark the original email answered or forwarded, and loses the unsubscribe reference; this predates the change and is tracked separately.
