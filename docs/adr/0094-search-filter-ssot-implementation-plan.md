# 94. Search Filter SSOT — Implementation Plan

Date: 2026-06-24

## Status

Draft — steps and code samples may evolve during implementation. Architectural decisions remain in [ADR-0093](./0093-search-filter-single-source-of-truth.md).

## Related ADRs

- [ADR-0093](./0093-search-filter-single-source-of-truth.md) — Search Filter SSOT + Pipeline Transformer (this ADR implements it)
- [ADR-0092](./0092-upgrade-flutter-riverpod-3.md) — Riverpod 3.x, `appProviderContainer` pattern
- [ADR-0085](./0085-riverpod-state-management-for-local-settings.md) — Riverpod pilot, strategic direction

## Context

ADR-0093 defines four architectural decisions:
1. `SearchFilterNotifier` — committed filter SSOT (Riverpod keepAlive)
2. `SearchFilterPipeline` + transformers — execution-time logic
3. `SearchEmailNotifier` — centralized search executor (Riverpod)
4. `SearchFilterDraftNotifier` — advanced filter panel draft state (Riverpod autoDispose)

This ADR records the concrete implementation approach: which files to create, which existing methods to remove, and how to wire the components together. It is a guide, not a contract — specific method signatures and file names may shift as implementation reveals details not visible at design time.

## Decision

Implement ADR-0093 in 10 ordered steps. Steps 1–4 build the Riverpod layer bottom-up. Steps 5–8 migrate existing controllers and views. Steps 9–10 fix the four bugs.

### Step 1 — `SearchEmailState` result model

New model replacing the ad-hoc email list + `canSearchMore` bool scattered across controllers.

```dart
class SearchEmailState {
  final List<PresentationEmail> emails;
  final bool canLoadMore;
  const SearchEmailState({required this.emails, required this.canLoadMore});
  factory SearchEmailState.empty() =>
      const SearchEmailState(emails: [], canLoadMore: false);
}
```

Location: `lib/features/search/email/domain/model/search_email_state.dart`

### Step 2 — `SearchFilterNotifier` + generated provider

Create `lib/features/search/email/domain/notifier/search_filter_notifier.dart`:

```dart
@Riverpod(keepAlive: true)
class SearchFilterNotifier extends _$SearchFilterNotifier {
  @override
  SearchEmailFilter build() => SearchEmailFilter.initial();
  void update({...}) { state = state.copyWith(...); }
  void set(SearchEmailFilter f) { state = f; }
  void clear() { state = SearchEmailFilter.withSortOrder(state.sortOrderType); }
}
```

Run `build_runner` to generate `search_filter_notifier.g.dart`.

### Step 3 — `SearchFilterDraftNotifier` + `AdvancedFilterView` migration

Create `lib/features/search/email/domain/notifier/search_filter_draft_notifier.dart` — same interface as `SearchFilterNotifier` but `@riverpod` (autoDispose, scoped to panel lifetime). Run `build_runner`.

**Seeding happens in the view, not the controller.** `SearchFilterDraftNotifier` is `autoDispose`: if the controller seeds the draft before the view mounts (before any `ref.watch()` listener exists), the provider auto-disposes immediately and the seed is lost. Moving the seed to `AdvancedFilterView.initState()` guarantees the listener is active first.

Migrate `AdvancedFilterView` to `ConsumerStatefulWidget`:
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final committed = ref.read(searchFilterNotifierProvider);
    ref.read(searchFilterDraftNotifierProvider.notifier).set(committed);
  });
}

// in build():
final draft = ref.watch(searchFilterDraftNotifierProvider);
```

Replace every `_updateMemorySearchFilter(...)` in `AdvancedFilterController` with:
```dart
appProviderContainer.read(searchFilterDraftNotifierProvider.notifier).update(...);
```

On Apply (`applyAdvancedSearchFilter()`):
```dart
final draft = appProviderContainer.read(searchFilterDraftNotifierProvider);
appProviderContainer.read(searchFilterNotifierProvider.notifier).set(draft);
```

On Cancel: close panel — `autoDispose` clears draft automatically, no cleanup needed.

**Remove:** `_memorySearchFilter`, `_updateMemorySearchFilter()`, `_synchronizeSearchFilter()`.

### Step 4 — `SearchEmailNotifier` (centralized executor)

Create `lib/features/search/email/domain/notifier/search_email_notifier.dart`:

```dart
@riverpod
class SearchEmailNotifier extends _$SearchEmailNotifier {
  @override
  AsyncValue<SearchEmailState> build() => const AsyncData(SearchEmailState.empty());

  Future<void> search({
    required Session session,
    required AccountId accountId,
    List<SearchFilterTransformer> intentTransformers = const [],
  }) async {
    state = const AsyncLoading();
    final base = ref.read(searchFilterNotifierProvider);
    final resolved = SearchFilterPipeline([
      ...intentTransformers,
      const ResetPaginationTransformer(),
    ]).apply(base);
    // call SearchEmailInteractor, emit AsyncData(SearchEmailState(...))
  }

