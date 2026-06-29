# 93. Search Filter — Single Source of Truth + Pagination Strategy

Date: 2026-06-19

## Status

Proposed

## Related ADRs

- [ADR-0085](./0085-riverpod-state-management-for-local-settings.md) — Riverpod pilot, `appProviderContainer` pattern
- [ADR-0092](./0092-upgrade-flutter-riverpod-3.md) — Riverpod 3.x, `keepAlive` rule, frozen `appProviderContainer`
- [Implementation Plan](./0094-search-filter-ssot-implementation-plan.md) — step-by-step guide for implementing this ADR (Draft, may evolve)

## Context

### Problem 1 — Dual write funnels, no shared state (bugs #4421, #4590, #4490)

`SearchEmailFilter` state lives in two independent, unconnected objects: `SearchController.searchEmailFilter.obs` (written by 10+ web call sites) and `SearchEmailController.searchEmailFilter.obs` (written by 20+ mobile call sites via `_updateSimpleSearchFilter()`). Neither is aware of the other. A staging layer (`listFilterOnSuggestionForm`) defers chip selections until submit, so the advanced filter panel never sees pending chip state. `FilterMessageOption` (unread/starred/attachments) is silently ANDed into JMAP queries via `moreFilterCondition: getFilterCondition()` — the result differs from what the chip UI shows.

| Bug | Root cause |
|---|---|
| #4421 | `listFilterOnSuggestionForm` not merged into filter until submit; mobile `SearchEmailController` starts fresh on every entry |
| #4590 | `ThreadController._searchEmail()` ANDs `filterMessageOption` as `moreFilterCondition`; chip bar reads `SearchEmailFilter.unread` (always `false`) → chip deselected, results still filtered |
| #4490 | `filterMessageOption` reset to `all` by unrelated code paths; cached results still filtered while chip shows deselected |

### Problem 2 — Pagination mixed with user intent

Both `_searchEmail()` and `_searchMoreEmails()` write `position`/`before`/`startDate` directly into the same observable as user intent (from, to, mailbox, etc.). The same `isScrollByPosition()` cursor branching logic is duplicated across `ThreadController` and `SearchEmailController`. This makes OCP impossible: every new search execution variant requires modifying existing controller code to reset/advance cursors.

### Problem 3 — One filter object, two conflicting lifetimes

The same `SearchEmailFilter` is used both as the *in-progress edit buffer* (suggestion dropdown, advanced form) and the *committed query state* (result chips, JMAP request). The advanced panel's staging buffer (`_memorySearchFilter`) is a third, disconnected copy. There is no clear "draft vs committed" boundary, so cancelling a panel edit, removing a chip, and submitting a search all mutate overlapping state with ad-hoc cleanup.

## Decision

### 1. Two notifiers — committed SSOT + draft staging

Filter state is split by **lifetime**, not by platform:

| Notifier | Owns UI | Role | Riverpod |
|---|---|---|---|
| `SearchFilterNotifier` | result-screen filter chips | **committed** intent — builds the JMAP query | `keepAlive` |
| `SearchFilterDraftNotifier` | suggestion dropdown + advanced filter form | **staging** — in-progress edits before apply | `keepAlive` (session-scoped) |

```dart
@Riverpod(keepAlive: true)
class SearchFilterNotifier extends _$SearchFilterNotifier {
  @override
  SearchEmailFilter build() => SearchEmailFilter.initial();
  void update({...})            // partial field update
  void set(SearchEmailFilter f) // commit from draft / apply form
  void clear()                  // reset, preserve sortOrderType
}
```

`SearchFilterDraftNotifier` has the same interface plus `seedFrom(SearchEmailFilter)`.

**Containment invariant (temporal-staging model):**

```
search ⊆ draft                  while an input surface is active
commit:   draft ──► search       one-directional, at Apply / submit
chip ops: write committed directly; draft re-seeds (draft = search) on next surface open
executor: reads SearchFilter only — never the draft
```

