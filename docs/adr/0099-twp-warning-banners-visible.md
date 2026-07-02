# 99. TWP Warning Banners — Read-Only Visibility

Date: 2026-07-01

## Status

Proposed

## Reference
Parent: [ADR-0098](0098-twp-warning-banners-and-header-cache-consolidation.md)

## Context

Phase 1 of #4484: users see server-driven warning banners (e.g. "external sender") on the email read view, always shown — no dismiss yet (Phase 2).

Key facts:
- `Email.fromJson`/`toJson` already handle arbitrary `header:X:form[:all]` keys generically — a new repeatable header needs zero changes to `Email` itself.
- `EmailHeaderValue.fromJson` branches on the `:all` suffix, returning `AllHeaderValue(List<EmailHeaderValue>)`; each element is a `TextHeaderValue`.
- First use of `.all()`/`AllHeaderValue` in this codebase — every other individual header is singular. Treat parsing as untested territory.
- This phase introduces the new consolidated `individualHeaders` cache field on `DetailedEmailHiveCache` only — `EmailCache` gets the same field in Phase 3.

## Decision

### Parsing and deduplication
`model/lib/email/twp_warning.dart`: `TwpWarningLevel` enum, `TwpWarning` model, tolerant parser `TwpWarning.parse(String raw, int index)`, deduplication helper `deduplicateTwpWarnings(List<TwpWarning>)`, `twpMessageHeaderName` constant.
- Unknown/missing level → `info`. Malformed lines degrade to best-effort — never throws.
- Parser always produces a non-empty `code` (default `'unknown'`).
- **Deduplication:** the raw parsed list is filtered by exact `(level, code, fallbackText)` triplet before being exposed. First occurrence wins; subsequent exact matches are dropped. Indices in the resulting `TwpWarning` list reflect deduplicated-list position (0-based, contiguous).
- Banner order = deduplicated-list order (JMAP `:all` guarantees server-side order; deduplication preserves first-occurrence order).
- Prefer a localized message for known `code`s, else the header's trailing text. The code→localized-message registry lives in `lib/main/localizations/`, not `model/`.

### Property wiring
Add the property string to both `ThreadConstants.propertiesGetEmailContent` and `propertiesGetDetailedEmail` (read view only — not thread list).

### Cache shape
New field, uniform value type:
```dart
@HiveField(11) Map<String, List<String>>? individualHeaders
```
Every individual header stored as an ordered list of raw string values — re-parsed and re-deduplicated on read. Avoids new Hive nested-type registration.
- `DetailedEmailHiveCache`: `@HiveField(11)` (verify free at implementation time).
- `EmailCache`: introduced in Phase 3, not here.
- Old cached emails show no banners until next refresh — correct, not a bug.

### Domain/presentation flow
```
Email.individualHeaders['header:X-TWP-Message:asText:all'] : AllHeaderValue
  → EmailExtension.twpWarnings : List<TwpWarning>  (parsed + deduplicated)
    → toPresentationEmail() → PresentationEmail.twpWarnings

Offline content-read path only (not a live source):
  DetailedEmail.twpMessages : List<String>?  (domain layer, raw headers)
    ↔ DetailedEmailHiveCache.individualHeaders[twpMessageHeaderName]
       → re-parsed + re-deduplicated on read → GetEmailContentFromCacheSuccess.emailCurrent.twpWarnings
```

### Riverpod notifier
`TwpWarningNotifier extends Notifier<TwpWarningState>` (`twpWarningNotifierProvider`):
- `TwpWarningState` holds `List<TwpWarning> warnings` (deduplicated) and `Set<String> dismissedKeywords`.
- `setWarnings(List<TwpWarning>)` replaces the warning list.
- `setKeywords(Map<KeyWordIdentifier, bool>?)` recomputes the dismissed set from TWP-prefixed keyword entries (Phase 2 unions this with a local optimistic set).
- `SingleEmailController` feeds it from two independent inputs, kept separate so a keyword-only update never wipes the warnings:
  - `setWarnings(emailCurrent.twpWarnings)` on content-load success (`GetEmailContentSuccess`/`GetEmailContentFromCacheSuccess`, fetched with `propertiesGetEmailContent`, which carries the TWP header).
  - `setKeywords(currentEmail.keywords)` from the controller's Obx/Worker listener on the open email. `currentEmail` resolves to `emailIdsPresentation[_currentEmailId]` on web/tablet or `selectedEmail` on mobile — the WebSocket-updated object. Its `keywords` are in `propertiesDefault`, so they stay current; the TWP header is not, which is why warnings come from the content load instead.
- The notifier is not fed from `DetailedEmail`/`DetailedEmailHiveCache` directly — those are not live and never update on WebSocket.
- The controller accesses the notifier via a widget-layer bridge (a `ConsumerStatefulWidget` wrapper that watches the controller's Rx open-email/content state and forwards to the notifier via `ref`) — not via a global `ProviderContainer`.

### Banner widget
`TwpWarningBanner`: `ConsumerWidget`, no constructor arguments. `ref.watch(twpWarningNotifierProvider)`. If `state.warnings.isEmpty` → `const SizedBox.shrink()`. Else a `Column` of one banner row per warning (in Phase 2, dismissed ones are hidden based on `state.dismissedKeywords`), colored by level. Inserted in `email_view.dart` after `MailUnsubscribedBanner` block.

## Consequences
- Banner fallback/localized text renders as plain `Text` — no HTML injection risk.
- Phase 2 depends on `TwpWarning.index` (deduplicated position) being stable, `TwpWarningNotifier` existing, and this widget existing.
- Phase 3 reuses `DetailedEmailHiveCache.individualHeaders` — whichever phase lands second must not redeclare the field under a different `@HiveField` index.
