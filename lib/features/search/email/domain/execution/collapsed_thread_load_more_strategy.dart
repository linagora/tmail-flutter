import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_context.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_intent.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_pagination_strategy.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_request_spec.dart';

/// Load-more with `collapseThreads` on: page by `position`, whatever the sort.
/// A collapsed row aggregates emails with differing `receivedAt`, so only an
/// offset is a stable cursor. Most specific guard → sits first; off → never
/// matches. Baseline since #4651.
class CollapsedThreadLoadMoreStrategy extends SearchPaginationStrategy {
  const CollapsedThreadLoadMoreStrategy();

  @override
  bool appliesTo(SearchExecutionContext ctx) =>
      ctx.intent is LoadMoreIntent && ctx.collapseThreads;

  @override
  SearchRequestSpec apply(SearchRequestSpec spec, SearchExecutionContext ctx) {
    final currentCount = (ctx.intent as LoadMoreIntent).currentCount;
    return spec.copyWith(
      positionOption: Some(currentCount),
      filter: spec.filter.clearPaginationCursors(),
    );
  }
}
