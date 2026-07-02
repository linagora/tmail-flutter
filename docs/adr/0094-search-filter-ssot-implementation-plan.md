# 94. Search Filter SSOT — Implementation Plan

Date: 2026-06-24

## Status

Accepted — steps and code samples may evolve during implementation. Architectural decisions remain in [ADR-0093](./0093-search-filter-single-source-of-truth.md).

Updated: 2026-07-01 — the design collapsed to a **single `SearchFilterNotifier`** (ADR-0093 §1). `SearchFilterDraftNotifier` is dropped: the advanced form now reads/writes the one SSOT directly (live sync). This supersedes the draft-notifier parts of **Step 4** (only the mixin + `SearchFilterNotifier` remain), **Step 7** (advanced form writes committed, no draft seed / no discard-on-close), and **Step 10** (no `searchFilterDraftProvider` invalidate).

## Related ADRs

- [ADR-0093](./0093-search-filter-single-source-of-truth.md) — Search Filter SSOT + Pagination Strategy (this ADR implements it)
- [ADR-0092](./0092-upgrade-flutter-riverpod-3.md) — Riverpod 3.x, `appProviderContainer` pattern
- [ADR-0085](./0085-riverpod-state-management-for-local-settings.md) — Riverpod pilot, strategic direction

## Context

ADR-0093 defines the target architecture. This document is the concrete code-change guide: exact files, what to add, what to delete, and the build order. It is a guide, not a contract — signatures and names may shift during implementation.

### Files in scope (current state)

| File | Role today |
|---|---|
| `lib/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart` | `SearchEmailFilter` value object (has `position`) |
| `lib/features/mailbox_dashboard/presentation/controller/search_controller.dart` | web filter funnel — `searchEmailFilter.obs`, `updateFilterEmail()`, `listFilterOnSuggestionForm` |
| `lib/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart` | advanced form — `_memorySearchFilter`, `_updateMemorySearchFilter()`, `_synchronizeSearchFilter()` |
| `lib/features/search/email/presentation/search_email_controller.dart` | mobile funnel — `searchEmailFilter.obs`, `_updateSimpleSearchFilter()`, `_searchEmailAction()`, `searchMoreEmailsAction()` |
| `lib/features/thread/presentation/thread_controller.dart` | web search exec — `_searchEmail()`, `_searchMoreEmails()`, `_searchEmailFilter` getter |
| `lib/features/thread/presentation/extensions/handle_email_filter_extension.dart` | `getFilterCondition()` → `MailboxFilterBuilder.buildDefaultMailboxFilter()` |
| `lib/features/thread/domain/model/filter_message_option.dart` | `FilterMessageOption` enum + `FilterMessageOptionExtension` |
| `lib/features/thread/domain/usecases/search_email_interactor.dart` | `SearchEmailInteractor.execute(session, accountId, {limit, position, sort, filter, properties, collapseThreads, needRefreshSearchState})` |
| `lib/features/thread/domain/usecases/search_more_email_interactor.dart` | `SearchMoreEmailInteractor.execute(..., {limit, sort, position, filter, properties, collapseThreads, lastEmailId})` |
| `lib/features/search/email/domain/usecases/refresh_changes_search_email_interactor.dart` | `RefreshChangesSearchEmailInteractor.execute(..., {limit, position, sort, filter, collapseThreads, properties})` |
| `lib/features/search/email/presentation/search_email_view.dart` | `class SearchEmailView extends GetWidget<SearchEmailController>` |
| `lib/features/mailbox_dashboard/presentation/widgets/advanced_search/advanced_search_input_form.dart` | `class AdvancedSearchInputForm extends GetWidget<AdvancedFilterController>` |
| `lib/features/search/email/presentation/search_email_bindings.dart` | `Get.put(SearchEmailController(...))` |
| `lib/features/mailbox_dashboard/presentation/bindings/mailbox_dashboard_bindings.dart` | `Get.lazyPut(() => SearchEmailInteractor(...))` etc. |

Interactor signatures share these JMAP types: `sort` is `Set<Comparator>?`, `filter` is `Filter?`, `properties` is `Properties?`, `limit`/`position` are `UnsignedInt?`/`int?`.

## Decision

Implement ADR-0093 in **11 ordered PRs**. Steps 1–5 build the Riverpod layer bottom-up — **no existing controller is touched**. Steps 6–10 migrate controllers/views. Step 11 removes `position` from the model (done last, once no caller reads it). Each step is buildable, has its own tests, and ships as its own PR.

---

### Step 1 — `SearchEmailState` result model

