# 93. Search Filter — Single Source of Truth

Date: 2026-06-19

## Status

Proposed

## Related ADRs

- [ADR-0085](./0085-riverpod-state-management-for-local-settings.md) — Riverpod pilot, `appProviderContainer` pattern
- [ADR-0092](./0092-upgrade-flutter-riverpod-3.md) — Riverpod 3.x, `keepAlive` rule, frozen `appProviderContainer`

## Context

### The four bugs

| Issue | Symptom |
|---|---|
| #4421 | "From me" / "Last 7 days" shortcut chips not reflected when opening the advanced filter panel |
| #4612 | Searching from inside a folder does not pre-fill that folder in the search filter |
| #4590 | Inbox "Unread" filter bleeds into search results; Unread chip appears deselected |
| #4490 | Inbox filter applied but filter chip disappears from UI after navigation |

### Root cause: two disconnected write funnels, no shared state

All four bugs trace to the same structural flaw: `SearchEmailFilter` state lives in two independent, unconnected objects with duplicated mutation logic.

**Web write funnel** — 10+ call sites routing through `SearchController.updateFilterEmail()`:

```
ThreadController            → searchController.updateFilterEmail(...)
MailboxDashBoardController  → searchController.updateFilterEmail(...)  (×10)
AdvancedFilterController    → searchController.synchronizeSearchFilter(...)
```

All of these mutate `SearchEmailFilter` via `copyWith()` inside `SearchController`.

**Mobile write funnel** — 20+ call sites routing through `SearchEmailController._updateSimpleSearchFilter()`:

```
SearchEmailController._updateSimpleSearchFilter(...)  ← 20+ internal call sites
```

This calls `SearchEmailFilter.copyWith()` separately — the same logic duplicated in a different controller. The two funnels are entirely independent. `SearchEmailController.searchEmailFilter.obs` is re-created from `SearchEmailFilter.initial()` on every mobile search entry, disconnected from `SearchController.searchEmailFilter.obs`.

A fourth disconnected object, `SearchController.listFilterOnSuggestionForm`, stages suggestion chip selections and is only merged into `searchEmailFilter` on search submit — so the advanced filter panel never sees pending chip state.

Additionally, `MailboxDashBoardController.filterMessageOption` (inbox-only filter) is silently ANDed into web search JMAP queries via `moreFilterCondition: getFilterCondition()`, producing results that do not match the chip UI.

**Per-bug root cause:**

| Bug | Cause |
|---|---|
| #4421 | `listFilterOnSuggestionForm` never merged into `searchEmailFilter` until submit; mobile `SearchEmailController` starts fresh, unaware of any chip state from `SearchController` |
| #4612 | `SearchEmailFilter.mailbox` always initialises to `null`; current folder context never seeded on search entry |
| #4590 | `ThreadController._searchEmail()` ANDs `filterMessageOption` as `moreFilterCondition`; chip bar reads `SearchEmailFilter.unread` (always `false`) → chip deselected, results still filtered |
| #4490 | `filterMessageOption` reset to `all` by unrelated code paths (e.g. `handleClearAdvancedSearchFilterEmail()`); cached email list still shows filtered results while chip shows deselected |

### Secondary structural problems (after SSOT is established)

After fixing the SSOT write paths, a second class of problems remains: search execution methods write **pagination cursors** (`position`, `before`, `startDate`) to the SSOT immediately before every interactor call.

- `ThreadController._searchEmail()` and `SearchEmailController._searchEmailAction()` both reset the cursor to 0 before every fresh search.
- `ThreadController._searchMoreEmails()` and `SearchEmailController.searchMoreEmailsAction()` advance the cursor for each load-more page — duplicating the same `isScrollByPosition()` branching logic across two controllers.
- `SearchEmailController._initializeDebounceTimeTextSearchChange()` resets the cursor on every debounced text change (suggestion-only path — before the user even submits).

Pagination cursors are **execution-time state**, not user intent. Writing them to the SSOT mixes two unrelated concerns and makes OCP impossible: every new search execution variant must touch controller code to reset/advance cursors manually.

