import 'package:tmail_ui_user/features/search/email/domain/model/search_email_result.dart';

/// A consumer of the central search executor. Implementers register with
/// [SearchExecutorService] and update their own state in these reactions; the
/// service never reads back into them.
abstract class SearchExecutionObserver {
  /// A fresh search was dispatched: reset transient list/scroll/focus state.
  void onNewSearchStarted();

  /// The first page is loading: show the search spinner.
  void onSearchLoading();

  /// A result is available. [result] carries the full accumulated list;
  /// [isFreshResult] is true only for the first page of a new search.
  void onSearchResult(SearchEmailResult result, {required bool isFreshResult});

  /// The search failed with a non-urgent error. Urgent failures are routed by
  /// the executor's consume seam and filtered by [SearchExecutorService]
  /// (ADR-0103), so this is never called for them. [isReplay] hydrates a new
  /// layout owner and must not repeat one-shot user notifications.
  void onSearchFailure(Object error, {bool isReplay = false});
}