The draft is the live edit buffer (committed values + not-yet-applied edits); the committed `SearchFilter` is the snapshot that was last applied. `search ⊆ draft` holds *while a surface is open* (the surface seeds the draft on entry); result-screen chips are a separate path that writes committed directly, and the draft is re-seeded on the next surface open. The surfaces and the chips are never the source of truth simultaneously, so the staleness window is invisible. This is the standard "form draft vs submitted" pattern.

**Why temporal-staging, not field-projection.** The JMAP query needs `subject`, `hasKeyword`, `notKeyword` — these must live in the committed `SearchFilter` that builds the query. The difference between draft and committed is therefore *commit state*, not a subset of fields.

`SearchController.searchEmailFilter.obs` becomes a passive mirror of the committed `SearchFilterNotifier` via one `appProviderContainer.listen()` bridge in `SearchController.onInit()`. All existing web `Obx` chip widgets keep working unchanged.

**Lifecycle:**

| Event | Action |
|---|---|
| Enter search | `search = initial(sortOrder: current)` |
| Open input surface | `draft.seedFrom(search)` — draft starts at committed, keeps `search ⊆ draft` |
| Edit field in surface | `draft.update(...)` |
| Apply / submit | `search.set(draft)` → execute |
| Chip remove / toggle | `search.update(...)` → execute (draft re-seeds on next surface open) |
| Cancel surface | drop draft — no manual revert; chips untouched (they read committed) |
| Disable search | `draft.clear()` + `search.clear()` |
| Logout | `invalidate(draft)` + `invalidate(search)` |

Because chips read the committed `SearchFilter` (not the draft), editing the advanced form never makes the background chips flicker, and Cancel needs no cleanup.

### 2. `SearchEmailFilter` — pagination position removed

`position` is removed from `SearchEmailFilter` entirely (field, constructor, `copyWith`, `props`). It is never user intent — it is always `0` (fresh search) or the current result count (load-more). Keeping it in the SSOT violated the "user intent only" invariant at the type level.

`before` / `startDate` remain on the model because `mappingToEmailFilterCondition()` reads them to build the JMAP query. They are **set transiently by the executor on a local filter copy** for the request, and are never written to the committed SSOT — see Invariants. Fully extracting them into `SearchEmailQueryParams` (so the SSOT carries zero cursor fields) is deferred follow-up work, gated on refactoring `mappingToEmailFilterCondition()`.

### 3. `SearchEmailNotifier` — centralized executor (intent + query params)

All search execution is centralized in `SearchEmailNotifier`. Callers declare **what** they want via a sealed `SearchExecutionIntent`. The executor reads the committed SSOT, resolves cursors/position for the request, builds `SearchEmailQueryParams`, and dispatches to the matching interactor.

```dart
sealed class SearchExecutionIntent {}
class NewSearchIntent      extends SearchExecutionIntent {}
class LoadMoreIntent       extends SearchExecutionIntent {
  const LoadMoreIntent({required this.currentCount, required this.lastEmailDate});
  final int currentCount;
  final UTCDate? lastEmailDate;
}
class RefreshChangesIntent extends SearchExecutionIntent {
  const RefreshChangesIntent({required this.currentCount});
  final int currentCount;   // websocket-state gating happens in the caller, before execute
}
```

`SearchEmailQueryParams` is a parameter object holding every interactor argument, built once per execution (field list mirrors the three interactor signatures):

```dart
class SearchEmailQueryParams {
  final Session session;
  final AccountId accountId;
  final Filter? filter;
  final Set<Comparator>? sort;
  final Properties? properties;
  final bool collapseThreads;
  final UnsignedInt? limit;
  final int? position;
  final EmailId? lastEmailId;          // load-more only
  final bool needRefreshSearchState;   // search interactor only
}
```

**Pagination resolution (OCP for pre-search rules).** Two orthogonal axes of variation exist:

- *Which search* — `new` / `loadMore` / `refresh`. A closed set bounded by JMAP search semantics → captured by `SearchExecutionIntent` (a `switch` picking the interactor).
- *How the request paginates* — position vs date cursor, and future context rules (e.g. "when `collapseThreads` is on, paginate by `position` instead of `receivedAt`"). This axis is **open** and grows over time.

