# 98. TWP Warning Banners and Individual-Header Cache Consolidation

Date: 2026-07-01

## Status

Proposed

## Reference
GitHub issue #4484

## Context

Server-driven warning banners on the email read view (e.g. "external sender", "virus detected"), signalled via a repeatable header:

```
X-TWP-Message: level:info code:suspicious-sender This email is from an external sender...
```

Backend contract:
- One header per warning, several may appear on one message, order is stable.
- Format always `level:<info|warn|error> code:<code> <fallback text>`.
- All levels dismissable. Unknown level defaults to `info`.
- Dismissal is per-warning (per position in the deduplicated list), persisted as a keyword; shows a red error toast when offline — no local hide, no queued mutation.
- Frontend prefers a localized message for known `code`s, falling back to the header's trailing text.

Separately: consolidate the cache classes' individual-header storage onto a single `individualHeaders`-shaped field per cache class (mirroring `Email.individualHeaders`), using `X-TWP-Message` as the forcing function. The legacy raw `Set<EmailHeader>? headers` field is unrelated and out of scope — not touched, not merged with `individualHeaders`.

## Decision

Three independently-shippable phases:

1. **[ADR-0099](0099-twp-warning-banners-visible.md)** — parse `X-TWP-Message`, deduplicate, plumb through cache/presentation, render banners read-only via Riverpod `TwpWarningNotifier`.
2. **[ADR-0100](0100-twp-warning-dismiss-persistence.md)** — per-header dismiss via notifier, persisted keyword, red error toast when offline.
3. **[ADR-0101](0101-consolidate-individual-header-cache-fields.md)** — consolidate `EmailCache`/`DetailedEmailHiveCache`'s separate per-header fields into one `individualHeaders` field each; fetch MDN/List-Post as individual headers.

### Ground rules across all phases

- `Email` keeps both the legacy `Set<EmailHeader>? headers` field and `Map<IndividualHeaderIdentifier, EmailHeaderValue> individualHeaders` — two unrelated fields. Only `individualHeaders`-feeding storage is reshaped; `headers` stays untouched everywhere.
- `X-TWP-Message` does not get a typed preset/getter on `Email` (unlike `xPriorityHeader` etc.) — it's a `List`, not a single value. Stays an inline `IndividualHeaderIdentifier.asText('X-TWP-Message').all()` lookup.
- Hive field indices are additive-only — never reused/reordered once shipped. Old per-header fields' indices stay reserved/unused once superseded, not deleted.
- Domain/presentation layers (`PresentationEmail`, `DetailedEmail`) keep their existing typed per-header fields unchanged — consolidation is scoped to the two Hive cache classes only.
- **Header deduplication before display:** raw TWP headers are deduplicated by exact `(level, code, fallbackText)` triplet before being exposed as the warning list or used for dismiss indexing. Indices in `TwpWarning` reflect position in the deduplicated list.
- **`TwpWarningBanner` is a Riverpod `ConsumerWidget`** with no constructor arguments. It reads all warning and dismissal state from `TwpWarningNotifier` (`NotifierProvider`). `SingleEmailController` feeds the notifier from two live sources: **warnings** from the content-load `PresentationEmail` (`GetEmailContentSuccess`/`GetEmailContentFromCacheSuccess.emailCurrent`, fetched with `propertiesGetEmailContent`), and **keywords** from `currentEmail.keywords` (the WebSocket-updated open email — `emailIdsPresentation[_currentEmailId]` on web/tablet, or `selectedEmail` on mobile). `DetailedEmail`/`DetailedEmailHiveCache` are not a live source and never feed the notifier directly; they back only the offline content-read path. The notifier maintains its own optimistic dismissed-keyword set and never writes back into any email object.
- Code→localized-message registry lives in `lib/main/localizations/`, not `model/`. `model/` is a plain Dart module with no `BuildContext`/`AppLocalizations` access; the mapping is a presentation-layer concern, matching `MailUnsubscribedBanner`'s existing direct use of `AppLocalizations.of(context)`.

## Open questions
- Ask backend/product: is per-index-in-deduplicated-list dismissal safe if warning count changes between fetches, or should dismissal key on `code` alone when it is unique per email?
