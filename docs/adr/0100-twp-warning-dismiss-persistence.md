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
- `KeyWordIdentifierExtension` has only static, non-parameterized keyword entries today. `twpWarningDismissed(String code, int index)` is the first parameterized `KeyWordIdentifier` factory in this codebase.
- `NetworkConnectionController` is already used by `thread_detail_controller.dart`; this is the first time `SingleEmailController` consumes it.
- No existing keyword supports removal/un-dismiss — every keyword patch is add-only (`true` at `keywords/<value>`).

## Decision

### Keyword
```dart
static KeyWordIdentifier twpWarningDismissed(String code, int index) =>
    KeyWordIdentifier('twp-warning-dismissed-$code-$index');
```
`code` is the backend-stable semantic identifier; `index` is the zero-based position within the **deduplicated** warning list, acting as a tiebreaker for the unlikely case of duplicate codes on one email. A stored keyword survives warning reordering across fetches because `code` is the primary key.

### Flow
```
TwpWarningBanner (ConsumerWidget, dismiss tap)
  → SingleEmailController.dismissTwpWarning(emailId, TwpWarning warning)
    → if NOT NetworkConnectionController.isNetworkConnectionAvailable():
         show red error toast — return (banner stays visible, no network call, nothing queued)
    → else:
         DismissTwpWarningInteractor.execute(session, accountId, emailId, warning.code, warning.index)
           → EmailRepository.dismissTwpWarning(...)
             → EmailApi: SetEmailMethod(accountId)..addUpdates(
                 {emailId.id: KeyWordIdentifierExtension
                     .twpWarningDismissed(code, index).generatePath(): true})
         on success:
           ref.read(twpWarningNotifierProvider.notifier).markDismissed(code, index)
           → notifier adds keyword string to its local optimistic set
           → Riverpod state update → ConsumerWidget rebuilds → banner row disappears immediately
           (no email object touched)
         on failure:
           show red error toast (banner stays visible)
```
Live keywords are fed separately: whenever `currentEmail` changes (incl. WebSocket), the controller calls `notifier.setKeywords(currentEmail.keywords)`; effective dismissed set = live ∪ optimistic.

New pieces mirror existing shapes exactly:
- `DismissTwpWarningInteractor` — 4-line shape like `UnsubscribeEmailInteractor`, parameterized by `code` + `index`.
- `EmailIdExtension.generateMapUpdateObjectDismissTwpWarning(String code, int index)` — mirrors `generateMapUpdateObjectUnsubscribeMail()`.
- Reuses existing `PatchObject`/`SetEmailMethod` machinery — no new JMAP method type.

### Offline semantics
When offline, dismiss shows a red error toast and returns immediately. No local banner hide, no queued mutation, no optimistic update. The banner remains visible until the user is online and successfully dismisses.

### Keyword source and dismiss success → immediate UI update
Live dismissal keywords come from `currentEmail.keywords` (the WebSocket-updated `PresentationEmail`), fed to the notifier via Phase 1's `setKeywords`. The notifier additionally keeps a local optimistic set; its effective dismissed set is the union of the two, so `setKeywords` refreshing the live portion never drops an in-flight dismiss.

On a successful JMAP call, `TwpWarningNotifier.markDismissed(String code, int index)` adds the keyword to the local optimistic set. The `TwpWarningBanner` `ConsumerWidget` watches this state and rebuilds immediately — the dismissed banner disappears without waiting for a WebSocket update or email re-fetch. No email object (`DetailedEmail` or `PresentationEmail`) is modified. When the WebSocket update later brings the keyword into `currentEmail`, `setKeywords` folds it into the live set and the union stays consistent.

## Consequences
- Dismiss button per-banner, trailing corner, with a11y tooltip (new ARB string).
- Red error toast string for offline and API failure cases (new ARB string).
- Un-dismiss (re-show) is out of scope — no existing keyword in this codebase supports removal.

## Risks

- **Dismissal key stability**: combining `code` with `index` (deduplicated position) ensures a stored keyword survives reordering. Residual gap: if the backend reuses a `code` on a semantically different warning in the future, the old dismissal would still fire. Unfixable without a server-generated stable ID — flagged for backend/product.
- **Optimistic/live reconciliation**: the effective dismissed set is `currentEmail.keywords` (live) ∪ local optimistic set. `setKeywords` must union, not replace, so an in-flight dismiss isn't dropped before the WebSocket update lands; the optimistic entry becomes redundant once the live keyword arrives.

## Open questions
- Should un-dismiss be in scope? Assume out of scope unless product says otherwise.
- Confirm exact binding/DI file used for `UnsubscribeEmailInteractor` registration before creating a new one for `DismissTwpWarningInteractor`.
- How is `emailId` passed to the dismiss call from inside `TwpWarningBanner`? Options: held in notifier state, or read from `SingleEmailController` directly in the widget. Decide at implementation time.