A secondary coupling issue: `MailboxDashBoardController._applyFilterMessageOptionToSearchFilter()` was called from inside `AdvancedFilterController.initSearchFilterField()` — a child controller calling a parent-side write. This violated unidirectional data flow and created an implicit ordering dependency between two controllers.

## Decision

### Chosen approach: Riverpod `SearchFilterNotifier` as single source of truth (Phase 1)

Introducing `SearchFilterNotifier` — a Riverpod `@keepAlive` notifier — as the single canonical owner of `SearchEmailFilter`. The mobile search view (`SearchEmailView`) is migrated to `ConsumerStatefulWidget` to consume it reactively. The web path (`SearchController`) keeps its existing `searchEmailFilter.obs` as a mirror bridged from the notifier via one documented `appProviderContainer.listen()` call, allowing progressive migration without breaking web widgets.

This establishes a clean single source of truth now, and positions web `Obx` widgets for incremental migration to `Consumer` in a follow-up PR.

### Core invariant

> `SearchEmailFilter.copyWith()` is called in exactly one place: `SearchFilterNotifier.update()`.
> No other controller or widget may call `copyWith()` on filter state through any other path.

### 1. `SearchFilterNotifier` — the single source of truth

```dart
@Riverpod(keepAlive: true)
class SearchFilterNotifier extends _$SearchFilterNotifier {
  @override
  SearchEmailFilter build() => SearchEmailFilter.initial();

  void update({
    Option<String>? fromOption,
    Option<String>? toOption,
    Option<MailboxResponse>? mailboxOption,
    Option<bool>? hasAttachmentOption,
    Option<EmailReceiveTimeType>? emailReceiveTimeTypeOption,
    Option<String>? notKeywordOption,
    Option<String>? subjectOption,
    Option<bool>? unreadOption,
  }) {
    state = state.copyWith(
      from: fromOption,
      to: toOption,
      mailbox: mailboxOption,
      hasAttachment: hasAttachmentOption,
      emailReceiveTimeType: emailReceiveTimeTypeOption,
      notKeyword: notKeywordOption,
      subject: subjectOption,
      unread: unreadOption,
    );
  }

  void clear() {
    // Preserve the user's sort order preference; reset everything else.
    state = SearchEmailFilter.withSortOrder(state.sortOrderType);
  }
}
```

#### Notifier lifecycle

| Event | Trigger | Action |
|---|---|---|
| **Created** | First `ref.read/watch` after container start or after `invalidate()` | `build()` → `SearchEmailFilter.initial()` |
| **Updated** | Chip tap, form field edit, folder pre-fill on search entry | `update(...)` — partial field update, sort order preserved |
| **Cleared** | User clears all filters (exit or "clear all" button) | `clear()` — resets all fields, preserves `sortOrderType` |
| **Session end** | Logout or account switch | `appProviderContainer.invalidate(searchFilterNotifierProvider)` — called from `MailboxDashBoardController.onClose()` |

**Session-end reset** is required because `appProviderContainer` is application-scoped (lives for the process lifetime, per ADR-0092). Without `invalidate()`, a user who logs out and logs into a different account would see stale filter state from the previous session. `invalidate()` disposes the current notifier state; the next `ref.read/watch` triggers `build()` again and returns `SearchEmailFilter.initial()`.

```dart
// MailboxDashBoardController.onClose()
@override
void onClose() {
  appProviderContainer.invalidate(searchFilterNotifierProvider);
  // ... existing cleanup ...
  super.onClose();
}
```

### 2. `SearchController` — web Rx bridge (1 documented `appProviderContainer` exception)

`SearchController.searchEmailFilter.obs` becomes a passive mirror. On init, it subscribes to the notifier:

```dart
appProviderContainer.listen<SearchEmailFilter>(
  searchFilterNotifierProvider,
  (_, next) { searchEmailFilter.value = next; },
  fireImmediately: true,
);
```

`SearchController.updateFilterEmail()` delegates writes to the notifier instead of calling `copyWith()` directly:

```dart
void updateFilterEmail({...}) {
  appProviderContainer
    .read(searchFilterNotifierProvider.notifier)
    .update(...);
}
```

`clearAllFilterSearch()` and `disableAllSearchEmail()` call `notifier.clear()`.

All existing web `Obx` widgets watching `searchController.searchEmailFilter.obs` continue to work without change.

