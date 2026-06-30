import 'package:jmap_dart_client/jmap/core/utc_date.dart';

/// What search to run — the "which search" axis (pagination is separate, see
/// `SearchPaginationStrategy`). `sealed` so the executor's `switch` is exhaustive;
/// a new variant = a new subclass + one branch (OCP). See ADR-0093.
sealed class SearchExecutionIntent {
  const SearchExecutionIntent();
}

/// Run the search from scratch, discarding any previous result.
class NewSearchIntent extends SearchExecutionIntent {
  const NewSearchIntent();
}

/// Fetch the next page and append it. Only valid on a non-empty result — the
/// caller guards the empty case (like the existing `isEmpty` checks), which the
/// `assert` encodes, so an empty load-more never becomes a page-1 refetch.
class LoadMoreIntent extends SearchExecutionIntent {
  const LoadMoreIntent({required this.currentCount, required this.lastEmailDate})
      : assert(currentCount > 0, 'LoadMoreIntent requires a non-empty result');

  /// Rows already loaded — the offset for position-based pagination.
  final int currentCount;

  /// Last row's `receivedAt` — the cursor for date-based pagination (null if it
  /// has none, leaving no cursor set: a safe degenerate request).
  final UTCDate? lastEmailDate;
}

/// Re-run the current search to fold in server-side changes, replacing the result.
/// The caller decides if a refresh is needed (websocket state) before `execute`.
class RefreshChangesIntent extends SearchExecutionIntent {
  const RefreshChangesIntent({required this.currentCount});

  final int currentCount;
}
