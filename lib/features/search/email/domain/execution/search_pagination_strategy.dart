import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_context.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_request_spec.dart';

/// One pagination algorithm. Pagination is *select one mode*, so strategies are
/// resolved by **first-match** (most-specific guard first, catch-all last), not
/// folded. Each is **total**: [apply] fully sets `position` and both date cursors,
/// so the result never depends on an earlier strategy. Extending = a new class +
/// one ordered entry (OCP). See ADR-0093 / ADR-0094.
abstract class SearchPaginationStrategy {
  const SearchPaginationStrategy();

  /// Whether this strategy handles [ctx] (its guard).
  bool appliesTo(SearchExecutionContext ctx);

  /// Fully resolves pagination for [ctx] onto [spec].
  SearchRequestSpec apply(SearchRequestSpec spec, SearchExecutionContext ctx);
}