Pagination is fundamentally *select one mode*, not *stack mutations* — so it is modelled as a **first-match strategy resolver** (most-specific guard first), not a fold pipeline. Each strategy is **total** (it fully determines `position` + date cursors) and operates on a **transient request spec**, never the SSOT and never the persisted `SearchEmailFilter`.

```dart
class SearchExecutionContext {
  final SearchExecutionIntent intent;
  final SearchEmailFilter committed;
  final bool collapseThreads;
}

class SearchRequestSpec {         // transient — a copy of committed + pagination, built per execution
  final SearchEmailFilter filter; // cursors may be set here; never written back to SSOT
  final int? position;
  final UnsignedInt? limit;
  SearchRequestSpec copyWith({...});
}

abstract class SearchPaginationStrategy {
  bool appliesTo(SearchExecutionContext ctx);
  SearchRequestSpec apply(SearchRequestSpec spec, SearchExecutionContext ctx);
}
```

```dart
@riverpod
class SearchEmailNotifier extends _$SearchEmailNotifier {
  // First-match: most-specific guard first, catch-all last.
  // Extend by adding a class + one ordered entry — no existing strategy is modified.
  static const _strategies = <SearchPaginationStrategy>[
    PositionLoadMoreStrategy(),   // loadMore + position-sort → position = currentCount
    DateLoadMoreStrategy(),       // loadMore + date-sort → before XOR startDate
    FreshSearchStrategy(),        // new/refresh (catch-all) → clear cursors, position per sortOrder
  ];

  @override
  AsyncValue<SearchEmailState> build() => const AsyncData(SearchEmailState.empty());

  Future<void> execute(SearchExecutionIntent intent) async {
    final ctx = SearchExecutionContext(intent: intent,
        committed: ref.read(searchFilterNotifierProvider), ...); // committed only, never draft
    var spec = SearchRequestSpec.base(ctx);                      // filter = copy of committed
    spec = _strategies.firstWhere((s) => s.appliesTo(ctx)).apply(spec, ctx);
    final params = SearchEmailQueryParams.from(spec, ctx);       // filter→condition mapping here
    switch (intent) {
      case NewSearchIntent():      /* _searchEmailInteractor.execute(params) */
      case LoadMoreIntent():       /* _searchMoreEmailInteractor.execute(params) */
      case RefreshChangesIntent(): /* _refreshChangesSearchEmailInteractor.execute(params) */
    }
  }
}
```

**Why first-match, not a fold.** A fold makes order mean "precedence over overlapping writes," which forces every contributor to reason about which fields other strategies touch. First-match over *total* strategies makes the contract trivial: each strategy fully owns the outcome for the contexts it matches, and only those. Adding a strategy cannot change the result for any context outside its guard, regardless of where it sits — `firstWhere` simply skips it there.

**Adding a rule is closed-for-modification.** Example — `collapseThreads` forces position-based load-more even on a date sort. Add at the **top** (most specific):

```dart
class CollapsedThreadLoadMoreStrategy implements SearchPaginationStrategy {
  const CollapsedThreadLoadMoreStrategy();
  @override
  bool appliesTo(SearchExecutionContext ctx) =>
      ctx.intent is LoadMoreIntent && ctx.collapseThreads;
  @override
  SearchRequestSpec apply(SearchRequestSpec spec, SearchExecutionContext ctx) =>
      spec.copyWith(
        positionOption: Some((ctx.intent as LoadMoreIntent).currentCount),
        filter: spec.filter.copyWith(beforeOption: const None(), startDateOption: const None()),
      );
}
```

Shipping it: add the class + one ordered entry. When `collapseThreads` is off the guard fails and the existing `PositionLoadMoreStrategy` / `DateLoadMoreStrategy` resolve exactly as before — existing strategy tests stay green; the new strategy gets its own isolated test. The catch-all `FreshSearchStrategy` (`appliesTo => true`) must remain last.

**`FilterMessageOption` mapping is a different category — SSOT-mutating, not pagination.** It must persist so chips/form reflect it, so it is applied to the committed SSOT *before* `execute` (via `notifier.set(...)` at the inbox call site), then restored on search exit via `restoreFilterMessageOption()`. It is not a `SearchPaginationStrategy`. If genuinely *additive* (independently stacking) request rules ever appear that are not pagination, a separate fold stage can be introduced then — out of scope here.

