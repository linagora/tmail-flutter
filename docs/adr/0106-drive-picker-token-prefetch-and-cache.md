# 106. Drive Picker Token Prefetch and Cache

Date: 2026-08-31

## Status

Proposed

## Reference

- Builds on [ADR-0095](0095-external-drive-file-picker-integration.md) and [ADR-0105](0105-attach-drive-file-via-jmap-mediated-upload.md), both unchanged.

## Context

- Every Drive tap pays two sequential round-trips before the picker renders: `POST /auth/token_exchange` (OIDC `id_token` → Drive access token), then `POST /intents`.
- The exchanged token is discarded after each tap; the skeleton stays on screen for both calls.
- TF-4713.

## Decision

- **Prefetch trigger is session load.** Fire as soon as the Drive platform URI is available, not at composer open, not at login as a separate hook.
- **One in-memory store.** `WorkplaceTokenStore` (`obtain` / `recoverAfterUnauthorized` / `prime` / `clear`) lives on the keepAlive `WorkplaceComposerAttachmentExtension`. Composers never own tokens.
- **No TTL.** cozy-stack does not return `expires_in`. Cache the session until Drive rejects it.
- **Refresh is reactive only.** It runs after a failed `POST /intents`, never on a timer, never during prefetch.
- **Coordination is cache-or-join.** Return the cached session, or await the single in-flight `Future`. No generation counters, no `force` flags, no `_isRefreshing` booleans.
- **401 handling (`recoverAfterUnauthorized`):** refresh via `POST /auth/access_token` (`grant_type=refresh_token`) when refresh token + client id/secret are all present; otherwise fall back to a full re-exchange. Either path retries that composer's `/intents` exactly once. A second 401 is not recovered — it surfaces as the existing modal failure.
- **Token sharing, not intent sharing.** The store shares one access token across composers; each composer still gets its own `/intents` call and its own modal.
- **Invalidation is URI-null, not composer-close.** `clear()` fires on logout, account switch, Drive preference off, or capability off. Composer close, all-composers-close, and OIDC `id_token` refresh are no-ops for the store.
- **Double-tap stays a UI concern.** The existing `DrivePickerStateMixin._modalOpen` guard owns same-button double-click; the store is not involved.
- **Out of scope:** Dio interceptor, disk persistence, intent prefetch, TTL/`expiresAt`/JWT `exp`, priming from `ComposerController.onInit`, a dedicated refresh interactor/state (the store calls the repository directly).

## Consequences

- First Drive tap after session load is faster: it only pays for `POST /intents` when the store is warm.
- New failure mode: a cached token can go stale between prefetch and tap; mitigated by the 401 recovery path, with no third attempt.
- `workplace` gains one new store abstraction (`WorkplaceTokenStore` / `InMemoryWorkplaceTokenStore`); `lib/` stays token-agnostic and only reads the registry.
- Worst case matches today's behavior: if prefetch failed or never ran, the tap pays for the exchange itself.

## Sources

- [ADR-0095: External drive file picker integration](0095-external-drive-file-picker-integration.md)
- [ADR-0105: Attach Drive File via JMAP-mediated Upload](0105-attach-drive-file-via-jmap-mediated-upload.md)
