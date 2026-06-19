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

## Decision

### Chosen approach: Riverpod `SearchFilterNotifier` as SSOT (mobile path now, web bridge)

Introducing `SearchFilterNotifier` — a Riverpod `@keepAlive` notifier — as the single canonical owner of `SearchEmailFilter`. The mobile search view (`SearchEmailView`) is migrated to `ConsumerStatefulWidget` to consume it reactively. The web path (`SearchController`) keeps its existing `searchEmailFilter.obs` as a mirror bridged from the notifier via one documented `appProviderContainer.listen()` call, allowing progressive migration without breaking web widgets.

This establishes a clean SSOT now, and positions web `Obx` widgets for incremental migration to `Consumer` in a follow-up PR.

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
    state = SearchEmailFilter.initial();
  }
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

### 3. Eliminate `SearchEmailController.searchEmailFilter.obs` (the mobile duplicate)

`SearchEmailController` drops:
- `searchEmailFilter.obs` — independent duplicate
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
           │         SearchFilterNotifier              │  Riverpod keepAlive — SSOT
           │         update() ← only copyWith          │
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
                                    read by ThreadController._searchEmail()

SearchEmailView (ConsumerStatefulWidget)
  ref.watch(searchFilterNotifierProvider) ← direct Riverpod reactivity (mobile)

MailboxDashBoardController.filterMessageOption  ← INBOX ONLY
  saved on search entry → cleared → restored on search exit
  NEVER passed to JMAP search queries
```

### Documented `appProviderContainer` exceptions (ADR-0092 delta)

| Call site | Type | Reason |
|---|---|---|
| `SearchController.onInit()` | `listen()` | Web Rx bridge — mirrors notifier into `searchEmailFilter.obs` for existing `Obx` widgets |
| `SearchController.updateFilterEmail()` / clear methods | `read()` | Web write path delegates to notifier |
| `SearchEmailController` write sites | `read()` | Mobile write path delegates to notifier |

All three are in the search feature boundary only and are documented here per ADR-0092 policy.

## Modified files

| File | Change |
|---|---|
| `lib/features/search/email/domain/notifier/search_filter_notifier.dart` | New — `SearchFilterNotifier` (`@Riverpod(keepAlive: true)`) |
| `lib/features/search/email/domain/notifier/search_filter_notifier.g.dart` | Generated by build_runner |
| `SearchController` | `updateFilterEmail()` / clear methods → delegate to notifier; add `appProviderContainer.listen()` bridge on init |
| `SearchEmailController` | Drop `searchEmailFilter.obs`, `_updateSimpleSearchFilter()`, `updateSimpleSearchFilter()`; 20+ call sites → `appProviderContainer.read(notifier).update()` |
| `SearchEmailView` | `GetView<SearchEmailController>` → `ConsumerStatefulWidget`; filter state reads use `ref.watch(searchFilterNotifierProvider)` |
| `ThreadController` | Remove `moreFilterCondition`; `goToSearchView()`: no mailbox pre-fill (moved to `MailboxDashBoardController`) |
| `MailboxDashBoardController` | `_filterMessageOptionBeforeSearch`; `_saveFilterMessageOptionForSearch()`; `restoreFilterMessageOption()`; `_preFillMailboxForSearch()`; remove `clearFilterMessageOption()` from `handleClearAdvancedSearchFilterEmail()` |
| `AdvancedFilterController` | `OpenAdvancedSearchViewAction`: re-sync `_memorySearchFilter` from `searchController.searchEmailFilter.value` before `initSearchFilterField()` |

## Deleted symbols

| Symbol | Reason |
|---|---|
| `SearchController.listFilterOnSuggestionForm` | Staging concept eliminated |
| `SearchController.addQuickSearchFilterToSuggestionSearchView()` | Same |
| `SearchController.deleteQuickSearchFilterFromSuggestionSearchView()` | Same |
| `SearchController.applyFilterSuggestionToSearchFilter()` | Same |
| `SearchController.clearFilterSuggestion()` | Same |
| `SearchEmailController.searchEmailFilter.obs` | Duplicate eliminated |
| `SearchEmailController._updateSimpleSearchFilter()` | Duplicate `copyWith()` logic eliminated |
| `SearchEmailController.updateSimpleSearchFilter()` | Same |
| `moreFilterCondition: getFilterCondition()` in `ThreadController` | `FilterMessageOption` no longer bleeds into search |

## Unit tests

| Test | Coverage |
|---|---|
| `search_filter_notifier_test.dart` (new) | `update()` for every field; `clear()` resets to initial; partial update preserves unspecified fields |
| `search_controller_test.dart` (extend) | `updateFilterEmail()` delegates to notifier; `clearAllFilterSearch()` / `disableAllSearchEmail()` call `notifier.clear()`; `searchEmailFilter.obs` mirrors notifier state |
| `search_email_controller_test.dart` (extend) | Filter writes go to notifier via `appProviderContainer`; `searchController.searchEmailFilter` is the state read at query time; `FilterMessageOption` saved and restored around search lifecycle |
| `thread_controller_test.dart` (new) | `_searchEmail()` never passes `moreFilterCondition`; search exit restores `filterMessageOption` |
| `search_email_filter_test.dart` (extend) | `mappingToEmailFilterCondition()` without `moreFilterCondition` never emits `notKeyword: $seen` unless `unread = true` |

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
- Clean foundation for progressive migration of remaining web `Obx` widgets to `Consumer` in a follow-up PR

**Negative**
- Three `appProviderContainer` call sites added (all in search feature boundary, documented above) — ADR-0092 exception
- `SearchEmailView` widget lifecycle changes from `GetView` to `ConsumerStatefulWidget` — requires careful testing for regressions
- `SearchEmailController` writes routed through `appProviderContainer` rather than a named dependency — coupling is implicit but scoped

## Future: ADR-0094 (web Obx → Consumer migration)

With `SearchFilterNotifier` as SSOT established by this ADR, the next step is:
1. Migrate remaining web `Obx` widgets watching `searchController.searchEmailFilter.obs` to `Consumer` / `ref.watch(searchFilterNotifierProvider)`
2. Remove the `appProviderContainer.listen()` bridge from `SearchController` once all web consumers read the notifier directly
3. `SearchController.searchEmailFilter.obs` becomes vestigial and can be removed
