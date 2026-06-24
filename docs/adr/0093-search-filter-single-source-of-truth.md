# 93. Search Filter — Single Source of Truth + Pipeline Transformer

Date: 2026-06-19

## Status

Proposed

## Related ADRs

- [ADR-0085](./0085-riverpod-state-management-for-local-settings.md) — Riverpod pilot, `appProviderContainer` pattern
- [ADR-0092](./0092-upgrade-flutter-riverpod-3.md) — Riverpod 3.x, `keepAlive` rule, frozen `appProviderContainer`
- [Implementation Plan](./0094-search-filter-ssot-implementation-plan.md) — step-by-step guide for implementing this ADR (Draft, may evolve)

## Context

### Problem 1 — Dual write funnels, no shared state (bugs #4421, #4612, #4590, #4490)

`SearchEmailFilter` state lives in two independent, unconnected objects: `SearchController.searchEmailFilter.obs` (written by 10+ web call sites) and `SearchEmailController.searchEmailFilter.obs` (written by 20+ mobile call sites via `_updateSimpleSearchFilter()`). Neither is aware of the other. A staging layer (`listFilterOnSuggestionForm`) defers chip selections until submit, so the advanced filter panel never sees pending chip state. `FilterMessageOption` (unread/starred/attachments) is silently ANDed into JMAP queries via `moreFilterCondition: getFilterCondition()` — the result differs from what the chip UI shows.

| Bug | Root cause |
|---|---|
| #4421 | `listFilterOnSuggestionForm` not merged into filter until submit; mobile `SearchEmailController` starts fresh on every entry |
| #4612 | `SearchEmailFilter.mailbox` always initializes to `null`; current folder context never seeded on search entry |
| #4590 | `ThreadController._searchEmail()` ANDs `filterMessageOption` as `moreFilterCondition`; chip bar reads `SearchEmailFilter.unread` (always `false`) → chip deselected, results still filtered |
| #4490 | `filterMessageOption` reset to `all` by unrelated code paths; cached results still filtered while chip shows deselected |

### Problem 2 — Pagination mixed with user intent

Both `_searchEmail()` and `_searchMoreEmails()` write `position`/`before`/`startDate` directly into the same observable as user intent (from, to, mailbox, etc.). The same `isScrollByPosition()` cursor branching logic is duplicated across `ThreadController` and `SearchEmailController`. This makes OCP impossible: every new search execution variant requires modifying existing controller code to reset/advance cursors.

## Decision

### 1. `SearchFilterNotifier` — single source of truth

`SearchFilterNotifier` is a Riverpod `@keepAlive` notifier and the **only** owner of `SearchEmailFilter` state. It holds **user intent only**: from, to, mailbox, text, unread, hasAttachment, sortOrder, emailReceiveTimeType, etc. Pagination cursors are explicitly excluded.

```dart
@Riverpod(keepAlive: true)
class SearchFilterNotifier extends _$SearchFilterNotifier {
  @override
  SearchEmailFilter build() => SearchEmailFilter.initial();

  void update({...})              // partial field update; unspecified fields unchanged
  void set(SearchEmailFilter f)   // full replace — used when applying the advanced filter form
  void clear()                    // reset all fields; preserve sortOrderType
}
```

`SearchController.searchEmailFilter.obs` becomes a passive mirror via one `appProviderContainer.listen()` bridge in `SearchController.onInit()`. All existing web `Obx` widgets continue working unchanged. All web and mobile write sites delegate to `appProviderContainer.read(searchFilterNotifierProvider.notifier)`.

**Session reset:** `MailboxDashBoardController.onClose()` calls `appProviderContainer.invalidate(searchFilterNotifierProvider)`. Required because `appProviderContainer` is process-scoped (ADR-0092) — without it, stale filter from a previous session survives logout.

### 2. `SearchFilterPipeline` + transformers — execution-time logic

Execution-time state (cursors, `FilterMessageOption` mapping) is separated from the SSOT using a pipeline transformer pattern.

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

Location: `lib/features/search/email/domain/transformer/`

| Transformer | Category | Written to SSOT? | Replaces |
|---|---|---|---|
| `ResetPaginationTransformer` | Transient | No | Cursor reset before every fresh search (6 sites, 2 controllers) |
| `SearchMoreTransformer(count, lastDate)` | Transient | No | Duplicated `isScrollByPosition()` cursor-advance logic |
| `FilterMessageOptionTransformer(option)` | Intent | Yes — via `notifier.set()` | Inline `switch` mapping inbox filter → JMAP fields |