Location: `lib/features/search/email/domain/notifier/search_email_notifier.dart`, strategies + intent + spec in `lib/features/search/email/domain/execution/`

## Invariants

- `SearchEmailFilter.copyWith()` on the committed/draft state is called only inside `SearchFilterNotifier` and `SearchFilterDraftNotifier`. Pagination strategies call `copyWith` only on the transient `SearchRequestSpec.filter` copy. No controller or widget calls it directly.
- `SearchEmailFilter.position` does not exist — pagination position cannot be written to the SSOT (type-enforced). `position` lives only on the transient `SearchRequestSpec`, set by the resolved strategy.
- Pagination cursors (`before`, `startDate`) are never written to the committed SSOT. The resolved strategy sets them on the transient `SearchRequestSpec.filter` copy only.
- The committed `SearchFilterNotifier` is the only state read by `SearchEmailNotifier`. The draft (`SearchFilterDraftNotifier`) is never read by the executor.
- `search ⊆ draft` while an input surface is active; chip operations write committed directly and the draft re-seeds on next open; commit is one-directional `draft → search`.
- New "which search" variant → new `SearchExecutionIntent` subclass + `switch` branch. New pagination rule → new `SearchPaginationStrategy` + one ordered entry (first-match: only its matching contexts are affected). Neither modifies an existing intent, strategy, controller, or the filter model (OCP on both axes).

## Architecture

```
INPUT SURFACES (DRAFT)                         COMMITTED (SEARCH)              EXECUTOR
suggestion dropdown + advanced form            result-screen chips            SearchEmailNotifier
        │ open → draft.seedFrom(search)                                       reads SEARCH only
        │ edit → draft.update()                                              ┌────────────────────┐
        ▼                                                                    │ execute(intent):   │
 SearchFilterDraftNotifier ──Apply: search.set(draft)──► SearchFilterNotifier│  ctx=read(search)  │
 (keepAlive, session)                                    (keepAlive)         │  spec=base(ctx)    │
        ▲                                                  │   ▲             │  firstWhere(_strat)│
        │ seed                                chips read   │   │ chip op     │  switch → interactor│
        └──────────────────────────────────────────────── │   │ search.update└────────┬───────────┘
                                              web bridge:  │   └─────────────         ▼
                                  SearchController.obs ◄───┘            AsyncValue<SearchEmailState>
                                  (Obx web widgets)                      ├ Mobile: SearchEmailView (ref.watch)
                                                                         └ Web: ThreadController (listen → obs)
```

## Patterns

Shared vocabulary for the executor design. Patterns are named to describe the solution, not chosen as a goal.

| Element | Pattern | Why |
|---|---|---|
| `SearchFilterNotifier` / `SearchFilterDraftNotifier` | **Single Source of Truth** + form *draft vs submitted* | One owner per lifetime; chips read committed, surfaces edit draft |
| `SearchEmailQueryParams` | **Parameter Object** | Collapses the long interactor argument list into one value |
| `SearchExecutionIntent` (sealed) + `switch` | tagged-union dispatch | Closed set of "which search"; exhaustive `switch` picks the interactor |
| `SearchPaginationStrategy` | **Strategy** | Interchangeable pagination algorithms behind one interface |
| `firstWhere((s) => s.appliesTo(ctx))` | **Chain of Responsibility** | Each strategy decides if it handles the context; first match wins |

**Not Composite.** Pagination is *select one mode*, a part-whole-free decision — Chain of Responsibility, not a tree. Forcing Composite here would be pattern-driven design.

**Composite is the sanctioned extension seam.** Because `SearchPaginationStrategy` is a single uniform interface, a composite *is-a* strategy and can be introduced later with **no change to existing leaves**, only when grouping strategies into a hierarchy carries real value (e.g. a "load-more" family vs a "fresh" family):

```dart
class CompositePaginationStrategy implements SearchPaginationStrategy {
  const CompositePaginationStrategy(this.children);
  final List<SearchPaginationStrategy> children;
  @override
  bool appliesTo(SearchExecutionContext ctx) => children.any((c) => c.appliesTo(ctx));
  @override
  SearchRequestSpec apply(SearchRequestSpec spec, SearchExecutionContext ctx) =>
      children.firstWhere((c) => c.appliesTo(ctx)).apply(spec, ctx);
}
```

