import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_context.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_intent.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_pagination_strategy.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_request_spec.dart';

/// Load-more on a position-based sort (relevance / sender / subject / size): no
/// monotonic date to page by, so take the next page by offset
/// (`position == currentCount`). Date cursors are cleared to stay total.
class PositionLoadMoreStrategy extends SearchPaginationStrategy {
  const PositionLoadMoreStrategy();

  @override
  bool appliesTo(SearchExecutionContext ctx) =>
      ctx.intent is LoadMoreIntent &&
      ctx.committed.sortOrderType.isScrollByPosition();

  @override
  SearchRequestSpec apply(SearchRequestSpec spec, SearchExecutionContext ctx) {
    final currentCount = (ctx.intent as LoadMoreIntent).currentCount;
    return spec.copyWith(
      positionOption: Some(currentCount),
      filter: spec.filter.copyWith(
        beforeOption: const None(),
        afterOption: const None(),
      ),
    );
  }
}
