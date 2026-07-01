# 101. Consolidate Individual-Header Cache Fields

Date: 2026-07-01

## Status

Proposed

## Reference
Parent: [ADR-0098](0098-twp-warning-banners-and-header-cache-consolidation.md); shares `DetailedEmailHiveCache.individualHeaders` introduced in [ADR-0099](0099-twp-warning-banners-visible.md)

## Context

Tech-debt payoff requested alongside #4484, not part of the banner feature itself. Current state:

- `EmailCache` (`lib/features/thread/data/model/email_cache.dart`): five separate `Map<String, String?>?` `@HiveField`s — `headerCalendarEvent` (14), `xPriorityHeader` (16), `importanceHeader` (17), `priorityHeader` (18), `unsubscribeHeader` (20) — reassembled at read time by `EmailCacheExtension._buildIndividualHeaders()`.
- `DetailedEmailHiveCache`: two separate fields — `sMimeStatusHeader` (9), `identityHeader` (10).
- Two headers never fetched as individual headers despite having presets: MDN (`Disposition-Notification-To`, `IndividualHeaderIdentifier.headerMdn`) and `List-Post` (`IndividualHeaderIdentifier.listPostHeader`).
- `listPostHeader` is already in `mergeTrackedIndividualHeaders`'s `trackedHeaderIds` but never actually requested as a property — currently dead code. `headerMdn` is missing from `trackedHeaderIds` entirely.
- `sMimeStatusHeader`/`identityHeader` are fetched but not tracked — never refreshed by incremental `Email/changes` merges (pre-existing gap, not fixed here).

This is the widest-blast-radius phase in the plan: it touches every individual header currently read from cache, not just the two new ones.

## Decision

One consolidated field per cache class, mirroring `Email.individualHeaders`'s single-map shape:
```dart
Map<String, List<String>>? individualHeaders
```
- `EmailCache`: new field at next free `@HiveField` index (23, re-verify at implementation time). Replaces `headerCalendarEvent`/`xPriorityHeader`/`importanceHeader`/`priorityHeader`/`unsubscribeHeader` as the source for `_buildIndividualHeaders()`; old fields stay declared but unwritten (Hive fields are additive-only, never reused/reordered).
- `DetailedEmailHiveCache`: reuses Phase 1's field (index 11) rather than redeclaring — gains `headerMdn`/`listPostHeader`/`sMimeStatusHeader`/`identityHeader` entries; old fields (9, 10) stay declared but unwritten.

### New header requests
Add `IndividualHeaderIdentifier.headerMdn.value` and `.listPostHeader.value` to both `ThreadConstants.propertiesGetEmailContent` and `propertiesGetDetailedEmail`. Add only `headerMdn` to `trackedHeaderIds` (`listPostHeader` already present — do not duplicate).

Existing fallback logic needs no call-site changes once these arrive:
- `hasRequestReadReceipt`: `headers.readReceiptHasBeenRequested || headerMdn != null`.
- `listPost`: `headers.listPost?.trim() ?? listPostHeader?.value?.trim() ?? ''`.

### Scope boundary
`EmailProperty.headers` / the raw `Set<EmailHeader>` field is never touched. Domain/presentation layers (`PresentationEmail`, `DetailedEmail`) keep their existing typed per-header fields unchanged — only the two Hive cache classes' storage shape changes. No user-visible behavior change.

### Sequencing with Phase 1
Whichever of Phase 1 / Phase 3 lands second must check the other hasn't already claimed `DetailedEmailHiveCache.individualHeaders` before adding a new `@HiveField`. `EmailCache` has no such dependency — Phase 1 doesn't touch it.

## Consequences
- Old cached entries (populated only in the now-unwritten per-field slots) read as absent from the new field until next server refresh — correct, no backfill, matches Phase 1's pattern.
- `_buildIndividualHeaders()` (and its `DetailedEmailHiveCache` equivalent) become simple single-field reads instead of a multi-field merge loop.

## Risks
- Regression surface spans every consolidated header (calendar-event, priority/importance, list-unsubscribe, S/MIME status, identity header), not just MDN/List-Post — regression-test all of them.
- Duplicate `listPostHeader` entry in `trackedHeaderIds` would iterate twice for no effect — verify none exists before merging.

## Open questions
- Confirm `EmailCache`'s next free index (23) and `DetailedEmailHiveCache`'s (11, or next-after-Phase-1) immediately before implementation.