Until such a hierarchy is warranted, the flat `_strategies` list is preferred (YAGNI). The interface keeps the door open.

## Riverpod-First Direction

GetX is the legacy layer. New search logic is written as Riverpod providers. GetX controllers bridge via `appProviderContainer` during migration and are eventually retired.

**Compatibility with the `ProviderScope` migration (ADR-0092).** This ADR does not entrench the bridge — it consolidates 30+ scattered `searchEmailFilter.obs` write sites into a small, enumerable set of `appProviderContainer` bridge points. Because `UncontrolledProviderScope` (ADR-0092) already shares `appProviderContainer` with the widget tree, every bridge call is a one-line swap to `ref.read/watch` when its owning controller becomes a `ConsumerWidget`:

| Bridge site | Eliminated when |
|---|---|
| `SearchController` mirror listen | web chip widgets migrate to `Consumer` |
| `AdvancedFilterController` draft reads/writes | controller becomes a thin shell |
| `SearchEmailController` executor calls | `SearchEmailView` is `ConsumerStatefulWidget` |
| `ThreadController` executor + result bridge | thread view migrates |
| `MailboxDashBoardController` invalidate on logout | dashboard migrates |

When all are gone, `appProviderContainer` is deleted per ADR-0092.

`Session` and `AccountId` are passed inside `SearchEmailQueryParams` in this PR. Future improvement: expose via `SessionProvider` (Riverpod).

## Alternatives considered

| Alternative | Why rejected |
|---|---|
| **Single notifier** for both UI surfaces and the query | Re-creates the divergence the SSOT removes — chips flicker during form edits, Cancel needs manual revert. Two lifetimes (draft/committed) keep them isolated. |
| **Field-projection** draft ⊋ committed (committed holds fewer *fields*) | The JMAP query needs `subject`/`hasKeyword`/`notKeyword`; they must live in committed. The draft/committed difference is *commit state*, not a field subset → temporal-staging. |
| **`SearchFilterTransformer` on the filter model** | Writes pagination cursors back into `SearchEmailFilter`, leaking pagination into "user intent" — the opposite of removing `position`. |
| **No pipeline; inline `switch` in the executor** | Closed for the 3 intents, but the *pagination-rule* axis is open (e.g. `collapseThreads`); inlining forces editing the executor for every new rule (OCP violation). |
| **Fold pipeline of request transformers** | Order means "precedence over overlapping writes" — adding a rule forces reasoning about which fields others touch. First-match over total strategies removes that coupling. |

## Consequences

**Positive**
- `copyWith()` called only in the two notifiers — no diverging filter state between web and mobile
- Draft vs committed boundary is explicit — chips never flicker during form edits; Cancel is a no-op
- `position` removed from the model — "user intent only" invariant enforced at the type level
- Pagination cursors never pollute the committed SSOT — they live on the transient `SearchRequestSpec`
- `FilterMessageOption` is inbox-only; no hidden filter bleed into JMAP queries
- OCP on both axes: new "which search" = new `SearchExecutionIntent`; new pagination rule (e.g. `collapseThreads`) = new `SearchPaginationStrategy` + one ordered entry — first-match means insertion never alters contexts outside its guard, so existing code and tests stay green
- `SearchEmailQueryParams` removes the long interactor argument list and centralizes request construction
- `_updateMemorySearchFilter`, `_memorySearchFilter`, `_synchronizeSearchFilter`, `listFilterOnSuggestionForm` eliminated

**Negative**
- `SearchController.searchEmailFilter.obs` bridge persists until web chip widgets migrate to `Consumer`
- `ThreadController` still bridges result state via `appProviderContainer.listen()` until the thread view migrates
- `SearchFilterDraftNotifier` is `keepAlive` (session-scoped), so search-disable must explicitly `clear()` both notifiers — missing cleanup leaves stale draft
- `Session`/`AccountId` inside `SearchEmailQueryParams` is temporary — addressed when `SessionProvider` is introduced
