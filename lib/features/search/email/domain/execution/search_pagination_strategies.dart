import 'package:tmail_ui_user/features/search/email/domain/execution/collapsed_thread_load_more_strategy.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/date_load_more_strategy.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/fresh_search_strategy.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/position_load_more_strategy.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_context.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_pagination_strategy.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_request_spec.dart';

/// Ordered first-match strategy list — the single source of truth for resolution
/// order: most-specific guard first, catch-all (`FreshSearch`) last. The executor
/// consumes it as-is. Extend by adding a class + one entry by guard specificity.
/// See ADR-0093 / ADR-0094.
const List<SearchPaginationStrategy> kSearchPaginationStrategies =
    <SearchPaginationStrategy>[
  CollapsedThreadLoadMoreStrategy(),
  PositionLoadMoreStrategy(),
  DateLoadMoreStrategy(),
  FreshSearchStrategy(),
];

/// Applies the first strategy whose guard matches (the catch-all guarantees one,
/// so `firstWhere` never throws). [strategies] is injectable for insertion-safety
/// tests.
SearchRequestSpec resolveSearchRequestSpec(
  SearchRequestSpec spec,
  SearchExecutionContext ctx, {
  List<SearchPaginationStrategy> strategies = kSearchPaginationStrategies,
}) {
  return strategies.firstWhere((s) => s.appliesTo(ctx)).apply(spec, ctx);
}
