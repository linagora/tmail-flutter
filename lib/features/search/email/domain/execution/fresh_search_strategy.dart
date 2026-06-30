import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_context.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_pagination_strategy.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_request_spec.dart';

/// Catch-all for new search / refresh. Clears both load-more cursors (leaving them
/// set was the stale-result leak) but keeps the `startDate`/`endDate` bounds.
/// `position` restarts at 0 when paging by offset (position sort or
/// `collapseThreads`), else cleared. Guard is always `true` → must stay last.
class FreshSearchStrategy extends SearchPaginationStrategy {
  const FreshSearchStrategy();

  @override
  bool appliesTo(SearchExecutionContext ctx) => true;

  @override
  SearchRequestSpec apply(SearchRequestSpec spec, SearchExecutionContext ctx) {
    final usesPositionPagination =
        ctx.committed.sortOrderType.isScrollByPosition() || ctx.collapseThreads;
    return spec.copyWith(
      positionOption: usesPositionPagination ? const Some(0) : const None(),
      filter: spec.filter.clearPaginationCursors(),
    );
  }
}
