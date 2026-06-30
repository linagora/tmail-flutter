import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_context.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_intent.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_pagination_strategy.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_request_spec.dart';

/// Load-more on a date-based sort: page by the last row's `receivedAt`. `oldest`
/// walks forward (`after` cursor), `mostRecent` backward (`before`). Exactly one
/// cursor is set; `position` is cleared; the `startDate`/`endDate` bounds are kept
/// (they are intent, not cursors).
class DateLoadMoreStrategy extends SearchPaginationStrategy {
  const DateLoadMoreStrategy();

  @override
  bool appliesTo(SearchExecutionContext ctx) =>
      ctx.intent is LoadMoreIntent &&
      !ctx.committed.sortOrderType.isScrollByPosition();

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