`FilterMessageOptionTransformer` is applied to the SSOT (not passed to the executor) so the advanced filter form and chips reflect the mapped state. Restored on search exit via `restoreFilterMessageOption()`.

### 3. `SearchEmailNotifier` — centralized search executor (Riverpod)

All search execution is centralized in `SearchEmailNotifier` — a single Riverpod `AsyncNotifier` that applies `SearchFilterPipeline` and calls the interactor. Consumers declare *what* they want (`search` or `loadMore`); the executor applies the correct transient transformers internally — callers never choose them.

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
      const ResetPaginationTransformer(), // executor always applies — caller cannot forget
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
    // call SearchMoreEmailInteractor, append emails to current state
  }
}
```

**Who provides which transformer:**

| Transformer | Provided by | Reason |
|---|---|---|
| `ResetPaginationTransformer` | Executor — always | Callers must never forget to reset cursors |
| `SearchMoreTransformer` | Executor — always | Cursor-advance logic consolidated in one place |
| `FilterMessageOptionTransformer` | Caller (inbox context) | Applied to SSOT before calling `search()` — form/chips must reflect it |

**OCP at system level:** adding a new execution rule = new transformer inside the executor. No caller changes. New search entry point (deep-link, notification, new screen) = call `notifier.search()`. No new GetX controller.

Location: `lib/features/search/email/domain/notifier/search_email_notifier.dart`

### 4. `SearchFilterDraftNotifier` — advanced filter panel draft state

`AdvancedFilterController` currently holds `_memorySearchFilter` — a plain `SearchEmailFilter` field that buffers in-panel edits, written by `_updateMemorySearchFilter()` (~20 call sites), and flushed to the SSOT only on Apply. This is unobservable local state scattered across the controller.

Replace it with `SearchFilterDraftNotifier` — a Riverpod `autoDispose` notifier scoped to the panel's lifetime:

```dart
@riverpod  // autoDispose by default — clears when panel closes
class SearchFilterDraftNotifier extends _$SearchFilterDraftNotifier {
  @override
  SearchEmailFilter build() => SearchEmailFilter.initial();

  void update({...})             // same signature as SearchFilterNotifier.update()
  void set(SearchEmailFilter f)  // seed draft from committed state on panel open
}
```

Panel lifecycle:

| Event | Action |
|---|---|
| Event | Action |
|---|---|
| Panel opens | `AdvancedFilterView.initState()` seeds draft: `ref.read(searchFilterDraftNotifierProvider.notifier).set(ref.read(searchFilterNotifierProvider))` |
| Field change | `draftNotifier.update(...)` — replaces every `_updateMemorySearchFilter()` call |
| Apply | `committedNotifier.set(ref.read(searchFilterDraftNotifierProvider))` — flush to SSOT |
| Cancel | Close panel → `autoDispose` clears draft automatically — no cleanup code |

**Seeding happens in the view, not the controller.** `SearchFilterDraftNotifier` is `autoDispose` — it stays alive only while `AdvancedFilterView` holds an active `ref.watch()`. If the controller seeds the draft before the view mounts, no listener exists yet and the provider auto-disposes immediately, discarding the seed. Moving the seed to `AdvancedFilterView.initState()` guarantees the `ref.watch()` is already active.

`AdvancedFilterView` migrates to `ConsumerStatefulWidget`:
```dart
@override
void initState() {
  super.initState();
  // ref.watch() in build() is already active — seed is safe here
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final committed = ref.read(searchFilterNotifierProvider);
    ref.read(searchFilterDraftNotifierProvider.notifier).set(committed);
  });
}

