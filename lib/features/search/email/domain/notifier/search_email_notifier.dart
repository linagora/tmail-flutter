import 'package:core/presentation/state/success.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_context.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_intent.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_request.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_pagination_strategies.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_result.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_request_spec.dart';
import 'package:tmail_ui_user/features/search/email/domain/model/search_email_query_params.dart';
import 'package:tmail_ui_user/features/search/email/domain/model/search_email_result.dart';
import 'package:tmail_ui_user/features/base/interactor_consumer.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/state/refresh_changes_search_email_state.dart';
import 'package:tmail_ui_user/features/search/email/domain/usecases/refresh_changes_search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_more_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';

part 'search_email_notifier.g.dart';

/// Applies a freshly loaded page of emails to [state].
typedef SearchPageHandler = void Function(List<PresentationEmail> page);

/// Central search executor: resolves pagination from the committed SSOT and folds
/// each intent's result into an [AsyncValue] of [SearchEmailResult]. See ADR-0093.
@Riverpod(keepAlive: true)
class SearchEmailNotifier extends _$SearchEmailNotifier with InteractorConsumer {
  // Lazy GetX bridge so build() never touches DI; a missing interactor surfaces
  // as an error at execute time, not a throw from build().
  SearchEmailInteractor get _searchInteractor =>
      Get.find<SearchEmailInteractor>();
  SearchMoreEmailInteractor get _searchMoreInteractor =>
      Get.find<SearchMoreEmailInteractor>();
  RefreshChangesSearchEmailInteractor get _refreshInteractor =>
      Get.find<RefreshChangesSearchEmailInteractor>();

  /// Monotonic token; a result applies only while it is the latest.
  int _latestRequestId = 0;

  /// Current result, or an empty one before the first search lands.
  SearchEmailResult get _currentResult =>
      state.value ?? SearchEmailResult.empty();

  @override
  AsyncValue<SearchEmailResult> build() => AsyncData(SearchEmailResult.empty());

  /// Runs [intent] and updates [state]; never mutates the committed SSOT.
  Future<SearchExecutionResult> execute(
    SearchExecutionIntent intent, {
    required Session session,
    required AccountId accountId,
    required Properties properties,
    required bool collapseThreads,
    required Set<MailboxId>? trashSpamMailboxIds,
  }) {
    final request = SearchExecutionRequest(
      intent: intent,
      session: session,
      accountId: accountId,
      properties: properties,
      collapseThreads: collapseThreads,
      trashSpamMailboxIds: trashSpamMailboxIds,
    );
    final requestId = ++_latestRequestId;
    return switch (intent) {
      NewSearchIntent() => _runNewSearch(requestId, request),
      LoadMoreIntent() => _runLoadMore(requestId, request),
      RefreshChangesIntent() => _runRefresh(requestId, request),
    };
  }

  /// New search: show a first-page spinner, then replace the list or error (a
  /// fresh search has no prior list to fall back on).
  Future<SearchExecutionResult> _runNewSearch(
    int requestId,
    SearchExecutionRequest request,
  ) {
    state = const AsyncLoading();
    return _runGuarded(
      requestId,
      () {
        final params = _resolveQueryParams(request);
        return _searchInteractor
            .execute(
              params.session,
              params.accountId,
              limit: params.limit,
              position: params.position,
              sort: params.sort,
              filter: params.filter,
              properties: params.properties,
              collapseThreads: params.collapseThreads,
            )
            .last;
      },
      onPageLoaded: (page) => state = AsyncData(
        SearchEmailResult(emails: page, canLoadMore: page.isNotEmpty),
      ),
      onFailure: (error, stackTrace) => state = AsyncError(error, stackTrace),
    );
  }

  /// Load-more: mark the page in progress, then append it. On failure the loaded
  /// page stays and [LoadMoreState.failure] lets the UI offer a retry. Concurrency
  /// (e.g. a socket-driven refresh arriving mid-load) is handled by [_latestRequestId]
  /// in [_runGuarded], which drops a superseded page — not by [LoadMoreState].
  Future<SearchExecutionResult> _runLoadMore(
    int requestId,
    SearchExecutionRequest request,
  ) {
    state = AsyncData(_currentResult.copyWith(
      loadMore: LoadMoreState.inProgress,
    ));
    return _runGuarded(
      requestId,
      () {
        final params = _resolveQueryParams(request);
        return _searchMoreInteractor
            .execute(
              params.session,
              params.accountId,
              limit: params.limit,
              sort: params.sort,
              position: params.position,
              filter: params.filter,
              properties: params.properties,
              collapseThreads: params.collapseThreads,
              lastEmailId: params.lastEmailId,
            )
            .last;
      },
      onPageLoaded: (page) => state = AsyncData(_currentResult.copyWith(
        emails: [..._currentResult.emails, ..._dropAlreadyLoaded(page)],
        canLoadMore: page.isNotEmpty,
        loadMore: LoadMoreState.idle,
      )),
      // Preserve the loaded page and flag the failure for the retry UI. Urgent
      // load-more failures are routed by the consume seam (ADR-0103).
      onFailure: (_, __) => state = AsyncData(
        _currentResult.copyWith(loadMore: LoadMoreState.failure),
      ),
    );
  }

