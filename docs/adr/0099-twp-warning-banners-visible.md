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
- First use of `.all()`/`AllHeaderValue` in this codebase — every other individual header (`xPriorityHeader`, `listUnsubscribeHeader`, `sMimeStatusHeader`, `identityHeader`, `listPostHeader`, `headerCalendarEvent`) is singular. Treat parsing as untested territory.
- `MailUnsubscribedBanner` (`lib/features/email/presentation/widgets/mail_unsubscribed_banner.dart`) is the structural template: plain `StatelessWidget`, internal `if`-branches, `const SizedBox.shrink()` when nothing to show, copy via `AppLocalizations.of(context)`.
- This phase introduces the new consolidated `individualHeaders` cache field (not a standalone `twpMessages` field) on `DetailedEmailHiveCache` only — `EmailCache` gets the same field in Phase 3, which later reuses it.

## Decision

### Parsing
`model/lib/email/twp_warning.dart`: `TwpWarningLevel` enum, `TwpWarning` model, tolerant parser `TwpWarning.parse(String raw, int index)`, `twpMessageHeaderName` constant.
- Unknown/missing level → `info`. Malformed lines degrade to best-effort (treat remainder as fallback text once `level:`/`code:` tokens are consumed) — never throws.
- Banner order = header arrival order (JMAP `:all` guarantees this server-side); parser preserves list order, never re-sorts.
- Prefer a localized message for known `code`s, else the header's own trailing text. The code→localized-message registry lives in `lib/main/localizations/`, not `model/`: `model/` is a plain Dart module with no `BuildContext`/`AppLocalizations` access, so the mapping is a presentation-layer concern, built near `TwpWarningBanner`, matching `MailUnsubscribedBanner`'s existing direct `AppLocalizations.of(context)` use.

### Property wiring
Add the property string to both `ThreadConstants.propertiesGetEmailContent` and `propertiesGetDetailedEmail` (read view only — not `propertiesDefault`/thread list).

### Cache shape
New field, uniform value type across both cache classes:
```dart
Map<String, List<String>>? individualHeaders
```
Every individual header (single- or multi-valued) stored as an ordered list of raw string values — re-parsed into `TwpWarning`s on read. Avoids new Hive nested-type registration.
- `DetailedEmailHiveCache`: `@HiveField(11)` (verify free at implementation time).
- `EmailCache`: introduced in Phase 3, not here (Phase 1 only touches `DetailedEmailHiveCache`).
- Old cached emails (fetched before this shipped) show no banners until next refresh — correct, not a bug, no backfill.

### Domain/presentation flow
```
Email.individualHeaders['header:X-TWP-Message:asText:all'] : AllHeaderValue
  → EmailExtension.twpWarnings : List<TwpWarning>
    → toPresentationEmail() → PresentationEmail.twpWarnings
      → TwpWarningBanner(presentationEmail) in email_view.dart, after MailUnsubscribedBanner

DetailedEmail.twpMessages : List<String>?  (domain layer, unchanged shape)
  ↔ DetailedEmailHiveCache.individualHeaders[twpMessageHeaderName]
     → re-parsed via the same parser on read
```

`TwpWarningBanner`: `StatelessWidget`, required `PresentationEmail`, `if (twpWarnings.isEmpty) return const SizedBox.shrink()`, else a `Column` of one row per warning colored by level.

## Consequences
- Banner fallback/localized text renders as plain `Text` — no HTML injection risk from a malicious backend header value.
- Phase 2 depends on `TwpWarning.index` being stable and on this banner widget existing to attach a dismiss affordance to.
- Phase 3 reuses `DetailedEmailHiveCache.individualHeaders` — whichever phase lands second must not redeclare the field under a different `@HiveField` index.