**Methods that bypass the notifier and must be removed:**

`SearchController.synchronizeSearchFilter()` and `clearSearchFilter()` currently mutate `searchEmailFilter.value` directly, violating the core invariant. Both must be eliminated:

- `synchronizeSearchFilter(SearchEmailFilter)` — used by `AdvancedFilterController` when applying the advanced filter; replace with a direct notifier call or route through `updateFilterEmail()`.
- `clearSearchFilter({EmailSortOrderType?})` — used within `SearchController` itself; replace with `notifier.clear()` (which already preserves sort order — see `clear()` above).

### 3. Eliminate `SearchEmailController.searchEmailFilter.obs` (the mobile duplicate)

`SearchEmailController` drops:
- `searchEmailFilter.obs` — independent duplicate
- `emailReceiveTimeType.obs` — duplicates `SearchEmailFilter.emailReceiveTimeType`; reads replace with `ref.watch(searchFilterNotifierProvider).emailReceiveTimeType`
- `emailSortOrderType.obs` — duplicates `SearchEmailFilter.sortOrderType`; reads replace with `ref.watch(searchFilterNotifierProvider).sortOrderType`
- `_updateSimpleSearchFilter()` and its public wrapper — duplicate `copyWith()` logic

All 20+ internal call sites are replaced with:

```dart
appProviderContainer
  .read(searchFilterNotifierProvider.notifier)
  .update(...);
```

Reading filter state in `SearchEmailController` uses `searchController.searchEmailFilter.value` (already synced from notifier via bridge).

### 4. `SearchEmailView` → `ConsumerStatefulWidget` (mobile UI reads notifier directly)

`SearchEmailView` is converted from `GetView<SearchEmailController>` to `ConsumerStatefulWidget`. Filter state in the mobile UI is read via:

```dart
final filter = ref.watch(searchFilterNotifierProvider);
```

Filter chips, form fields, and counters replace their `Obx` wrappers with `Consumer` or `ref.watch()` at the appropriate widget level. The `SearchEmailController` is still retrieved via `Get.find<SearchEmailController>()` for action methods.

### 5. Eliminate `listFilterOnSuggestionForm` — suggestion chips write directly (fixes #4421)

Remove `listFilterOnSuggestionForm`, `addQuickSearchFilterToSuggestionSearchView`, `deleteQuickSearchFilterFromSuggestionSearchView`, `applyFilterSuggestionToSearchFilter`, and `clearFilterSuggestion` from `SearchController`.

Suggestion chip taps call `searchController.updateFilterEmail(...)` directly (which routes to the notifier). The advanced filter panel reads `searchController.searchEmailFilter.value` on open — already includes chip selections. No staging, no deferred merge.

### 6. Pre-fill current folder on search entry (fixes #4612)

`MailboxDashBoardController._preFillMailboxForSearch()` calls `searchController.updateFilterEmail(mailboxOption: Some(selectedMailbox))` before `_unSelectedMailbox()` clears the selected mailbox, guarded by:

```dart
if (selectedMailbox != null
    && !selectedMailbox.isUnifiedMailbox
    && !selectedMailbox.isVirtual
    && !searchController.searchEmailFilter.value.hasMailboxFilter) {
  searchController.updateFilterEmail(mailboxOption: Some(selectedMailbox));
}
```

The folder chip is pre-selected; the user can clear it to search all email.

### 7. Remove `FilterMessageOption` from JMAP search path (fixes #4590)

Remove `moreFilterCondition: getFilterCondition()` from `ThreadController._searchEmail()` and `_searchMoreEmails()`. Search JMAP queries use `searchController.searchEmailFilter.value.mappingToEmailFilterCondition()` exclusively. `FilterMessageOption` becomes inbox-only state.

### 8. Isolate `FilterMessageOption` lifecycle from search (fixes #4490)

In `MailboxDashBoardController`:
- On search entry: save `_filterMessageOptionBeforeSearch = filterMessageOption.value`; call `clearFilterMessageOption()`.
- On search exit (`restoreFilterMessageOption()`): restore `filterMessageOption.value = _filterMessageOptionBeforeSearch`.