**Create** `lib/features/search/email/domain/model/search_email_state.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:model/email/presentation_email.dart';

class SearchEmailState with EquatableMixin {
  final List<PresentationEmail> emails;
  final bool canLoadMore;

  const SearchEmailState({required this.emails, required this.canLoadMore});

  factory SearchEmailState.empty() =>
      const SearchEmailState(emails: [], canLoadMore: false);

  SearchEmailState copyWith({List<PresentationEmail>? emails, bool? canLoadMore}) =>
      SearchEmailState(
        emails: emails ?? this.emails,
        canLoadMore: canLoadMore ?? this.canLoadMore,
      );

  @override
  List<Object?> get props => [emails, canLoadMore];
}
```

This replaces the scattered `emailList` + `canSearchMore`/`canLoadMore` booleans currently held separately in `SearchEmailController` and `ThreadController`.

**Test** `test/features/search/email/domain/model/search_email_state_test.dart`: `empty()` is `[]`/`false`; `copyWith` replaces only provided fields.

---

### Step 2 — Pagination resolution (`SearchRequestSpec` + first-match strategies)

**Create** in `lib/features/search/email/domain/execution/`:

`search_execution_intent.dart`:
```dart
import 'package:jmap_dart_client/jmap/core/utc_date.dart';

sealed class SearchExecutionIntent {
  const SearchExecutionIntent();
}

class NewSearchIntent extends SearchExecutionIntent {
  const NewSearchIntent();
}

class LoadMoreIntent extends SearchExecutionIntent {
  const LoadMoreIntent({required this.currentCount, required this.lastEmailDate});
  final int currentCount;
  final UTCDate? lastEmailDate;
}

class RefreshChangesIntent extends SearchExecutionIntent {
  const RefreshChangesIntent({required this.currentCount});
  final int currentCount;   // websocket-state gating happens in the caller, before execute
}
```

`search_execution_context.dart`:
```dart
class SearchExecutionContext {
  const SearchExecutionContext({
    required this.intent,
    required this.committed,
    required this.collapseThreads,
  });
  final SearchExecutionIntent intent;
  final SearchEmailFilter committed;   // read-only snapshot of the SSOT
  final bool collapseThreads;
}
```

`search_request_spec.dart`:
```dart
class SearchRequestSpec {
  const SearchRequestSpec({required this.filter, this.position, this.limit});
  final SearchEmailFilter filter;   // transient copy of committed; cursors may be set here
  final int? position;
  final UnsignedInt? limit;

  SearchRequestSpec copyWith({SearchEmailFilter? filter, Option<int>? positionOption, UnsignedInt? limit}) =>
      SearchRequestSpec(
        filter: filter ?? this.filter,
        position: positionOption != null ? positionOption.toNullable() : position,
        limit: limit ?? this.limit,
      );

  factory SearchRequestSpec.base(SearchExecutionContext ctx) =>
      SearchRequestSpec(filter: ctx.committed, limit: ThreadConstants.defaultLimit);
}
```

`search_pagination_strategy.dart` — pagination is *select one mode*, resolved by **first-match (most-specific guard first)**, not a fold. Each strategy is **total** (it fully determines `position` + date cursors), so strategies never partially overlap and adding one cannot corrupt a context it does not match:
```dart
abstract class SearchPaginationStrategy {
  const SearchPaginationStrategy();
  bool appliesTo(SearchExecutionContext ctx);
  SearchRequestSpec apply(SearchRequestSpec spec, SearchExecutionContext ctx);
}
```

