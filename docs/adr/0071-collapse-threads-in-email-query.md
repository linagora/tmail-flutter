# 0071 - Enable collapseThreads in Email/query

Date: 2026-03-12

## Status

Proposed

## Context

JMAP `Email/query` supports `collapseThreads` (RFC 8621 §4.4). When `true`, server returns only the **latest email per thread**, avoiding duplicate rows in the mail list.

Currently, our app does **not** set `collapseThreads`. When thread is enabled, users see multiple emails from the same thread as separate rows.

### Two Query Paths (see ADR-0070)

| Path | `FORCE_EMAIL_QUERY` | Method | Cache |
|------|---------------------|--------|-------|
| Force query | `true` | `forceQueryAllEmailsForWeb()` | No local cache — server only |
| Cache-first | `false` | `getAllEmail()` | Local DB first, then sync |

### Problem: Cache Inconsistency on Toggle

On the cache-first path, the local DB reflects the `collapseThreads` mode it was built under. When thread mode changes:

- **OFF → ON**: Cache has individual emails (5 rows) but server now returns collapsed (3 rows) → stale first yield
- **ON → OFF**: Cache has collapsed emails (3 rows) but server now returns all individuals (5 rows) → missing emails in first yield

Force-query path has **no problem** — always queries server directly.

## Decision

### 1. Set `collapseThreads: true` in Email/query When Thread Is Enabled

In `MailAPIMixin.fetchAllEmail()` and `ThreadAPI.searchEmails()`, pass `collapseThreads: true` when thread is enabled.

### 2. Clear Email Cache on Thread Setting Toggle

Reuse the existing thread-enabled setting. **No new flag needed.** When thread is toggled (enable ↔ disable), clear email cache immediately in the toggle handler. Next `getAllEmail()` will rebuild cache under correct mode.

### 3. No Change for Force-Query Path

Already server-only. Just pass `collapseThreads: true` in the query.

## Consequences

**Positive**: Correct thread display, reduced data per page, spec-compliant.

**Negative**: One-time full reload on each toggle; toggle handler coupled with cache management.

## Implementation Steps

1. Add `collapseThreads` to `QueryEmailMethod` in `MailAPIMixin.fetchAllEmail()` and `ThreadAPI.searchEmails()`
2. Pass thread-enabled status from Settings to query builder
3. Clear email cache in thread setting toggle handler
4. Update `GetEmailsInMailboxInteractor` and related interactors to propagate thread status

## References

- [RFC 8621 §4.4](https://www.rfc-editor.org/rfc/rfc8621#section-4.4)
- [ADR-0070](./0070-sync-strategy-disappearing-emails.md)
- `lib/features/base/mixin/mail_api_mixin.dart` — `fetchAllEmail()`
- `lib/features/thread/data/repository/thread_repository_impl.dart` — `getAllEmail()`
- `lib/features/thread/domain/usecases/get_emails_in_mailbox_interactor.dart`