  /// Refresh: replace the list on success; on failure keep the current list, never
  /// erroring the whole result.
  Future<SearchExecutionResult> _runRefresh(
    int requestId,
    SearchExecutionRequest request,
  ) {
    state = AsyncData(_currentResult.copyWith(
      loadMore: LoadMoreState.idle,
    ));
    return _runGuarded(
      requestId,
      () {
        final params = _resolveQueryParams(request);
        return _refreshInteractor
            .execute(
              params.session,
              params.accountId,
              limit: params.limit,
              position: params.position,
              sort: params.sort,
              filter: params.filter,
              collapseThreads: params.collapseThreads,
              properties: params.properties,
            )
            .last;
      },
      onPageLoaded: (page) => state = AsyncData(
        SearchEmailResult(emails: page, canLoadMore: page.isNotEmpty),
      ),
      // Nothing visible changes on failure — keep the list. The consume seam
      // routes urgent ones at the failure point (ADR-0103), so repeats all route.
      onFailure: (_, __) {},
    );
  }

  /// Runs [runInteractor] through the [InteractorConsumer] seam (auto urgent
  /// routing, ADR-0093/0103), dropping stale results; intermediate successes kept.
  Future<SearchExecutionResult> _runGuarded(
    int requestId,
    InteractorCall runInteractor, {
    required SearchPageHandler onPageLoaded,
    required InteractorFailureHandler onFailure,
  }) async {
    final succeeded = await consumeInteractor(
      runInteractor,
      isStale: () => !ref.mounted || requestId != _latestRequestId,
      onSuccess: (success) {
        final page = _emailsOf(success);
        if (page != null) onPageLoaded(page); // else intermediate — keep current
      },
      onFailure: onFailure,
    );
    if (succeeded) return SearchExecutionResult.success;
    // Re-check staleness after the await: a newer execute() during the
    // interactor call advances _latestRequestId. A failure that raced a newer
    // request is superseded, not a real failure, so the refresh path skips the
    // retry — the newer request now owns the result.
    return !ref.mounted || requestId != _latestRequestId
        ? SearchExecutionResult.superseded
        : SearchExecutionResult.failure;
  }

  /// Resolves the interactor args via the pagination strategies for [request].
  SearchEmailQueryParams _resolveQueryParams(SearchExecutionRequest request) {
    final intent = request.intent;
    final committed = ref.read(searchFilterProvider);
    final context = SearchExecutionContext(
      intent: intent,
      committed: committed,
      collapseThreads: request.collapseThreads,
    );
    final spec = resolveSearchRequestSpec(SearchRequestSpec.base(context), context);
    final limit = intent is RefreshChangesIntent && intent.currentCount > 0
        ? UnsignedInt(intent.currentCount)
        : spec.limit;

    return SearchEmailQueryParams(
      session: request.session,
      accountId: request.accountId,
      filter: spec.filter.mappingToEmailFilterCondition(
        trashSpamMailboxIds: request.trashSpamMailboxIds,
      ),
      sort: spec.filter.sortOrderType.getSortOrder().toNullable(),
      properties: request.properties,
      collapseThreads: request.collapseThreads,
      limit: limit,
      position: spec.position,
      lastEmailId: intent is LoadMoreIntent ? intent.lastEmailId : null,
    );
  }

  /// Drops emails already present in the current list so a load-more page whose
  /// boundary overlaps the previous one (same-timestamp rows) never duplicates.
  List<PresentationEmail> _dropAlreadyLoaded(List<PresentationEmail> page) {
    final existingIds =
        _currentResult.emails.map((email) => email.id).toSet();
    return page.where((email) => !existingIds.contains(email.id)).toList();
  }

  /// Emails of a terminal success, else null (keep current on intermediate).
  List<PresentationEmail>? _emailsOf(Success success) {
    return switch (success) {
      SearchEmailSuccess(:final emailList) => emailList,
      SearchMoreEmailSuccess(:final emailList) => emailList,
      RefreshChangesSearchEmailSuccess(:final emailList) => emailList,
      _ => null,
    };
  }
}
