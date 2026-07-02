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

One consolidated field per cache class, mirroring `Email.individualHeaders`'s single-map shape. Value type is `dynamic`, holding either a `String` or a `List<String>` — the runtime type, not the value's length, records which JMAP request form (`asText` vs. `asText:all`) produced it:
```dart
Map<String, dynamic>? individualHeaders
```
- `EmailCache`: new field at next free `@HiveField` index (23, re-verify at implementation time). Replaces `headerCalendarEvent`/`xPriorityHeader`/`importanceHeader`/`priorityHeader`/`unsubscribeHeader` as the source for `_buildIndividualHeaders()`; old fields stay declared but unwritten (Hive fields are additive-only, never reused/reordered).

A header requested singularly (`asText`, e.g. MDN, List-Post, S/MIME status, identity) writes a raw `String`. A header requested with the `:all` suffix (currently only `X-TWP-Message`) writes a `List<String>` unconditionally, even for a single returned value — a one-warning email must reconstruct as `AllHeaderValue` on read, matching what the network path produces, not collapse to `TextHeaderValue`.

**Cache-to-domain type conversion (required in `_buildIndividualHeaders()` and its `DetailedEmailHiveCache` equivalent):**
`Email.individualHeaders` is `Map<IndividualHeaderIdentifier, EmailHeaderValue>`, not `Map<String, dynamic>`. `_buildIndividualHeaders()` must convert each entry:
- Key: the stored `String` is the `IndividualHeaderIdentifier.value`; reconstruct via `IndividualHeaderIdentifier(key)` (positional constructor — `IndividualHeaderIdentifier` has no named `value` parameter).
- Value: branch on the stored value's **runtime type**, not its length:
  - `String` (singularly-requested header, e.g. MDN, List-Post, S/MIME status): `TextHeaderValue(value)`.
  - `List<String>` (a header requested with `:all`, currently only `X-TWP-Message`): `AllHeaderValue(value.map((s) => TextHeaderValue(s)).toList())` — **regardless of element count**, including a single-element list.

This matches how the JMAP layer produces `EmailHeaderValue` via `EmailHeaderValue.fromJson` today (the `:all` suffix produces `AllHeaderValue` unconditionally; a singular `asText` key produces `TextHeaderValue`). The write side must store consistently with this: singular headers write a raw `String`; `:all` headers write a `List<String>` unconditionally, never collapsed to `String` even for one value.
- `DetailedEmailHiveCache`: reuses Phase 1's field (index 11) rather than redeclaring — gains `headerMdn`/`listPostHeader`/`sMimeStatusHeader`/`identityHeader` entries; old fields (9, 10) stay declared but unwritten.

### New header requests
Add `IndividualHeaderIdentifier.headerMdn.value` and `.listPostHeader.value` to both `ThreadConstants.propertiesGetEmailContent` and `propertiesGetDetailedEmail`. Add only `headerMdn` to `trackedHeaderIds` (`listPostHeader` already present — do not duplicate).

`listPost` (`email_extension.dart`) needs no call-site change: `headers.listPost?.trim() ?? listPostHeader?.value?.trim() ?? ''` already falls back to the new header once it arrives.

`hasRequestReadReceipt` (`email_extension.dart`) also needs no change: `headers.readReceiptHasBeenRequested || headerMdn != null`. But this getter is **not** what drives the read-receipt prompt on the read view. That prompt is triggered by `Email.hasReadReceipt(Map<MailboxId, PresentationMailbox>)`, called as `success.emailCurrent.hasReadReceipt(...)` from `SingleEmailController`. Its current implementation only checks the raw header:
```dart
bool hasReadReceipt(Map<MailboxId, PresentationMailbox> mapMailbox) {
  final mailboxCurrent = findMailboxContain(mapMailbox);
  return !hasMdnSent &&
      headers.readReceiptHasBeenRequested &&
      mailboxCurrent?.isSent != true;
}
```
This must be updated to also accept `headerMdn`, e.g. `(headers.readReceiptHasBeenRequested || headerMdn != null) && ...`, otherwise the read-receipt prompt keeps missing emails where the MDN signal only arrives via the new individual header.

