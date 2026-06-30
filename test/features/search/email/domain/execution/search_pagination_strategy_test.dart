import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/collapsed_thread_load_more_strategy.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/date_load_more_strategy.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/fresh_search_strategy.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/position_load_more_strategy.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_context.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_intent.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_pagination_strategies.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_pagination_strategy.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_request_spec.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';

/// Tests the resolver end to end — the guarantee that matters is "the right
/// strategy wins for a given context". Table-driven so resolve→assert lives once.
void main() {
  // Load-more cursor (last row's receivedAt) vs user date-range bounds (must survive).
  final lastDate = UTCDate(DateTime.parse('2026-03-15T10:00:00.000Z'));
  final rangeStart = UTCDate(DateTime.parse('2026-01-01T00:00:00.000Z'));
  final rangeEnd = UTCDate(DateTime.parse('2026-06-01T00:00:00.000Z'));

  SearchExecutionContext contextOf({
    required SearchExecutionIntent intent,
    EmailSortOrderType sortOrder = EmailSortOrderType.mostRecent,
    bool collapseThreads = false,
    UTCDate? startDate,
    UTCDate? endDate,
  }) {
    return SearchExecutionContext(
      intent: intent,
      committed: SearchEmailFilter(
        sortOrderType: sortOrder,
        startDate: startDate,
        endDate: endDate,
      ),
      collapseThreads: collapseThreads,
    );
  }

  SearchRequestSpec resolve(SearchExecutionContext ctx) =>
      resolveSearchRequestSpec(SearchRequestSpec.base(ctx), ctx);

  /// Asserts the resolved pagination outcome. Each argument accepts a value or a
  /// matcher (e.g. `isNull`), so every strategy case reads as one expectation.
  void expectCursors(
    SearchRequestSpec spec, {
    required Object? position,
    required Object? before,
    required Object? after,
  }) {
    expect(spec.position, position);
    expect(spec.filter.position, isNull);
    expect(spec.filter.before, before);
    expect(spec.filter.after, after);
  }

  void expectBoundsPreserved(SearchRequestSpec spec) {
    expect(spec.filter.startDate, rangeStart);
    expect(spec.filter.endDate, rangeEnd);
  }

  group('LoadMoreIntent', () {
    test('rejects an empty result in every build mode', () {
      expect(
        () => LoadMoreIntent(currentCount: 0, lastEmailDate: lastDate),
        throwsArgumentError,
      );
    });
  });

  group('ordered strategy list', () {
    test('is in most-specific-first, catch-all-last order', () {
      expect(kSearchPaginationStrategies, hasLength(4));
      expect(kSearchPaginationStrategies[0], isA<CollapsedThreadLoadMoreStrategy>());
      expect(kSearchPaginationStrategies[1], isA<PositionLoadMoreStrategy>());
      expect(kSearchPaginationStrategies[2], isA<DateLoadMoreStrategy>());
      expect(kSearchPaginationStrategies[3], isA<FreshSearchStrategy>());
    });

    test('FreshSearchStrategy is the unconditional catch-all', () {
      expect(const FreshSearchStrategy().appliesTo(
        contextOf(intent: const NewSearchIntent())), isTrue);
      expect(const FreshSearchStrategy().appliesTo(contextOf(
        intent: LoadMoreIntent(currentCount: 5, lastEmailDate: null))), isTrue);
    });
  });

  group('cursor resolution per (intent, sortOrder, collapseThreads)', () {
    final cursorCases = <_CursorCase>[
      // LoadMore — position-based / collapsed → position == currentCount.
      _CursorCase('LoadMore relevance → position, no date cursors',
          contextOf(
            intent: LoadMoreIntent(currentCount: 20, lastEmailDate: lastDate),
            sortOrder: EmailSortOrderType.relevance,
          ),
          position: 20, before: isNull, after: isNull),
      _CursorCase('LoadMore oldest + collapseThreads → position (CollapsedThread wins)',
          contextOf(
            intent: LoadMoreIntent(currentCount: 40, lastEmailDate: lastDate),
            sortOrder: EmailSortOrderType.oldest,
            collapseThreads: true,
          ),
          position: 40, before: isNull, after: isNull),
      // LoadMore — date-based → exactly one date cursor, no position.
      _CursorCase('LoadMore oldest → `after` cursor only',
          contextOf(
            intent: LoadMoreIntent(currentCount: 20, lastEmailDate: lastDate),
            sortOrder: EmailSortOrderType.oldest,
          ),
          position: isNull, before: isNull, after: lastDate),
      _CursorCase('LoadMore mostRecent → `before` cursor only',
          contextOf(
            intent: LoadMoreIntent(currentCount: 20, lastEmailDate: lastDate),
            sortOrder: EmailSortOrderType.mostRecent,
          ),
          position: isNull, before: lastDate, after: isNull),
      _CursorCase('LoadMore date sort with null lastEmailDate → no cursor (degenerate, safe)',
          contextOf(
            intent: LoadMoreIntent(currentCount: 20, lastEmailDate: null),
            sortOrder: EmailSortOrderType.oldest,
          ),
          position: isNull, before: isNull, after: isNull),
      // Fresh (new / refresh) → cursors cleared, position per pagination mode.
      _CursorCase('NewSearch relevance → position 0, cursors cleared',
          contextOf(
            intent: const NewSearchIntent(),
            sortOrder: EmailSortOrderType.relevance,
          ),
          position: 0, before: isNull, after: isNull),
      _CursorCase('NewSearch mostRecent → position cleared, cursors cleared',
          contextOf(
            intent: const NewSearchIntent(),
            sortOrder: EmailSortOrderType.mostRecent,
          ),
          position: isNull, before: isNull, after: isNull),
      _CursorCase('NewSearch oldest + collapseThreads → position 0 even on a date sort',
          contextOf(
            intent: const NewSearchIntent(),
            sortOrder: EmailSortOrderType.oldest,
            collapseThreads: true,
          ),
          position: 0, before: isNull, after: isNull),
      _CursorCase('RefreshChanges relevance → fresh search, position 0',
          contextOf(
            intent: const RefreshChangesIntent(currentCount: 30),
            sortOrder: EmailSortOrderType.relevance,
          ),
          position: 0, before: isNull, after: isNull),
      _CursorCase('RefreshChanges mostRecent → fresh search, position cleared',
          contextOf(
            intent: const RefreshChangesIntent(currentCount: 30),
            sortOrder: EmailSortOrderType.mostRecent,
          ),
          position: isNull, before: isNull, after: isNull),
    ];

    for (final c in cursorCases) {
      test(c.name, () {
        expectCursors(
          resolve(c.ctx),
          position: c.position,
          before: c.before,
          after: c.after,
        );
      });
    }
  });

  group('startDate/endDate user bounds are preserved (never treated as cursors)', () {
    final boundCases = <_BoundCase>[
      _BoundCase('LoadMore oldest', LoadMoreIntent(
          currentCount: 20, lastEmailDate: lastDate), EmailSortOrderType.oldest),
      const _BoundCase('NewSearch mostRecent',
          NewSearchIntent(), EmailSortOrderType.mostRecent),
    ];

    for (final c in boundCases) {
      test(c.name, () {
        expectBoundsPreserved(resolve(contextOf(
          intent: c.intent,
          sortOrder: c.sortOrder,
          startDate: rangeStart,
          endDate: rangeEnd,
        )));
      });
    }
  });

  group('stale cursors on the committed filter are never carried into a request', () {
    // The committed SSOT should never hold cursors, but the resolver must be
    // robust to it — this is the leak (#4490/#4590-class) the refactor removes.
    SearchExecutionContext withStaleCursors(
      SearchExecutionIntent intent,
      EmailSortOrderType sortOrder, {
      bool collapseThreads = false,
    }) {
      return SearchExecutionContext(
        intent: intent,
        committed: SearchEmailFilter(
          sortOrderType: sortOrder,
          position: 99,
          before: lastDate,
          after: lastDate,
        ),
        collapseThreads: collapseThreads,
      );
    }

    final staleCases = <({
      String name,
      SearchExecutionIntent intent,
      EmailSortOrderType sort,
      bool collapse,
      Object? position,
      Object? before,
      Object? after,
    })>[
      (
        name: 'fresh search clears stale cursors',
        intent: const NewSearchIntent(),
        sort: EmailSortOrderType.mostRecent,
        collapse: false,
        position: isNull,
        before: isNull,
        after: isNull,
      ),
      (
        name: 'position load-more clears stale filter cursors',
        intent: LoadMoreIntent(currentCount: 15, lastEmailDate: lastDate),
        sort: EmailSortOrderType.relevance,
        collapse: false,
        position: 15,
        before: isNull,
        after: isNull,
      ),
      (
        name: 'collapsed-thread load-more clears stale filter cursors',
        intent: LoadMoreIntent(currentCount: 15, lastEmailDate: lastDate),
        sort: EmailSortOrderType.oldest,
        collapse: true,
        position: 15,
        before: isNull,
        after: isNull,
      ),
      (
        name: 'date load-more oldest replaces stale cursors with `after` only',
        intent: LoadMoreIntent(currentCount: 15, lastEmailDate: lastDate),
        sort: EmailSortOrderType.oldest,
        collapse: false,
        position: isNull,
        before: isNull,
        after: lastDate,
      ),
      (
        name: 'date load-more mostRecent replaces stale cursors with `before` only',
        intent: LoadMoreIntent(currentCount: 15, lastEmailDate: lastDate),
        sort: EmailSortOrderType.mostRecent,
        collapse: false,
        position: isNull,
        before: lastDate,
        after: isNull,
      ),
    ];

    for (final c in staleCases) {
      test(c.name, () {
        expectCursors(
          resolve(withStaleCursors(c.intent, c.sort, collapseThreads: c.collapse)),
          position: c.position,
          before: c.before,
          after: c.after,
        );
      });
    }
  });

  group('request limit', () {
    test('every strategy preserves the base page limit', () {
      final contexts = [
        contextOf(intent: const NewSearchIntent(), sortOrder: EmailSortOrderType.relevance),
        contextOf(
          intent: LoadMoreIntent(currentCount: 5, lastEmailDate: lastDate),
          sortOrder: EmailSortOrderType.oldest,
        ),
        contextOf(
          intent: LoadMoreIntent(currentCount: 5, lastEmailDate: lastDate),
          collapseThreads: true,
        ),
      ];
      for (final ctx in contexts) {
        expect(resolve(ctx).limit, ThreadConstants.defaultLimit);
      }
    });
  });

  group('purity', () {
    test('no strategy mutates ctx.committed', () {
      final committed = SearchEmailFilter(
        sortOrderType: EmailSortOrderType.oldest,
        before: lastDate,
        startDate: rangeStart,
      );
      final ctx = SearchExecutionContext(
        intent: LoadMoreIntent(currentCount: 10, lastEmailDate: lastDate),
        committed: committed,
        collapseThreads: false,
      );

      resolve(ctx);

      expect(ctx.committed, committed);
      expect(ctx.committed.before, lastDate);
      expect(ctx.committed.startDate, rangeStart);
    });
  });

  group('insertion safety', () {
    test('a guarded strategy prepended at the top does not change unmatched contexts', () {
      // Context the new strategy does NOT match: date-sort load-more, no collapse.
      final ctx = contextOf(
        intent: LoadMoreIntent(currentCount: 20, lastEmailDate: lastDate),
        sortOrder: EmailSortOrderType.mostRecent,
      );

      final withoutNew = resolveSearchRequestSpec(SearchRequestSpec.base(ctx), ctx);
      final withNew = resolveSearchRequestSpec(
        SearchRequestSpec.base(ctx),
        ctx,
        strategies: const [
          _NeverMatchingStrategy(),
          ...kSearchPaginationStrategies,
        ],
      );

      expect(withNew.position, withoutNew.position);
      expect(withNew.filter.before, withoutNew.filter.before);
      expect(withNew.filter.after, withoutNew.filter.after);
    });
  });
}

/// One row of the cursor-resolution table: a context and its expected outcome
/// (each expectation accepts a value or a matcher such as `isNull`).
class _CursorCase {
  const _CursorCase(
    this.name,
    this.ctx, {
    required this.position,
    required this.before,
    required this.after,
  });

  final String name;
  final SearchExecutionContext ctx;
  final Object? position;
  final Object? before;
  final Object? after;
}

/// One row of the bound-preservation table.
class _BoundCase {
  const _BoundCase(this.name, this.intent, this.sortOrder);

  final String name;
  final SearchExecutionIntent intent;
  final EmailSortOrderType sortOrder;
}

/// A guarded strategy whose `appliesTo` is never true for the tested context;
/// prepending it must leave the resolved result unchanged (first-match contract).
class _NeverMatchingStrategy extends SearchPaginationStrategy {
  const _NeverMatchingStrategy();

  @override
  bool appliesTo(SearchExecutionContext ctx) => false;

  @override
  SearchRequestSpec apply(SearchRequestSpec spec, SearchExecutionContext ctx) =>
      throw StateError('must not be applied');
}