Remove `clearFilterMessageOption()` from `handleClearAdvancedSearchFilterEmail()` — that method resets only the search filter via `searchController.clearAllFilterSearch()`.

### 9. Interaction diagram

```
User action (chip tap / text / open filter panel / enter search)
                          │
                          ▼
           ┌──────────────────────────────────────────┐
           │         SearchFilterNotifier (SSOT)       │  Riverpod keepAlive
           │         update() / set() / clear()        │  ← single write path
           └──────────────────────────────────────────┘
              ▲                        │
              │                        │ appProviderContainer.listen()
  Writes via appProviderContainer:     ▼
  SearchController.updateFilterEmail() ┌──────────────────────────────┐
  SearchEmailController (mobile)       │  SearchController             │
  AdvancedFilterController (web)       │  .searchEmailFilter.obs       │  GetX Rx — web mirror
                                       └──────────────────────────────┘
                                                  │
                                    read by Obx web widgets
                                    read by ThreadController / SearchEmailController
                                                  │
                                                  ▼ (on execute search — see Phase 2)
                                       SearchFilterPipeline([...])
                                       resolvedFilter (ephemeral)
                                                  │
                                                  ▼
                                       SearchEmailInteractor.execute(...)

SearchEmailView (ConsumerStatefulWidget)
  ref.watch(searchFilterNotifierProvider) ← direct Riverpod reactivity (mobile)

MailboxDashBoardController.filterMessageOption  ← INBOX ONLY
  saved on search entry → mapped via FilterMessageOptionTransformer → written to SSOT
  restored on search exit via restoreFilterMessageOption()
  NEVER passed directly to JMAP search queries
```

### Documented `appProviderContainer` exceptions (ADR-0092 delta)

| Call site | Type | Reason |
|---|---|---|
| `SearchController.onInit()` | `listen()` | Web Rx bridge — mirrors notifier into `searchEmailFilter.obs` for existing `Obx` widgets |
| `SearchController.updateFilterEmail()` / clear methods | `read()` | Web write path delegates to notifier |
| `SearchEmailController` write sites | `read()` | Mobile write path delegates to notifier |

All three are in the search feature boundary only and are documented here per ADR-0092 policy.

---

## Decision (Phase 2) — Search Filter Pipeline/Transformer

### Problem

After the SSOT was established, the `SearchFilterNotifier.update()` is still called with pagination cursors immediately before every interactor call — these are execution-time state, not user intent:

- `ThreadController._searchEmail()` and `SearchEmailController._searchEmailAction()` reset cursor to 0 before fresh search.
- `ThreadController._searchMoreEmails()` and `SearchEmailController.searchMoreEmailsAction()` advance the cursor — duplicating the same `isScrollByPosition()` branching logic across two controllers.
- `SearchEmailController._initializeDebounceTimeTextSearchChange()` resets cursor on every debounced text change.