### Scope boundary
`EmailProperty.headers` / the raw `Set<EmailHeader>` field is never touched. `PresentationEmail` keeps its existing typed per-header fields unchanged, with the one addition above to `hasReadReceipt()`. `DetailedEmail` gains `headerMdn`/`listPostHeader` fields (`TextHeaderValue?`), mirroring its existing `sMimeStatusHeader`/`identityHeader` fields.

### Offline rebuild path must carry the new fields through
`GetEmailContentFromCacheSuccess.emailCurrent` is rebuilt in `get_email_content_interactor.dart`'s `_getStoredOpenedEmail`/`_getStoredNewEmail`, which merge specific `DetailedEmail` fields back into `emailCache.individualHeaders` by name:
```dart
final map = emailCache.individualHeaders.merge({
  if (detailedEmail.sMimeStatusHeader != null)
    IndividualHeaderIdentifier.sMimeStatusHeader: detailedEmail.sMimeStatusHeader!,
  if (detailedEmail.identityHeader != null)
    IndividualHeaderIdentifier.identityHeader: detailedEmail.identityHeader!,
});
```
Both merge blocks must gain `headerMdn`/`listPostHeader` entries the same way, or offline/cached content reads silently drop these two headers even though `DetailedEmailHiveCache` stores them correctly — breaking the read-receipt prompt and List-Post UI specifically for offline/cached opens. While touching these blocks, also fix the pre-existing inconsistency where `_getStoredOpenedEmail`'s merge is missing the `identityHeader` entry that `_getStoredNewEmail` already has.

**Read-side fallback — no user-visible regression.** `_buildIndividualHeaders()` (and its `DetailedEmailHiveCache` equivalent) reads the new `individualHeaders` field first; for any `IndividualHeaderIdentifier` **not present** in it, it falls back to reading the corresponding legacy per-header field (`headerCalendarEvent`/`xPriorityHeader`/`importanceHeader`/`priorityHeader`/`unsubscribeHeader` on `EmailCache`; `sMimeStatusHeader`/`identityHeader` on `DetailedEmailHiveCache`) using the existing pre-consolidation reconstruction logic. No cached email loses any header-derived UI at any point, upgrade or not. The legacy fields keep being read (never written) until a later, separate cleanup change confirms every entry has been refreshed at least once post-upgrade and removes the fallback — that cleanup is out of scope here and not required for this phase to ship correctly.

### Sequencing with Phase 1
Whichever of Phase 1 / Phase 3 lands second must check the other hasn't already claimed `DetailedEmailHiveCache.individualHeaders` before adding a new `@HiveField`. `EmailCache` has no such dependency — Phase 1 doesn't touch it.

## Consequences
- Old cached entries keep working via the legacy-field read fallback until they're next refreshed from the server and start populating the new consolidated field — no user-visible gap.
- `_buildIndividualHeaders()` (and its `DetailedEmailHiveCache` equivalent) gain one fallback branch per legacy field instead of becoming a pure single-field read; this fallback is removable once a future cleanup phase confirms full migration.

## Risks
- Fallback surface spans every consolidated header (calendar-event, priority/importance, list-unsubscribe, S/MIME status, identity header), not just MDN/List-Post — regression-test all of them, including the legacy-field fallback path itself.
- Duplicate `listPostHeader` entry in `trackedHeaderIds` would iterate twice for no effect — verify none exists before merging.
- `Email.hasReadReceipt()` (the actual read-receipt prompt trigger, distinct from the unused-by-that-path `hasRequestReadReceipt` getter) must be updated to check `headerMdn`, or the prompt keeps missing MDN-only-signaled emails.
- `get_email_content_interactor.dart`'s two offline-rebuild merge blocks must add `headerMdn`/`listPostHeader` entries, or offline/cached content reads silently drop these headers even though the cache stores them correctly.

## Open questions
- Confirm `EmailCache`'s next free index (23) and `DetailedEmailHiveCache`'s (11, or next-after-Phase-1) immediately before implementation.
