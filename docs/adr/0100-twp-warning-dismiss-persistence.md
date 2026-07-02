# 100. TWP Warning Dismiss Persistence

Date: 2026-07-01

## Status

Proposed

## Reference
Parent: [ADR-0098](0098-twp-warning-banners-and-header-cache-consolidation.md); builds on [ADR-0099](0099-twp-warning-banners-visible.md)

## Context

Phase 2 of #4484: dismissing a warning persists across app restarts; shows a red error toast when offline.

Closest existing analogue: the unsubscribe-mail flow (`KeyWordIdentifierExtension.unsubscribeMail` → `EmailIdExtension.generateMapUpdateObjectUnsubscribeMail()` → `EmailApi.unsubscribeMail()` → `SetEmailMethod.addUpdates`).

Key facts:
- `KeyWordIdentifierExtension` has only static, non-parameterized keyword entries today. `twpWarningDismissed(TwpWarning warning)` is the first parameterized `KeyWordIdentifier` factory in this codebase.
- `NetworkConnectionController` is already used by `thread_detail_controller.dart`; this is the first time `SingleEmailController` consumes it.
- No existing keyword supports removal/un-dismiss — every keyword patch is add-only (`true` at `keywords/<value>`).

## Decision

### Keyword
```dart
static KeyWordIdentifier twpWarningDismissed(TwpWarning warning) =>
    KeyWordIdentifier('twp-warning-dismissed-${warning.stableId}');
```
`TwpWarning.stableId` (new, `model/lib/email/twp_warning.dart`) is content-derived, never position-derived, so it is stable across reordering, insertion, or removal of *other* warnings on the same email:
```dart
String get stableId {
  final normalizedCode = code.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  final contentHash = fnv1a32('$level|$code|$fallbackText').toRadixString(16);
  return '$normalizedCode-$contentHash';
}
```
- `normalizedCode` slugifies `code` to `[a-z0-9-]` only, so a backend `code` containing `/`, whitespace, uppercase, or unicode can never produce an invalid JMAP keyword path or collide with keyword syntax — see "Keyword safety" below.
- `contentHash` is a deterministic hash (FNV-1a 32-bit, or equivalent fixed, stable-across-app-versions algorithm) of the same `(level, code, fallbackText)` triplet used as the deduplication identity in ADR-0099 — the dismiss key and the dedup key are the same logical identity, computed once.

### Flow
`TwpWarningBanner` reads `emailId` from `TwpWarningState.emailId` (ADR-0099 — fed into the notifier in the same `setWarnings` call as the warning list, so it's always in sync with what's on screen) rather than reaching into `SingleEmailController` or taking it as a constructor argument.
```
TwpWarningBanner (ConsumerWidget, dismiss tap)
  → emailId = ref.read(twpWarningNotifierProvider).emailId   // fed by setWarnings, ADR-0099
  → SingleEmailController.dismissTwpWarning(emailId, TwpWarning warning)
    → if NOT NetworkConnectionController.isNetworkConnectionAvailable():
         show red error toast — return (banner stays visible, no network call, nothing queued)
    → else:
         DismissTwpWarningInteractor.execute(session, accountId, emailId, warning)
           → EmailRepository.dismissTwpWarning(...)
             → EmailApi: SetEmailMethod(accountId)..addUpdates(
                 {emailId.id: KeyWordIdentifierExtension
                     .twpWarningDismissed(warning).generatePath(): true})
         on success:
           ref.read(twpWarningNotifierProvider.notifier).markDismissed(warning)
           → notifier adds keyword string to its local optimistic set
           → Riverpod state update → ConsumerWidget rebuilds → banner row disappears immediately
           (no email object touched)
         on failure:
           show red error toast (banner stays visible)
```
Live keywords are fed separately: whenever `currentEmail` changes (incl. WebSocket), the controller calls `notifier.setKeywords(currentEmail.keywords)`; effective dismissed set = live ∪ optimistic.

New pieces mirror existing shapes exactly:
- `DismissTwpWarningInteractor` — 4-line shape like `UnsubscribeEmailInteractor`, parameterized by the `TwpWarning` being dismissed.
- `EmailIdExtension.generateMapUpdateObjectDismissTwpWarning(TwpWarning warning)` — mirrors `generateMapUpdateObjectUnsubscribeMail()`.
- Reuses existing `PatchObject`/`SetEmailMethod` machinery — no new JMAP method type.

### Offline semantics
When offline, dismiss shows a red error toast and returns immediately. No local banner hide, no queued mutation, no optimistic update. The banner remains visible until the user is online and successfully dismisses.

### Keyword source and dismiss success → immediate UI update
Live dismissal keywords come from `currentEmail.keywords` (the WebSocket-updated `PresentationEmail`), fed to the notifier via Phase 1's `setKeywords`. The notifier additionally keeps a local optimistic set; its effective dismissed set is the union of the two, so `setKeywords` refreshing the live portion never drops an in-flight dismiss.

On a successful JMAP call, `TwpWarningNotifier.markDismissed(TwpWarning warning)` adds `KeyWordIdentifierExtension.twpWarningDismissed(warning).value` to the local optimistic set. The `TwpWarningBanner` `ConsumerWidget` watches this state and rebuilds immediately — the dismissed banner disappears without waiting for a WebSocket update or email re-fetch. No email object (`DetailedEmail` or `PresentationEmail`) is modified. When the WebSocket update later brings the keyword into `currentEmail`, `setKeywords` folds it into the live set and the union stays consistent.

### Keyword safety
`code` is backend-supplied and not guaranteed to be a safe keyword-path fragment (JMAP keyword paths are `keywords/<value>`; an unsanitized `code` containing `/`, whitespace, or mixed case could produce an invalid patch path or two visually-different codes that collide once lowercased elsewhere). `TwpWarning.stableId` (above) sanitizes this at the source — `code` is slugified to `[a-z0-9-]` before being embedded, and the human-readable/variable-length part of the identity (`fallbackText`) never appears verbatim in the keyword at all, only as a fixed-length hash. There is no path where a raw, unvalidated `code` or `fallbackText` reaches `KeyWordIdentifier`.

## Consequences
- Dismiss button per-banner, trailing corner, with a11y tooltip (new ARB string).
- Red error toast string for offline and API failure cases (new ARB string).
- Un-dismiss (re-show) is out of scope — no existing keyword in this codebase supports removal.
- `emailId` ownership is resolved by construction: `TwpWarningState.emailId` (ADR-0099) is set in the same call as `warnings`, so the banner and its dismiss action always agree on which email they belong to without a separate lookup.

## Risks

- **Dismissal key stability**: `stableId` is keyed on warning content (`level` + `code` + `fallbackText`, hashed), independent of list position, so reordering other warnings never invalidates a stored dismissal. Residual gap: if the backend reuses a `code` on a semantically different warning *with the same fallback text* in the future, the old dismissal would still fire. Unfixable without a server-generated stable ID — flagged for backend/product.
- **Optimistic/live reconciliation**: the effective dismissed set is `currentEmail.keywords` (live) ∪ local optimistic set. `setKeywords` must union, not replace, so an in-flight dismiss isn't dropped before the WebSocket update lands; the optimistic entry becomes redundant once the live keyword arrives.

## Open questions
- Should un-dismiss be in scope? Assume out of scope unless product says otherwise.
- Confirm exact binding/DI file used for `UnsubscribeEmailInteractor` registration before creating a new one for `DismissTwpWarningInteractor`.