Additionally, `FilterMessageOption`-to-search-filter mapping lives as an inline `switch` in `MailboxDashBoardController._applyFilterMessageOptionToSearchFilter()` — called via a reverse dependency from `AdvancedFilterController.initSearchFilterField()` (child calling parent's write method).

Neither is testable in isolation and both violate OCP: every new search execution variant requires modifying existing controller code.

### Decision

Introduce `SearchFilterTransformer` + `SearchFilterPipeline` in `lib/features/search/email/domain/transformer/`.

```dart
abstract class SearchFilterTransformer {
  SearchEmailFilter transform(SearchEmailFilter filter);
}

class SearchFilterPipeline {
  const SearchFilterPipeline(this._transformers);
  final List<SearchFilterTransformer> _transformers;
  SearchEmailFilter apply(SearchEmailFilter base) =>
      _transformers.fold(base, (acc, t) => t.transform(acc));
}
```

Two categories of transformer:

**Transient** — applied at execution time; result is passed directly to the interactor and never written back to the SSOT:

| Transformer | Constructor params | Replaces |
|---|---|---|
| `ResetPaginationTransformer` | none | `updateFilterEmail(positionOption: ..., beforeOption: ...)` before fresh search (6 sites across 2 controllers) |
| `SearchMoreTransformer` | `currentEmailCount`, `lastEmailDate` | Duplicated `if/else if/else isScrollByPosition()` cursor logic in `_searchMoreEmails()` and `searchMoreEmailsAction()` |

**Intent** — applied once on search entry; result is written to the SSOT via `notifier.set()` so the advanced filter form and UI chips reflect the correct state:

| Transformer | Constructor params | Replaces |
|---|---|---|
| `FilterMessageOptionTransformer` | `filterMessageOption` | Inline `switch` in `_applyFilterMessageOptionToSearchFilter()` |

Usage at execution time (transient path):
```dart
final resolvedFilter = const SearchFilterPipeline([
  ResetPaginationTransformer(),
]).apply(searchController.searchEmailFilter.value);

consumeState(_searchEmailInteractor.execute(
  position: resolvedFilter.position,
  filter: resolvedFilter.mappingToEmailFilterCondition(...),
  ...
));
```

Usage on search entry (intent path):
```dart
// In applyCurrentFilterMessageOptionToSearch():
if (_filterMessageOptionBeforeSearch == null) {
  final resolved = SearchFilterPipeline([
    FilterMessageOptionTransformer(filterMessageOption.value),
  ]).apply(searchController.searchEmailFilter.value);
  appProviderContainer.read(searchFilterProvider.notifier).set(resolved);
}
```

### Fix for reverse coupling

`MailboxDashBoardController.openAdvancedSearchView()` calls `applyCurrentFilterMessageOptionToSearch()` **before** dispatching `OpenAdvancedSearchViewAction`:

```dart
void openAdvancedSearchView() {
  applyCurrentFilterMessageOptionToSearch(); // ← moved here
  dispatchAction(OpenAdvancedSearchViewAction());
  searchController.openAdvanceSearch();
}
```

`AdvancedFilterController.initSearchFilterField()` no longer calls back into the dashboard controller. It only reads from the SSOT via `searchController.searchEmailFilter.value`. `_applyFilterMessageOptionToSearchFilter()` is deleted.

### New invariant

> Pagination cursors (`position`, `before`, `startDate` as cursor) are never written to the SSOT. They are computed transiently by pipeline transformers at search execution time.

### Pipeline diagram

```
  User action (chip tap, text input, form submit, folder select)
                              │
                              ▼
              ┌───────────────────────────────┐
              │   SearchFilterNotifier (SSOT)  │  ← keepAlive Riverpod
              │   user intent only:            │
              │   from, to, text, mailbox,     │
              │   unread, hasAttachment,        │
              │   hasKeyword, sortOrder, ...   │
              └───────────────┬───────────────┘
                              │
           ┌──────────────────┴──────────────────────┐
           │                                          │
           ▼ on search entry (intent path)            ▼ on execute search (transient path)
           │                                          │
  FilterMessageOptionTransformer           ┌──────────┴──────────┐
  (unread/attachments/starred chip         │                     │
   → filter fields)                     Fresh search          Load-more
           │                            │                        │
           ▼                   ResetPaginationTransformer   SearchMoreTransformer
  notifier.set(resolved)       (position: 0 / before: None)  (position: N /
  → SSOT updated               │                              before/startDate: lastDate)
  → form/chips reflect it      │                              │
                               └──────────────┬───────────────┘
                                              │
                                        resolvedFilter
                                        (ephemeral — never stored)
                                              │
                                              ▼
                               SearchEmailInteractor.execute(
                                 position:  resolvedFilter.position,
                                 sort:      resolvedFilter.sortOrderType...,
                                 filter:    resolvedFilter
                                              .mappingToEmailFilterCondition(...)
                               )
                                              │
                                              ▼
                                          JMAP result
```

**Why two paths:**

| Path | When | Written to SSOT? | Why |
|---|---|---|---|
| Intent (`FilterMessageOptionTransformer`) | On search entry (focus / panel open) | **Yes** — via `notifier.set()` | UI (advanced filter form, chips) must read the mapped state |
| Transient (`ResetPaginationTransformer`, `SearchMoreTransformer`) | At interactor call time | **No** — `resolvedFilter` is ephemeral | Cursors are execution-time state, not user intent |

### Extension pattern (OCP)

New search execution variants = new `SearchFilterTransformer` subclass. No existing transformer, controller method, or filter model is modified.

---

## Modified files

| File | Change |
|---|---|
| `lib/features/search/email/domain/notifier/search_filter_notifier.dart` | New — `SearchFilterNotifier` (`@Riverpod(keepAlive: true)`) |
| `lib/features/search/email/domain/notifier/search_filter_notifier.g.dart` | Generated by build_runner |
| `lib/features/search/email/domain/transformer/search_filter_transformer.dart` | New — abstract transformer contract |
| `lib/features/search/email/domain/transformer/search_filter_pipeline.dart` | New — fold-based pipeline |
| `lib/features/search/email/domain/transformer/reset_pagination_transformer.dart` | New — clears cursors for fresh search |
| `lib/features/search/email/domain/transformer/search_more_transformer.dart` | New — advances cursor for load-more |
| `lib/features/search/email/domain/transformer/filter_message_option_transformer.dart` | New — maps chip state to filter fields |
| `SearchController` | `updateFilterEmail()` / clear methods → delegate to notifier; bridge on init; remove `synchronizeSearchFilter()` and `clearSearchFilter()` |
| `SearchEmailController` | Drop `searchEmailFilter.obs`, `emailReceiveTimeType.obs`, `emailSortOrderType.obs`, `_updateSimpleSearchFilter()`; remove pagination writes before interactor calls; use `SearchFilterPipeline` |
| `ThreadController` | Remove `moreFilterCondition`; remove pagination writes before interactor calls; use `SearchFilterPipeline` |
| `MailboxDashBoardController` | Add `invalidate()` in `onClose()`; `_applyFilterMessageOptionToSearchFilter()` → `FilterMessageOptionTransformer`; move `applyCurrentFilterMessageOptionToSearch()` call to `openAdvancedSearchView()` |
| `AdvancedFilterController` | Remove `_mailboxDashBoardController.applyCurrentFilterMessageOptionToSearch()` call from `initSearchFilterField()` |
| `SearchEmailView` | `GetView<SearchEmailController>` → `ConsumerStatefulWidget` |

## Deleted symbols

| Symbol | Reason |
|---|---|
| `SearchController.listFilterOnSuggestionForm` | Staging concept eliminated |
| `SearchController.addQuickSearchFilterToSuggestionSearchView()` | Same |
| `SearchController.deleteQuickSearchFilterFromSuggestionSearchView()` | Same |
| `SearchController.applyFilterSuggestionToSearchFilter()` | Same |
| `SearchController.clearFilterSuggestion()` | Same |
| `SearchController.synchronizeSearchFilter()` | Bypasses notifier — violates the single-write-path invariant |
| `SearchController.clearSearchFilter()` | Bypasses notifier — replaced by `notifier.clear()` |
| `SearchEmailController.searchEmailFilter.obs` | Duplicate eliminated |
| `SearchEmailController.emailReceiveTimeType.obs` | Duplicate of `SearchEmailFilter.emailReceiveTimeType` |
| `SearchEmailController.emailSortOrderType.obs` | Duplicate of `SearchEmailFilter.sortOrderType` |
| `SearchEmailController._updateSimpleSearchFilter()` | Duplicate `copyWith()` logic eliminated |
| `SearchEmailController.updateSimpleSearchFilter()` | Same |
| `moreFilterCondition: getFilterCondition()` in `ThreadController` | `FilterMessageOption` no longer bleeds into search |
| `MailboxDashBoardController._applyFilterMessageOptionToSearchFilter()` | Replaced by `FilterMessageOptionTransformer` |

## Unit tests

| Test | Coverage |
|---|---|
| `search_filter_notifier_test.dart` (new) | `update()` for every field; `clear()` preserves `sortOrderType`; partial update preserves unspecified fields |
| `reset_pagination_transformer_test.dart` (new) | position-sort → `position: 0`, clears `before`; date-sort → clears all cursors; customRange → `startDate` preserved |
| `search_more_transformer_test.dart` (new) | position-sort + count=25 → `position: 25`; mostRecent + date → `before`; oldest + date → `startDate` |
| `filter_message_option_transformer_test.dart` (new) | unread → `unread: true`; attachments → `hasAttachment: true`; starred → `$Flagged` in `hasKeyword`; all → filter unchanged |
| `search_filter_pipeline_test.dart` (new) | empty pipeline → unchanged; single transformer → delegates; two transformers → left-to-right fold |
| `search_controller_test.dart` (extend) | `updateFilterEmail()` delegates to notifier; clear methods call `notifier.clear()`; `searchEmailFilter.obs` mirrors notifier |
| `search_email_controller_test.dart` (extend) | Filter writes go to notifier; `emailReceiveTimeType` / `emailSortOrderType` obs fields absent; no pagination writes to SSOT |
| `thread_controller_test.dart` (extend) | `_searchEmail()` never passes `moreFilterCondition`; no pagination writes to SSOT before interactor call |

## Integration tests (patrol)

| File | Scenario |
|---|---|
| `search_filter_sync_with_shortcuts_test.dart` | Select "From me" → open advanced panel → verify From field pre-filled |
| `search_filter_folder_preselect_test.dart` | Open search from Drafts → verify folder chip shows "Drafts" |
| `search_no_inbox_filter_bleed_test.dart` | Filter inbox to Unread → search text → verify Unread chip NOT active in search results |
| `inbox_filter_restored_after_search_test.dart` | Filter inbox to Unread → search → exit → verify Unread still active in inbox |

## Consequences

**Positive**
- `SearchEmailFilter.copyWith()` called in exactly one place — `SearchFilterNotifier.update()`
- Mobile search UI (`SearchEmailView`) reads filter state reactively via Riverpod — no `Obx` needed
- No duplicate filter state between web and mobile paths
- Suggestion chips and advanced panel always read the same notifier state — no staging step
- `FilterMessageOption` is inbox-only; no hidden JMAP filter bleed
- Pagination cursors never pollute the SSOT — the SSOT represents user intent only
- Load-more cursor logic consolidated in `SearchMoreTransformer` — no duplication between `ThreadController` and `SearchEmailController`
- New search execution variants = new `SearchFilterTransformer` subclass, no existing code changes (OCP)
- Reverse coupling between `AdvancedFilterController` and `MailboxDashBoardController` eliminated
- Clean foundation for progressive migration of remaining web `Obx` widgets to `Consumer` in a follow-up PR

**Negative**
- Three `appProviderContainer` call sites added (all in search feature boundary, documented above) — ADR-0092 exception; will be removed when controllers are migrated to `ConsumerWidget`
- `SearchEmailView` widget lifecycle changes from `GetView` to `ConsumerStatefulWidget` — requires careful regression testing
- `_memorySearchFilter` in `AdvancedFilterController` remains as a staging layer for in-progress form edits; it is still a divergence window while the form is open, but it is bounded to the form interaction lifetime and always resolved atomically on submit

## Future: ADR-0094 (web Obx → Consumer migration + draft/committed split)

With `SearchFilterNotifier` as the single source of truth established by this ADR, the next step is:
1. Migrate remaining web `Obx` widgets watching `searchController.searchEmailFilter.obs` to `Consumer` / `ref.watch(searchFilterNotifierProvider)`
2. Remove the `appProviderContainer.listen()` bridge from `SearchController` once all web consumers read the notifier directly
3. `SearchController.searchEmailFilter.obs` becomes vestigial and can be removed

### Draft/committed state split (deferred to ADR-0094)

A promising further refinement: separate the notifier into two providers:

| Provider | Scope | Purpose |
|---|---|---|
| `searchFilterProvider` (keepAlive) | Committed state | What the JMAP query actually runs with — the canonical single source of truth |
| `searchFilterDraftProvider` (autoDispose) | Panel-scoped | Editing buffer while the advanced filter panel is open; discarded on cancel, copied to committed on apply |

`AdvancedFilterController._memorySearchFilter` is already an implicit draft — this split would formalize it as a Riverpod provider. The autoDispose scope ensures the draft is automatically released when the panel closes, removing the need for manual `clearFilterSuggestion()`-style cleanup.

This is deferred because: (a) it goes beyond the scope of the 4 bug fixes this ADR targets, (b) it requires rethinking the `AdvancedFilterController` apply/cancel flow, and (c) it is best tackled together with the Obx→Consumer migration once the web path reads the notifier directly.