  Future<void> loadMore({
    required Session session,
    required AccountId accountId,
    required int currentCount,
    UTCDate? lastEmailDate,
  }) async {
    final base = ref.read(searchFilterNotifierProvider);
    final resolved = SearchFilterPipeline([
      SearchMoreTransformer(currentCount: currentCount, lastEmailDate: lastEmailDate),
    ]).apply(base);
    // call SearchMoreEmailInteractor, append to current state
  }
}
```

Run `build_runner` to generate `search_email_notifier.g.dart`.

`search()` always appends `ResetPaginationTransformer` internally. `loadMore()` always uses `SearchMoreTransformer`. No caller ever specifies these.

### Step 5 — `SearchController` — mirror bridge + delegated writes

In `SearchController.onInit()`, subscribe to the committed SSOT:
```dart
appProviderContainer.listen<SearchEmailFilter>(
  searchFilterNotifierProvider,
  (_, next) => searchEmailFilter.value = next,
  fireImmediately: true,
);
```

`updateFilterEmail()` delegates to `searchFilterNotifierProvider.notifier.update(...)`.

**Remove:** `synchronizeSearchFilter()`, `clearSearchFilter()`, `listFilterOnSuggestionForm` and all related helpers (`addQuickSearchFilter...`, `applyFilterSuggestion...`, `clearFilterSuggestion`). Chip taps now call `updateFilterEmail()` directly, which routes to the notifier.

### Step 6 — `SearchEmailController` — drop duplicate obs, delegate to executor

**Remove:** `searchEmailFilter.obs`, `emailReceiveTimeType.obs`, `emailSortOrderType.obs`, `_updateSimpleSearchFilter()`.

Add mirror subscription in `onInit()`:
```dart
appProviderContainer.listen<SearchEmailFilter>(
  searchFilterNotifierProvider,
  (_, next) => searchEmailFilter.value = next,
  fireImmediately: true,
);
```

Replace `_searchEmailAction()` and `searchMoreEmailsAction()` with executor calls:
```dart
appProviderContainer.read(searchEmailNotifierProvider.notifier)
    .search(session: session!, accountId: accountId!);

appProviderContainer.read(searchEmailNotifierProvider.notifier)
    .loadMore(session: session!, accountId: accountId!,
              currentCount: listResultSearch.length, lastEmailDate: lastEmail?.receivedAt);
```

### Step 7 — `ThreadController` — delegate to executor, bridge results

Replace `_searchEmail()` and `_searchMoreEmails()` bodies with executor calls (same pattern as Step 6). Bridge results back to GetX:
```dart
appProviderContainer.listen<AsyncValue<SearchEmailState>>(
  searchEmailNotifierProvider,
  (_, next) => next.whenData((s) {
    mailboxDashBoardController.emailsInCurrentMailbox.assignAll(s.emails);
    canSearchMore = s.canLoadMore;
  }),
);
```

### Step 8 — `SearchEmailView` → `ConsumerStatefulWidget`

Migrate from `GetView<SearchEmailController>` to `ConsumerStatefulWidget`:
```dart
final filter  = ref.watch(searchFilterNotifierProvider);
final results = ref.watch(searchEmailNotifierProvider);
```

Action methods still retrieved via `Get.find<SearchEmailController>()` until the controller is fully replaced.

### Step 9 — `FilterMessageOption` isolation (fixes #4590, #4490)

Remove `moreFilterCondition: getFilterCondition()` from `ThreadController._searchEmail()` and `_searchMoreEmails()`.

In `MailboxDashBoardController.applyCurrentFilterMessageOptionToSearch()`:
```dart
// 1. Map inbox filter → SSOT so form/chips reflect it:
final resolved = SearchFilterPipeline([
  FilterMessageOptionTransformer(filterMessageOption.value),
]).apply(searchController.searchEmailFilter.value);
appProviderContainer.read(searchFilterNotifierProvider.notifier).set(resolved);

// 2. Trigger search — executor reads the already-updated SSOT:
appProviderContainer.read(searchEmailNotifierProvider.notifier)
    .search(session: session!, accountId: accountId!);
```

On search exit (`restoreFilterMessageOption()`): restore `filterMessageOption.value = _filterMessageOptionBeforeSearch`.

### Step 10 — Session reset on logout

```dart
// MailboxDashBoardController.onClose()
appProviderContainer.invalidate(searchFilterNotifierProvider);
// SearchEmailNotifier and SearchFilterDraftNotifier are autoDispose — no invalidation needed
```

## Consequences

**Positive**
- Each step produces a buildable, testable increment — no big-bang migration
- Steps 1–4 can be reviewed and tested independently before touching existing controllers
- Steps 5–8 are mechanical rewrites guided by the invariants in ADR-0093; regressions are caught by existing unit tests
- Steps 9–10 fix the four bugs as a natural outcome of the structural cleanup, not as patches

**Negative**
- Steps 3 and 8 migrate two views to `ConsumerStatefulWidget` — requires regression testing on both platforms
- Step 10 order matters: `invalidate(searchFilterNotifierProvider)` must fire before any post-logout rebuild that might re-subscribe
- Implementation details not covered here (e.g., exact interactor call signatures, error state handling) must follow existing patterns in the codebase
