import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
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
import 'package:tmail_ui_user/features/search/email/domain/execution/search_pagination_strategies.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_request_spec.dart';
import 'package:tmail_ui_user/features/search/email/domain/model/search_email_query_params.dart';
import 'package:tmail_ui_user/features/search/email/domain/model/search_email_state.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/state/refresh_changes_search_email_state.dart';
import 'package:tmail_ui_user/features/search/email/domain/usecases/refresh_changes_search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_more_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';

part 'search_email_notifier.g.dart';

/// Single search executor: reads the committed SSOT, resolves pagination, dispatches
/// by intent, and folds the result (append on load-more, else replace). See ADR-0093.
@Riverpod(keepAlive: true)
class SearchEmailNotifier extends _$SearchEmailNotifier {
  // Temporary GetX bridge, resolved lazily so build() never touches DI: a missing
  // interactor becomes an AsyncError in _applyResult, not a throw from build().
  SearchEmailInteractor get _searchInteractor =>
      Get.find<SearchEmailInteractor>();
  SearchMoreEmailInteractor get _searchMoreInteractor =>
      Get.find<SearchMoreEmailInteractor>();
  RefreshChangesSearchEmailInteractor get _refreshInteractor =>
      Get.find<RefreshChangesSearchEmailInteractor>();

  /// Request token; a result applies only while it's the latest (drops stale ones).
  int _requestId = 0;

  /// Base a load-more appends to; kept out of [state] so an error can't erase it.
  List<PresentationEmail> _loadedEmails = const [];

  @override
  AsyncValue<SearchEmailState> build() => AsyncData(SearchEmailState.empty());

  /// Runs [intent] and updates [state]. The committed SSOT is never mutated.
  Future<void> execute(
    SearchExecutionIntent intent, {
    required Session session,
    required AccountId accountId,
    required Properties properties,
    required bool collapseThreads,
    required Set<MailboxId>? trashSpamMailboxIds,
  }) async {
    final requestId = ++_requestId;

    final SearchEmailQueryParams params;
    try {
      params = _resolveParams(
        intent,
        session: session,
        accountId: accountId,
        properties: properties,
        collapseThreads: collapseThreads,
        trashSpamMailboxIds: trashSpamMailboxIds,
      );
    } catch (error, stackTrace) {
      if (requestId != _requestId) return;
      state = _errorState(error, stackTrace);
      return;
    }

    switch (intent) {
      case NewSearchIntent():
        state = const AsyncLoading();
        await _applyResult(
          requestId,
          append: false,
          run: () => _searchInteractor.execute(
            params.session,
            params.accountId,
            limit: params.limit,
            position: params.position,
            sort: params.sort,
            filter: params.filter,
            properties: params.properties,
            collapseThreads: params.collapseThreads,
          ).last,
        );
      case LoadMoreIntent():
        await _applyResult(
          requestId,
          append: true,
          run: () => _searchMoreInteractor.execute(
            params.session,
            params.accountId,
            limit: params.limit,
            sort: params.sort,
            position: params.position,
            filter: params.filter,
            properties: params.properties,
            collapseThreads: params.collapseThreads,
            lastEmailId: params.lastEmailId,
          ).last,
        );
      case RefreshChangesIntent():
        await _applyResult(
          requestId,
          append: false,
          run: () => _refreshInteractor.execute(
            params.session,
            params.accountId,
            limit: params.limit,
            position: params.position,
            sort: params.sort,
            filter: params.filter,
            collapseThreads: params.collapseThreads,
            properties: params.properties,
          ).last,
        );
    }
  }

  /// Folds [run]'s result into [state] unless a newer [execute] superseded
  /// [requestId]. A thrown error becomes [AsyncError], never stuck on loading.
  Future<void> _applyResult(
    int requestId, {
    required bool append,
    required Future<Either<Failure, Success>> Function() run,
  }) async {
    try {
      final result = await run();
      if (requestId != _requestId) return;
      state = _foldSearch(result, append: append);
    } catch (error, stackTrace) {
      if (requestId != _requestId) return;
      state = _errorState(error, stackTrace);
    }
  }

  /// Logs to Sentry (error via `exception`, no filter/email content) and returns the
  /// error state. Pages survive in [_loadedEmails], so a retry still appends.
  AsyncValue<SearchEmailState> _errorState(Object error, StackTrace stackTrace) {
    logError(
      'SearchEmailNotifier::execute: search execution failed',
      exception: error,
      stackTrace: stackTrace,
    );
    return AsyncError<SearchEmailState>(error, stackTrace);
  }

  /// Resolves the interactor args via the pagination strategies. `RefreshChangesIntent`
  /// caps `limit` at the current row count to keep the same window.
  SearchEmailQueryParams _resolveParams(
    SearchExecutionIntent intent, {
    required Session session,
    required AccountId accountId,
    required Properties properties,
    required bool collapseThreads,
    required Set<MailboxId>? trashSpamMailboxIds,
  }) {
    final committed = ref.read(searchFilterProvider);
    final ctx = SearchExecutionContext(
      intent: intent,
      committed: committed,
      collapseThreads: collapseThreads,
    );
    final spec = resolveSearchRequestSpec(SearchRequestSpec.base(ctx), ctx);

    return SearchEmailQueryParams(
      session: session,
      accountId: accountId,
      filter: spec.filter.mappingToEmailFilterCondition(
        trashSpamMailboxIds: trashSpamMailboxIds,
      ),
      sort: spec.filter.sortOrderType.getSortOrder().toNullable(),
      properties: properties,
      collapseThreads: collapseThreads,
      limit: intent is RefreshChangesIntent
          ? UnsignedInt(intent.currentCount)
          : spec.limit,
      position: spec.position,
      lastEmailId: intent is LoadMoreIntent ? intent.lastEmailId : null,
    );
  }

  /// Folds a result: failure → error; page → append (load-more) or replace; loading →
  /// keep current. `canLoadMore` stays true while the last page was non-empty.
  AsyncValue<SearchEmailState> _foldSearch(
    Either<Failure, Success> result, {
    required bool append,
  }) {
    return result.fold(
      (failure) => _errorState(failure, StackTrace.current),
      (success) {
        final newEmails = _emailsOf(success);
        if (newEmails == null) return state;
        final emails =
            append ? [..._loadedEmails, ...newEmails] : newEmails;
        _loadedEmails = emails;
        return AsyncData(SearchEmailState(
          emails: emails,
          canLoadMore: newEmails.isNotEmpty,
        ));
      },
    );
  }

  /// Emails of a terminal success, else null (keep current for loading/intermediate).
  List<PresentationEmail>? _emailsOf(Success success) {
    return switch (success) {
      SearchEmailSuccess(:final emailList) => emailList,
      SearchMoreEmailSuccess(:final emailList) => emailList,
      RefreshChangesSearchEmailSuccess(:final emailList) => emailList,
      _ => null,
    };
  }
}