// in build():
final draft = ref.watch(searchFilterDraftNotifierProvider);
```

This eliminates: `_memorySearchFilter` field, `_updateMemorySearchFilter()`, `_synchronizeSearchFilter()`, and all staging-related cleanup methods in `AdvancedFilterController`. The controller becomes a thin shell for action dispatch only.

Location: `lib/features/search/email/domain/notifier/search_filter_draft_notifier.dart`

## Invariants

- `SearchEmailFilter.copyWith()` is called only inside `SearchFilterNotifier.update()`/`set()` and `SearchFilterDraftNotifier.update()`/`set()`. No controller or widget calls it directly.
- Pagination cursors (`position`, `before`, `startDate`) are never written to the SSOT. They are computed transiently by `SearchFilterPipeline` inside `SearchEmailNotifier`.
- Draft state (`searchFilterDraftNotifierProvider`) is never read by `SearchEmailNotifier`. Only committed state (`searchFilterNotifierProvider`) is used for search execution.
- New search execution variant → new `SearchFilterTransformer` subclass. No existing transformer, executor, controller, or filter model is modified (OCP).

## Architecture

```
User action (chip / text / folder select)
                         │
                         ▼
          ┌──────────────────────────────────┐
          │   SearchFilterNotifier (SSOT)    │  Riverpod keepAlive
          │   committed user intent only     │  update() / set() / clear()
          └──────┬───────────────────────────┘
                 │                         ▲
                 │ listen() bridge         │ committedNotifier.set(draft)
                 ▼                         │ ← on Apply
          SearchController             ┌───┴──────────────────────────────┐
          .searchEmailFilter.obs       │  SearchFilterDraftNotifier       │  Riverpod autoDispose
          (web Rx mirror)              │  panel-scoped draft state        │  update() / set()
          read by Obx web widgets      └───────────────┬──────────────────┘
                 │                                     │ ref.watch() — AdvancedFilterView
                 │                               ConsumerStatefulWidget
                 │                               seed on open / cleared on close (autoDispose)
                 │
  FilterMessageOption ──► FilterMessageOptionTransformer
  (inbox context)         → committedNotifier.set(resolved)   on search entry
                          → restoreFilterMessageOption()       on search exit
                          → NEVER passed to JMAP as moreFilterCondition
                 │
                 ▼ caller invokes executor
          ┌──────────────────────────────────┐
          │   SearchEmailNotifier (executor)  │  Riverpod autoDispose
          │   search() / loadMore()           │  reads committed SSOT only
          │   [intentTransformers...,         │
          │    ResetPaginationTransformer]    │
          └──────────────┬───────────────────┘
                         │
                         ▼
          AsyncValue<SearchEmailState>  ─────────────────────┐
                         │                                    │
                  web bridge                           mobile (direct)
          ThreadController                          SearchEmailView
          appProviderContainer.listen(...)          ref.watch(searchEmailNotifierProvider)
          → emailsInCurrentMailbox.obs              ConsumerStatefulWidget
```

## Riverpod-First Direction

GetX is the legacy layer. New search logic is written as Riverpod providers. GetX controllers bridge via `appProviderContainer` during migration and are eventually retired.

This PR completes the search path:
- Committed filter state: `SearchFilterNotifier` (Riverpod keepAlive)
- Advanced filter panel draft: `SearchFilterDraftNotifier` (Riverpod autoDispose)
- Search execution + results: `SearchEmailNotifier` (Riverpod AsyncNotifier)
- Mobile UI: `SearchEmailView`, `AdvancedFilterView` (ConsumerStatefulWidget) reads Riverpod directly via `ref.watch()`
- Web: `ThreadController` bridges to Riverpod via `appProviderContainer` until the thread view is migrated

`Session` and `AccountId` are passed as method parameters in this PR. Future improvement: expose via `SessionProvider` (Riverpod) to eliminate the parameter entirely.

---

## Consequences

**Positive**
- `copyWith()` called only in `SearchFilterNotifier` and `SearchFilterDraftNotifier` — no diverging filter state between web and mobile
- Pagination cursors never pollute the SSOT — notifier represents user intent only
- `FilterMessageOption` is inbox-only; no hidden filter bleed into JMAP search queries
- `SearchFilterPipeline` built in exactly one class (`SearchEmailNotifier`) — callers never choose transient transformers
- New search execution variant = new transformer subclass, no existing code changes (OCP)
- New search entry point = call `notifier.search()`, no new GetX controller
- Advanced filter panel Cancel is a no-op — `autoDispose` clears draft, no cleanup method needed
- `_updateMemorySearchFilter`, `_memorySearchFilter`, `_synchronizeSearchFilter` eliminated entirely
- `SearchEmailView` and `AdvancedFilterView` read Riverpod state directly — no `Obx`, no `consumeState()`

**Negative**
- `SearchController.searchEmailFilter.obs` bridge persists until web filter-UI widgets migrate to `Consumer`
- `ThreadController` still bridges result state via `appProviderContainer.listen()` until thread view migrates
- `Session`/`AccountId` as method parameters is temporary — addressed when `SessionProvider` is introduced
