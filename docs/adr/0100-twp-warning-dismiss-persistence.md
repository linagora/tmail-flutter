# 100. TWP Warning Dismiss Persistence

Date: 2026-07-01

## Status

Proposed

## Reference
Parent: [ADR-0098](0098-twp-warning-banners-and-header-cache-consolidation.md); builds on [ADR-0099](0099-twp-warning-banners-visible.md)

## Context

Phase 2 of #4484: dismissing a warning persists across app restarts; disabled (optimistic-hide only) when offline.

Closest existing analogue, traced end-to-end and reused as the template: the unsubscribe-mail flow (`KeyWordIdentifierExtension.unsubscribeMail` → `EmailIdExtension.generateMapUpdateObjectUnsubscribeMail()` → `EmailApi.unsubscribeMail()` → `SetEmailMethod.addUpdates`).

Key facts:
- `KeyWordIdentifierExtension` has only static, non-parameterized keyword entries today. `twpWarningDismissed(int index)` is the first parameterized `KeyWordIdentifier` factory in this codebase.
- `NetworkConnectionController` is already used by `thread_detail_controller.dart`; this is the first time `SingleEmailController` consumes it.
- No existing keyword supports removal/un-dismiss — every keyword patch is add-only (`true` at `keywords/<value>`).

## Decision

### Keyword
```dart
static KeyWordIdentifier twpWarningDismissed(int index) => KeyWordIdentifier('twp-warning-dismissed-$index');
```
Dismissal targets exactly one `TwpWarning` by its stable `index` (list position).

### Flow
```
TwpWarningBanner (dismiss tap)
  → SingleEmailController.dismissTwpWarning(emailId, index)
    → if NetworkConnectionController.isNetworkConnectionAvailable():
         DismissTwpWarningInteractor.execute(session, accountId, emailId, index)
           → EmailRepository.dismissTwpWarning(...)
             → EmailApi: SetEmailMethod(accountId)..addUpdates(
                 {emailId.id: KeyWordIdentifierExtension.twpWarningDismissed(index).generatePath(): true})
       else:
         optimistic local-only hide, no network call (per "disabled when offline" contract — not queued/retried)
    → on success: PresentationEmail.isTwpWarningDismissed(index) reads true from updated keywords map
```

New pieces mirror existing shapes exactly:
- `DismissTwpWarningInteractor` — 4-line shape like `UnsubscribeEmailInteractor`, parameterized by `index`.
- `PresentationEmail.isTwpWarningDismissed(int index)` — mirrors `isSubscribed`'s keyword-lookup shape.
- `EmailIdExtension.generateMapUpdateObjectDismissTwpWarning(int index)` — mirrors `generateMapUpdateObjectUnsubscribeMail()`.
- Reuses existing `PatchObject`/`SetEmailMethod` machinery — no new JMAP method type.

### Offline semantics
Per confirmed backend contract, offline dismiss is a local-only, non-persistent hide — not an offline-queued mutation. Going back online does not retroactively send a queued dismiss.

## Consequences
- Dismiss button per-banner, trailing corner, with a11y tooltip (new ARB string).
- Un-dismiss (re-show) is out of scope — no existing keyword in this codebase supports removal, and the issue doesn't ask for it.

## Risks

- **Index-based dismissal fragility**: if the set/order of `X-TWP-Message` headers changes between two fetches (a resolved warning, or a new one landing at the same index), a stored `twp-warning-dismissed-N` keyword could silently apply to a different warning next time. Not fixed speculatively (backend contract guarantees order stability within one response, not across time) — flagged for backend/product.

## Open questions
- Should un-dismiss be in scope? Assume out of scope unless product says otherwise.
- Dismiss key on `code` instead of/alongside `index`, to survive warning-count changes across fetches?