**Cursor model (post-#4651).** Date pagination uses two distinct load-more cursors, not one: `before` (cursor for `mostRecent` sort) and `after` (cursor for `oldest` sort). `startDate`/`endDate` are **user-intent date-range bounds** (set by the receive-time filter), preserved across load-more — they are *not* cursors. `mappingToEmailFilterCondition` reads `getAfterDate(startDate, after)` / `getBeforeDate(endDate, before)`. Strategies therefore write `before`/`after` only, and never touch `startDate`/`endDate`.

The four built-in strategies (`collapseThreads` forcing position-based pagination is now production behaviour, so `CollapsedThreadLoadMoreStrategy` is a baseline strategy, not a future example):

`collapsed_thread_load_more_strategy.dart` — load-more, collapsed threads (most specific, first):
```dart
class CollapsedThreadLoadMoreStrategy extends SearchPaginationStrategy {
  const CollapsedThreadLoadMoreStrategy();
  @override
  bool appliesTo(SearchExecutionContext ctx) =>
      ctx.intent is LoadMoreIntent && ctx.collapseThreads;
  @override
  SearchRequestSpec apply(SearchRequestSpec spec, SearchExecutionContext ctx) =>
      spec.copyWith(
        positionOption: Some((ctx.intent as LoadMoreIntent).currentCount),
        filter: spec.filter.copyWith(beforeOption: const None(), afterOption: const None()),
      );
}
```

`position_load_more_strategy.dart` — load-more, position-based sort:
```dart
class PositionLoadMoreStrategy extends SearchPaginationStrategy {
  const PositionLoadMoreStrategy();
  @override
  bool appliesTo(SearchExecutionContext ctx) =>
      ctx.intent is LoadMoreIntent && ctx.committed.sortOrderType.isScrollByPosition();
  @override
  SearchRequestSpec apply(SearchRequestSpec spec, SearchExecutionContext ctx) =>
      spec.copyWith(
        positionOption: Some((ctx.intent as LoadMoreIntent).currentCount),
        filter: spec.filter.copyWith(beforeOption: const None(), afterOption: const None()),
      );
}
```

`date_load_more_strategy.dart` — load-more, date-based sort (`oldest` → `after`, `mostRecent` → `before`):
```dart
class DateLoadMoreStrategy extends SearchPaginationStrategy {
  const DateLoadMoreStrategy();
  @override
  bool appliesTo(SearchExecutionContext ctx) =>
      ctx.intent is LoadMoreIntent && !ctx.committed.sortOrderType.isScrollByPosition();
  @override
  SearchRequestSpec apply(SearchRequestSpec spec, SearchExecutionContext ctx) {
    final lastDate = (ctx.intent as LoadMoreIntent).lastEmailDate;
    final isOldest = ctx.committed.sortOrderType == EmailSortOrderType.oldest;
    return spec.copyWith(
      positionOption: const None(),
      filter: spec.filter.copyWith(
        afterOption: isOldest ? optionOf(lastDate) : const None(),
        beforeOption: isOldest ? const None() : optionOf(lastDate),
      ),
    );
  }
}
```

`fresh_search_strategy.dart` — new search / refresh (catch-all, last). Clears both load-more cursors, **preserves** the `startDate`/`endDate` bounds; position restarts at 0 when paginating by position (`isScrollByPosition()` **or** `collapseThreads`):
```dart
class FreshSearchStrategy extends SearchPaginationStrategy {
  const FreshSearchStrategy();
  @override
  bool appliesTo(SearchExecutionContext ctx) => true;   // fallback
  @override
  SearchRequestSpec apply(SearchRequestSpec spec, SearchExecutionContext ctx) {
    final byPosition = ctx.committed.sortOrderType.isScrollByPosition() || ctx.collapseThreads;
    return spec.copyWith(
      filter: spec.filter.copyWith(beforeOption: const None(), afterOption: const None()),
      positionOption: byPosition ? const Some(0) : const None(),
    );
  }
}
```

> These re-implement the cursor branching today duplicated in `ThreadController._updateLoadMoreCursor()` / `resetCursorsForFreshSearch()` and `SearchEmailController.searchMoreEmailsAction()` / `_resetCursorForFreshSearch()` (both post-#4651), now in one place.

**Ordering contract (this is the whole point of first-match).** The executor (Step 5) holds an ordered list and applies the **first** strategy whose `appliesTo` is true:
```dart
static const _strategies = <SearchPaginationStrategy>[
  CollapsedThreadLoadMoreStrategy(),  // most specific guards first
  PositionLoadMoreStrategy(),
  DateLoadMoreStrategy(),
  FreshSearchStrategy(),               // catch-all, always last
];
```
Adding a strategy:
- place it **by guard specificity** — a strategy with more guard conditions goes before more general ones;
- it only affects contexts where its `appliesTo` is true; for every other context `firstWhere` skips it and the previously-matching strategy still wins → **existing strategy tests stay green**;
- the catch-all `FreshSearchStrategy` (`appliesTo => true`) must remain last.

`CollapsedThreadLoadMoreStrategy` sitting at the top is the canonical first-match proof: when `collapseThreads` is off its guard fails and the Position/Date strategies resolve exactly as if it were absent.

**Tests** `test/features/search/email/domain/execution/*_test.dart`:
- a resolver test: `_strategies.firstWhere(...).apply(...)` returns the expected mode for each `(intent, sortOrder, collapseThreads)` triple
- `CollapsedThreadLoadMoreStrategy` / `PositionLoadMoreStrategy` set `position == currentCount`, leave both date cursors null
- `DateLoadMoreStrategy` sets exactly one of `before`/`after` (oldest → `after`, mostRecent → `before`), `position == null`, never touches `startDate`/`endDate`
- `FreshSearchStrategy` clears both load-more cursors, preserves `startDate`/`endDate`, sets `position` per pagination mode (incl. `collapseThreads`)
- no strategy mutates `ctx.committed`
- **insertion safety:** adding a guarded strategy at the top does not change the resolved result for any context outside its guard

---

### Step 3 — `SearchFilterNotifier` (committed SSOT)

**Create** `lib/features/search/email/domain/notifier/search_filter_notifier.dart`. The
`update`/`set`/`clear` bodies live in the shared `SearchFilterMutation` mixin (Step 4),
so this file is just the provider shell:

```dart
part 'search_filter_notifier.g.dart';

@Riverpod(keepAlive: true)
class SearchFilterNotifier extends _$SearchFilterNotifier
    with SearchFilterMutation {
  @override
  SearchEmailFilter build() => SearchEmailFilter.initial();
}
```

Run `scripts/prebuild.sh` (build_runner) → generates `search_filter_notifier.g.dart` (provider `searchFilterProvider`). The mixin's `update(...)` exposes user intent only — it drops `positionOption` and the `before`/`after` cursors (see Step 4).

**Tests** `test/features/search/email/domain/notifier/search_filter_notifier_test.dart` (via `ProviderContainer`):
- `update(unreadOption: Some(true))` sets `unread`, leaves `before`/`startDate` untouched
- `clear()` preserves `sortOrderType`, resets all other fields to `initial()`
- `set(f)` fully replaces state

---

### Step 4 — shared mutation mixin (+ `SearchFilterDraftNotifier`, since removed)

> **Superseded (2026-07-01):** `SearchFilterDraftNotifier` was removed — a single
> `SearchFilterNotifier` is the SSOT (ADR-0093 §1). The `SearchFilterMutation` mixin and
> `clearPaginationCursors()` below still ship (the mixin now backs the one notifier); the
> draft notifier + its test do not. The two-notifier rationale in this step is historical.

`update`/`set`/`clear` are identical between the two notifiers. Rather than copy the
body (and the option signature) twice, extract a **`SearchFilterMutation` mixin**
`on $Notifier<SearchEmailFilter>` (the generated notifier base) holding `update` /
`set` / `clear`. Both notifiers `with SearchFilterMutation`; the draft adds only
`seedFrom`.

**Cursors are excluded from the notifier API (enforces the ADR-0093 invariant).**
`update` exposes only user-intent options — it omits `positionOption` **and** the
`before`/`after` cursors (it keeps the `startDate`/`endDate` range bounds). `set` and
`seedFrom` route the incoming filter through `SearchEmailFilter.clearPaginationCursors()`
so a full replacement can never seed committed/draft state with a stale cursor. Cursors
exist only on the transient `SearchRequestSpec`.

**Add** to `SearchEmailFilter`: `clearPaginationCursors()` → `copyWith(positionOption:
None, beforeOption: None, afterOption: None)` (keeps every other field).

**Create** `search_filter_mutation.dart`:

```dart
mixin SearchFilterMutation on $Notifier<SearchEmailFilter> {
  void update({/* user-intent options only: no positionOption / beforeOption / afterOption */}) {
    state = state.copyWith(/* forward those options */);
  }
  void set(SearchEmailFilter filter) => state = filter.clearPaginationCursors();
  void clear() => state = SearchEmailFilter.withSortOrder(state.sortOrderType);
}
```

**Create** `search_filter_draft_notifier.dart`:

```dart
@Riverpod(keepAlive: true)
class SearchFilterDraftNotifier extends _$SearchFilterDraftNotifier
    with SearchFilterMutation {
  @override
  SearchEmailFilter build() => SearchEmailFilter.initial();

  void seedFrom(SearchEmailFilter committed) =>
      state = committed.clearPaginationCursors();
}
```

`SearchFilterNotifier` (Step 3) collapses the same way: `extends _$SearchFilterNotifier
with SearchFilterMutation` plus `build()`. Run build_runner → `searchFilterDraftProvider`.

> The 17-option list still appears twice — once on `SearchEmailFilter.copyWith` (the
> canonical builder, also used by the strategies' transient copy) and once on the
> mixin's `update`. That second copy is irreducible: Dart has no way to reuse a
> named-parameter list, and a parameter-object would force every one of the 30+ call
> sites in Steps 6–10 to wrap its arguments. The mixin removes the *only* avoidable
> duplication — the identical method bodies across the two notifiers.

**Test** `search_filter_draft_notifier_test.dart` (containment): `seedFrom(committed)` then `update(...)` → draft contains every committed value plus the edit (`committed` ⊆ `draft`).

---

### Step 5 — `SearchEmailNotifier` (executor) + intent dispatch + bindings

**Create** `lib/features/search/email/domain/model/search_email_query_params.dart`:
```dart
class SearchEmailQueryParams {
  const SearchEmailQueryParams({
    required this.session,
    required this.accountId,
    required this.filter,
    required this.sort,
    required this.properties,
    required this.collapseThreads,
    this.limit,
    this.position,
    this.lastEmailId,            // load-more only
    this.needRefreshSearchState = false,
  });
  final Session session;
  final AccountId accountId;
  final Filter? filter;
  final Set<Comparator>? sort;
  final Properties? properties;
  final bool collapseThreads;
  final UnsignedInt? limit;
  final int? position;
  final EmailId? lastEmailId;
  final bool needRefreshSearchState;
}
```

**Add** `applyTo` to the existing `FilterMessageOptionExtension` in `lib/features/thread/domain/model/filter_message_option.dart` (SSOT-mutating mapping, used in Step 10):
```dart
SearchEmailFilter applyTo(SearchEmailFilter filter) {
  switch (this) {
    case FilterMessageOption.all:
      return filter;
    case FilterMessageOption.unread:
      return filter.copyWith(unreadOption: const Some(true));
    case FilterMessageOption.attachments:
      return filter.copyWith(hasAttachmentOption: const Some(true));
    case FilterMessageOption.starred:
      return filter.copyWith(
        hasKeywordOption: Some({...filter.hasKeyword, KeyWordIdentifier.emailFlagged.value}));
  }
}
```

**Create** `lib/features/search/email/domain/notifier/search_email_notifier.dart`:
```dart
part 'search_email_notifier.g.dart';

@Riverpod(keepAlive: true)
class SearchEmailNotifier extends _$SearchEmailNotifier {
  // First-match: most-specific guard first, catch-all last.
  // Extend by adding a strategy class + one entry — no existing strategy is modified.
  static const _strategies = <SearchPaginationStrategy>[
    PositionLoadMoreStrategy(),
    DateLoadMoreStrategy(),
    FreshSearchStrategy(),
  ];

  // GetX bridge during migration — interactors are still registered in GetX DI.
  late final SearchEmailInteractor _searchInteractor;
  late final SearchMoreEmailInteractor _searchMoreInteractor;
  late final RefreshChangesSearchEmailInteractor _refreshInteractor;

  @override
  AsyncValue<SearchEmailState> build() {
    _searchInteractor = Get.find<SearchEmailInteractor>();
    _searchMoreInteractor = Get.find<SearchMoreEmailInteractor>();
    _refreshInteractor = Get.find<RefreshChangesSearchEmailInteractor>();
    return AsyncData(SearchEmailState.empty());
  }

  Future<void> execute(
    SearchExecutionIntent intent, {
    required Session session,
    required AccountId accountId,
    required Properties properties,
    required bool collapseThreads,
    required Set<MailboxId>? trashSpamMailboxIds,
    required PresentationEmail? lastEmail,           // load-more only
  }) async {
    final committed = ref.read(searchFilterProvider);
    final ctx = SearchExecutionContext(
      intent: intent, committed: committed, collapseThreads: collapseThreads);

    var spec = SearchRequestSpec.base(ctx);
    spec = _strategies.firstWhere((s) => s.appliesTo(ctx)).apply(spec, ctx);

    final params = SearchEmailQueryParams(
      session: session,
      accountId: accountId,
      filter: spec.filter.mappingToEmailFilterCondition(trashSpamMailboxIds: trashSpamMailboxIds),
      sort: spec.filter.sortOrderType.getSortOrder().toNullable(),
      properties: properties,
      collapseThreads: collapseThreads,
      limit: intent is RefreshChangesIntent
          ? UnsignedInt((intent).currentCount)
          : spec.limit,
      position: spec.position,
      lastEmailId: lastEmail?.id,
    );

    switch (intent) {
      case NewSearchIntent():
        state = const AsyncLoading();
        final result = await _searchInteractor.execute(
          params.session, params.accountId,
          limit: params.limit, position: params.position, sort: params.sort,
          filter: params.filter, properties: params.properties,
          collapseThreads: params.collapseThreads).last;
        state = _foldSearch(result, append: false);
      case LoadMoreIntent():
        final result = await _searchMoreInteractor.execute(
          params.session, params.accountId,
          limit: params.limit, sort: params.sort, position: params.position,
          filter: params.filter, properties: params.properties,
          collapseThreads: params.collapseThreads, lastEmailId: params.lastEmailId).last;
        state = _foldSearch(result, append: true);
      case RefreshChangesIntent():
        final result = await _refreshInteractor.execute(
          params.session, params.accountId,
          limit: params.limit, position: params.position, sort: params.sort,
          filter: params.filter, collapseThreads: params.collapseThreads,
          properties: params.properties).last;
        state = _foldSearch(result, append: false);
    }
  }

  AsyncValue<SearchEmailState> _foldSearch(Either<Failure, Success> result, {required bool append}) {
    return result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (success) {
        final newEmails = _emailsOf(success);
        if (newEmails == null) return state;             // intermediate state, keep current
        final current = state.valueOrNull?.emails ?? const [];
        final emails = append ? [...current, ...newEmails] : newEmails;
        return AsyncData(SearchEmailState(emails: emails, canLoadMore: newEmails.isNotEmpty));
      },
    );
  }
}
```

> `_emailsOf(Success)` maps `SearchEmailSuccess` / `SearchMoreEmailSuccess` / `RefreshChangesSearchEmailSuccess` to their `emailList`, else `null`. The interactor already returns `PresentationEmail`; mailbox-id mapping + selection sync (`toSearchPresentationEmail`, `syncPresentationEmail`) stay in the bridge consumers (Steps 8–9) because they depend on selection state and `mapMailboxById`. Resolving interactors via `Get.find` is the temporary GetX bridge; it is replaced by Riverpod providers when interactors migrate.

**Register** the notifier is provider-based (no GetX `put` needed). Keep the existing interactor `lazyPut`s in `mailbox_dashboard_bindings.dart`.

**Tests** `search_email_notifier_test.dart` — the core anti-regression suite, with `ProviderContainer` overriding `searchFilterProvider` and mock interactors:
- `execute(NewSearchIntent())` → interactor receives `position == 0` (scroll-by-position sort) or `null`, and `filter` built with `before`/`startDate == null`, regardless of prior SSOT cursor values
- `execute(LoadMoreIntent(currentCount: 20, ...))` → `position == 20` (position sort) **or** exactly one date cursor in `filter` (date sort), never both
- `execute(RefreshChangesIntent(currentCount: 30, ...))` → `limit == 30`, `position == 0`
- **Reads committed only:** set `searchFilterProvider` = `filterA`, `execute(NewSearchIntent())` → interactor receives `filterA`'s condition
- committed SSOT unchanged after any `execute(...)`
- `LoadMoreIntent` result appends to the existing `emails`; `NewSearchIntent` replaces

---

### Step 6 — `SearchController`: mirror bridge + delegated writes

**Edit** `search_controller.dart`.

`onInit()` — add the committed-SSOT mirror so existing web `Obx` widgets keep reading `searchEmailFilter.value`:
```dart
@override
void onInit() {
  super.onInit();
  searchFocus.addListener(_onSearchFocusChanged);
  onKeyboardShortcutInit();
  appProviderContainer.listen<SearchEmailFilter>(
    searchFilterProvider,
    (_, next) => searchEmailFilter.value = next,
    fireImmediately: true,
  );
}
```

Rewire `updateFilterEmail(...)` to delegate (drop the local `copyWith`):
```dart
void updateFilterEmail({/* same Option params, minus positionOption */}) {
  appProviderContainer.read(searchFilterProvider.notifier).update(/* forward */);
}
```

**Remove:** `synchronizeSearchFilter()`, `clearSearchFilter()` (replace call sites with `searchFilterProvider.notifier.set/clear`), `listFilterOnSuggestionForm` + `addQuickSearchFilterToSuggestionSearchView()` + `deleteQuickSearchFilterFromSuggestionSearchView()` + `applyFilterSuggestionToSearchFilter()` + `clearFilterSuggestion()`. The suggestion-bar chips now call `updateFilterEmail(...)` directly (which routes to the notifier), eliminating the deferred-staging that caused #4421.

**Tests:** update `search_controller` tests — assert `updateFilterEmail` mutates `searchFilterProvider`; assert the mirror keeps `searchEmailFilter.value` in sync.

---

### Step 7 — `AdvancedFilterController` + `AdvancedSearchInputForm`

> **Superseded (2026-07-01):** the advanced form reads/writes the committed
> `searchFilterProvider` **directly** (no draft, no `seedFrom`) so field edits sync live
> to the suggestion/result chips before Apply. `AdvancedFilterController` uses a
> `_committedFilter` getter + `_updateCommittedFilter(...)` on `searchFilterProvider`;
> `applyAdvancedSearchFilter()` just `set`s the current committed filter and runs the
> search. Closing without Apply keeps the edits ("Clear filter" resets). The views stay
> `GetWidget` (no `ConsumerStatefulWidget` migration). The draft-based recipe below is
> historical.

**Edit** `advanced_search_input_form.dart` — migrate `GetWidget<AdvancedFilterController>` → `ConsumerStatefulWidget`; seed the draft on open (after the first frame, so `ref.watch` is active — see ADR-0093):
```dart
class AdvancedSearchInputForm extends ConsumerStatefulWidget { ... }

class _AdvancedSearchInputFormState extends ConsumerState<AdvancedSearchInputForm> {
  final controller = Get.find<AdvancedFilterController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchFilterDraftProvider.notifier)
         .seedFrom(ref.read(searchFilterProvider));
    });
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(searchFilterDraftProvider); // drives field values
    ...
  }
}
```

**Edit** `advanced_filter_controller.dart` — replace every `_updateMemorySearchFilter(...)` (≈20 call sites: `onHasAttachmentCheckboxChanged`, `onStarredCheckboxChanged`, `onUnreadCheckboxChanged`, `onEventsCheckboxChanged`, `onTextChanged`, `updateListEmailAddress`, `_updateDateRangeTime`, `updateSortOrder`, `selectedMailBox`, `removeDraggableEmailAddress`, …) with:
```dart
appProviderContainer.read(searchFilterDraftProvider.notifier).update(/* same Option */);
```
`applyAdvancedSearchFilter()` commits draft → SSOT:
```dart
void applyAdvancedSearchFilter() {
  final draft = appProviderContainer.read(searchFilterDraftProvider);
  appProviderContainer.read(searchFilterProvider.notifier).set(draft);
  if (draft.isApplied) {
    searchController.activateAdvancedSearch();
  } else {
    searchController.deactivateAdvancedSearch();
  }
  searchController.isAdvancedSearchViewOpen.value = false;
  _mailboxDashBoardController.handleAdvancedSearchEmail();
}
```

**Remove:** `_memorySearchFilter`, `_updateMemorySearchFilter()`, `_synchronizeSearchFilter()`, `_setUpDefaultSortOrder`'s `_memorySearchFilter` assignment, and the `_memorySearchFilter` reset in `onClose()`/`_handleClearAllFieldOfAdvancedSearch()`/`_handleStartSearchEmailAction()`. `initSearchFilterField()` reads from the draft (seeded above) instead of `_memorySearchFilter`. Cancel needs **no** cleanup — chips read the committed SSOT, not the draft.

**Tests:** update `advanced_filter_controller_test.dart` — `@visibleForTesting memorySearchFilter`/`setMemorySearchFilter` removed; assert field changes mutate `searchFilterDraftProvider`; `applyAdvancedSearchFilter` copies draft → committed.

---

### Step 8 — `SearchEmailController` + `SearchEmailView`: delegate to executor

**Edit** `search_email_controller.dart`.

Add the committed mirror in `onInit()` (same `appProviderContainer.listen` as Step 6, so the existing `searchEmailFilter.value` getters keep working during the view migration).

Replace `_searchEmailAction()` body and `searchMoreEmailsAction()` body with executor calls:
```dart
void _searchEmailAction() {
  textInputSearchFocus.unfocus();
  if (session == null || accountId == null) {
    consumeState(Stream.value(Left(SearchEmailFailure(NotFoundSessionException()))));
    return;
  }
  searchIsRunning.value = true;
  cancelSelectionMode();
  if (PlatformInfo.isWeb) { /* replaceBrowserHistory unchanged */ }
  appProviderContainer.read(searchEmailProvider.notifier).execute(
    const NewSearchIntent(),
    session: session!, accountId: accountId!,
    properties: EmailUtils.getPropertiesForEmailGetMethod(session!, accountId!),
    collapseThreads: _isCollapseThreadsEnabled,
    trashSpamMailboxIds: mailboxDashBoardController.trashSpamMailboxIds,
    lastEmail: null,
  );
}

void searchMoreEmailsAction() {
  if (!canSearchMore || session == null || accountId == null || listResultSearch.isEmpty) return;
  appProviderContainer.read(searchEmailProvider.notifier).execute(
    LoadMoreIntent(currentCount: listResultSearch.length, lastEmailDate: listResultSearch.last.receivedAt),
    session: session!, accountId: accountId!,
    properties: EmailUtils.getPropertiesForEmailGetMethod(session!, accountId!),
    collapseThreads: _isCollapseThreadsEnabled,
    trashSpamMailboxIds: mailboxDashBoardController.trashSpamMailboxIds,
    lastEmail: listResultSearch.last,
  );
}
```

**Remove:** `searchEmailFilter.obs` (replaced by the mirror), `emailReceiveTimeType.obs`, `emailSortOrderType.obs`, `_updateSimpleSearchFilter()` + the public `updateSimpleSearchFilter()` wrapper, and the inline `consumeState(_searchEmailInteractor/_searchMoreEmailInteractor.execute(...))` blocks. The chip-delete helpers (`_deleteFromSearchFilter()` etc.) become `searchFilterProvider.notifier.update(... None())` + `_searchEmailAction()`.

**Edit** `search_email_view.dart` — `GetWidget<SearchEmailController>` → `ConsumerStatefulWidget`; read results reactively:
```dart
final results = ref.watch(searchEmailProvider);
final filter  = ref.watch(searchFilterProvider);
// results.when(data: ..., loading: ..., error: ...)
```
Action methods still via `Get.find<SearchEmailController>()`. The result list applies `mapMailboxById`/selection sync here (moved from `_searchEmailsSuccess`).

**Tests:** `search_email_controller` tests assert `_searchEmailAction` triggers `searchEmailProvider.execute(NewSearchIntent())`; widget test for the `ConsumerStatefulWidget` rendering `AsyncData`/`AsyncLoading`.

---

### Step 9 — `ThreadController`: delegate to executor, bridge results (web)

**Edit** `thread_controller.dart`.

Replace `_searchEmail()` body (lines ~1184–1222) and `_searchMoreEmails()` (lines ~1273–1313) with executor calls (`NewSearchIntent` / `LoadMoreIntent`), passing `collapseThreads: _shouldCollapseThreads`. Bridge results back into GetX in `onInit()`:
```dart
appProviderContainer.listen<AsyncValue<SearchEmailState>>(
  searchEmailProvider,
  (_, next) => next.whenData((s) {
    final synced = s.emails
      .map((e) => e.toSearchPresentationEmail(mailboxDashBoardController.mapMailboxById))
      .toList()
      .syncPresentationEmail(
        mapMailboxById: mailboxDashBoardController.mapMailboxById,
        selectedMailbox: selectedMailbox,
        searchQuery: searchController.searchQuery,
        isSearchEmailRunning: isSearchActive);
    mailboxDashBoardController.updateEmailList(synced);
    canSearchMore = s.canLoadMore;
    loadingMoreStatus.value = LoadingMoreStatus.completed;
  }),
);
```

**Remove:** the inline cursor branching (`updateFilterEmail(positionOption/beforeOption...)`), the `consumeState(_searchEmailInteractor/_searchMoreEmailInteractor.execute(...))` blocks, and **critically** `moreFilterCondition: getFilterCondition()` from both calls — the inbox filter now flows through the SSOT (Step 10), fixing #4590 and #4490. `_searchEmailsSuccess` / `_searchMoreEmailsSuccess` are deleted (their logic moved into the bridge above).

**Tests:** `thread_controller_test.dart` — assert `_searchEmail` calls the executor (not the interactor directly); assert no `moreFilterCondition` leaks into the query.

---

### Step 10 — `MailboxDashBoardController`: filter-option mapping + session reset

**Edit** `mailbox_dashboard_controller.dart`.

Map `FilterMessageOption` into the SSOT before searching (so chips/form reflect it), then trigger the executor — replaces the old `moreFilterCondition` path removed in Step 9:
```dart
void applyCurrentFilterMessageOptionToSearch() {
  final resolved = filterMessageOption.value.applyTo(
    appProviderContainer.read(searchFilterProvider));
  appProviderContainer.read(searchFilterProvider.notifier).set(resolved);
}
```
On search exit, restore: `filterMessageOption.value = _filterMessageOptionBeforeSearch ?? FilterMessageOption.all`.

Session reset in `onClose()` (order matters — invalidate before any post-logout rebuild):
```dart
@override
void onClose() {
  appProviderContainer.invalidate(searchFilterProvider);
  appProviderContainer.invalidate(searchEmailProvider);
  super.onClose();
}
```

**Tests:** `mailbox_dashboard_controller_test.dart` — `applyCurrentFilterMessageOptionToSearch` maps `unread`/`attachments`/`starred` into the SSOT; logout invalidates both providers.

---

### Step 11 — Remove `position` from `SearchEmailFilter` (final cleanup)

By now no caller reads `searchEmailFilter.value.position` (Steps 8–9 removed them; the executor uses `SearchRequestSpec.position`). **Edit** `search_email_filter.dart`:
- delete the `final int? position;` field, the `this.position` constructor param, the `positionOption` parameter + line in `copyWith`, and `position` from `props`
- delete any leftover `position:` argument still passed to interactors (should be none after Steps 8–9)

This makes "cursors never in the SSOT" type-enforced.

**Test:** update `search_email_filter_test.dart` — equality ignores pagination; `copyWith` has no `positionOption`. Confirm the whole suite is green (the Step 5 executor tests already prove position is computed correctly without the field).

---

## Shipping strategy

This PR contains only the ADR documents. Each of the 11 steps ships as its own PR:

- **Steps 1–5** (model + pagination strategies + notifiers + executor): no existing controller touched. Self-contained — new files + tests only. The ADR-0093 invariants are locked down here, before any controller migration.
- **Steps 6–10**: one controller (or one controller + its view) per PR. Regression scope limited to that unit.
- **Step 11**: pure model cleanup, mechanical.

Reviewers reference the corresponding step for the expected change and regression scope.

## Consequences

**Positive**
- Each step is a buildable, testable increment — no big-bang migration
- Steps 1–5 build the layer and lock the invariants with explicit tests before any controller is touched
- `position` removed last, when no caller depends on it — no transitional position-shims in controllers
- Future pagination rules (e.g. `collapseThreads`) = a new `SearchPaginationStrategy` + one ordered entry; first-match means it only affects contexts its guard matches, so existing strategies and their tests are untouched (OCP)
- Bug fixes (#4421, #4590, #4490) fall out of the structural cleanup, not as patches

**Negative**
- Steps 7 and 8 migrate two views to `ConsumerStatefulWidget` — requires regression testing on web and mobile
- The executor resolves interactors and `mapMailboxById` via `Get.find`/bridge consumers during migration — a temporary GetX coupling removed when those controllers migrate
- Strategy order is a contract (most-specific guard first, catch-all last) — documented where `_strategies` is declared; first-match makes insertion safe (a new strategy never alters contexts outside its guard)
- Step 10 order matters: `invalidate` must precede post-logout rebuilds
- the 17-option list is declared twice — on `SearchEmailFilter.copyWith` and the `SearchFilterMutation` mixin's `update`; irreducible without forcing a parameter-object on every call site. The mixin removes the avoidable duplication (identical bodies across the two notifiers)
