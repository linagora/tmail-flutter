part of '../thread_controller.dart';

/// Web search executor bridge for [ThreadController].
/// Delegates search intents and mirrors [SearchEmailResult] into GetX state.
extension HandleSearchEmailExecutionExtension on ThreadController {
  @visibleForTesting
  Future<void> refreshChangeSearchEmail() => _refreshChangeSearchEmail();

  /// Whether session, account and the current email state are all present — the
  /// values [_refreshChangeListEmailCache] force-unwraps. A queued websocket
  /// refresh can arrive after they clear, so guard on this first.
  bool get _canRefreshSearchChanges =>
      _session != null &&
      _accountId != null &&
      mailboxDashBoardController.currentEmailState != null;

  Future<void> _refreshChangeSearchEmail() async {
    if (!_canRefreshSearchChanges) return;

    await _refreshChangeListEmailCache();

    // Re-check: session/account can clear while the cache refresh above awaits
    // (logout, controller teardown), and _executeSearch force-unwraps them.
    if (!_canRefreshSearchChanges) return;

    loadingMoreStatus.value = LoadingMoreStatus.idle;

    await _executeSearch(RefreshChangesIntent(
      currentCount: mailboxDashBoardController.emailsInCurrentMailbox.length,
    ));
  }

  /// Sends [intent] to the central executor with the shared request context.
  Future<void> _executeSearch(SearchExecutionIntent intent) {
    return appProviderContainer.read(searchEmailProvider.notifier).execute(
      intent,
      session: _session!,
      accountId: _accountId!,
      properties: EmailUtils.getPropertiesForEmailGetMethod(_session!, _accountId!),
      collapseThreads: _shouldCollapseThreads,
      trashSpamMailboxIds: mailboxDashBoardController.trashSpamMailboxIds,
    );
  }

  @visibleForTesting
  void searchEmail({bool needRefreshSearchState = false}) =>
      _searchEmail(needRefreshSearchState: needRefreshSearchState);

  void _searchEmail({bool needRefreshSearchState = false}) {
    if (_session == null || _accountId == null) {
      appProviderContainer.read(searchEmailProvider.notifier).clearResult();
      _handleSearchEmailFailure(SearchEmailFailure(NotFoundSessionException()));
      return;
    }

    if (!needRefreshSearchState && listEmailController.hasClients) {
      isListEmailScrollViewJumping = true;
      listEmailController.jumpTo(0);
    }
    if (!needRefreshSearchState) {
      mailboxDashBoardController.emailsInCurrentMailbox.clear();
    }
    loadingMoreStatus.value = LoadingMoreStatus.idle;

    searchController.activateSimpleSearch();

    // Cursors and limit come from the executor; no `moreFilterCondition` leak.
    _executeSearch(const NewSearchIntent());
  }

  @visibleForTesting
  void searchMoreEmails() => _searchMoreEmails();

  void _searchMoreEmails() {
    if (!canSearchMore) return;

    if (_session == null || _accountId == null) {
      _handleSearchMoreEmailFailure();
      return;
    }

    final currentEmailList = mailboxDashBoardController.emailsInCurrentMailbox;
    if (currentEmailList.isEmpty) return;

    final lastEmail = currentEmailList.last;

    // The executor resolves cursors; no cursor is written to the SSOT.
    _executeSearch(LoadMoreIntent(
      currentCount: currentEmailList.length,
      lastEmailDate: lastEmail.receivedAt,
      lastEmailId: lastEmail.id,
    ));
  }

  /// Bridges [searchEmailProvider] into the web GetX result state.
  /// Mobile search results stay owned by `SearchEmailController`.
  void _registerSearchEmailResultBridge() {
    _searchEmailResultSubscription ??=
        appProviderContainer.listen<AsyncValue<SearchEmailResult>>(
      searchEmailProvider,
      _handleSearchEmailResult,
    );
  }

  /// Maps first-page loading/error to web view state.
  /// Load-more/refresh stay `AsyncData`, so they never blank the list.
  void _handleSearchEmailResult(
    AsyncValue<SearchEmailResult>? previous,
    AsyncValue<SearchEmailResult> next,
  ) {
    if (next.isLoading) {
      dispatchState(Right(SearchingState()));
      return;
    }
    if (next.hasError) {
      _handleSearchEmailFailure(_asSearchEmailFailure(next.error));
      return;
    }
    final result = next.value;
    if (result == null) return;
    _applySearchResult(result);
  }

  void _applySearchResult(SearchEmailResult result) {
    mailboxDashBoardController.updateRefreshAllEmailState(Right(RefreshAllEmailSuccess()));

    // The executor returns the full accumulated list.
    // The transform re-carries the current selection.
    final syncedList = result.emails.toSyncedSearchResults(
      context: PresentationEmailSyncContext(
        mapMailboxById: mailboxDashBoardController.mapMailboxById,
        selectedMailbox: selectedMailbox,
        searchQuery: searchController.searchQuery,
        isSearchEmailRunning: isSearchActive,
      ),
      previousList: mailboxDashBoardController.emailsInCurrentMailbox,
    );
    mailboxDashBoardController.updateEmailList(syncedList);
    if (mailboxDashBoardController.isSelectionEnabled()) {
      mailboxDashBoardController.listEmailSelected.value = listEmailSelected;
    }

    // Settle `viewState` so the searching spinner disappears after results land.
    dispatchState(Right(SearchEmailSuccess(syncedList)));

    _syncLoadMoreStatus(result.loadMore);

    if (_shouldAutoLoadMoreSearchResult(result)) {
      _performAutomaticallyLoadMoreEmails();
    }
  }

  @visibleForTesting
  bool shouldAutoLoadMoreSearchResult(SearchEmailResult result) =>
      _shouldAutoLoadMoreSearchResult(result);

  /// Auto-fetch only after a page settled cleanly (`idle`) and more results
  /// exist. Excludes `failure` so a failed load-more (incl. urgent) never
  /// auto-retries; [_isAutoLoadMore] says the viewport still needs rows.
  bool _shouldAutoLoadMoreSearchResult(SearchEmailResult result) {
    return result.loadMore == LoadMoreState.idle &&
        result.canLoadMore &&
        _isAutoLoadMore;
  }

  void _syncLoadMoreStatus(LoadMoreState loadMore) {
    loadingMoreStatus.value = loadMore == LoadMoreState.inProgress
        ? LoadingMoreStatus.running
        : LoadingMoreStatus.completed;
  }

  void _handleSearchEmailFailure(SearchEmailFailure failure) {
    // Settle `viewState` off `SearchingState` first, so an async first-page error
    // can't leave the search spinner running indefinitely.
    dispatchState(Left(failure));
    loadingMoreStatus.value = LoadingMoreStatus.idle;

    // Urgent failures (re-login / reconnect / connection errors) are already
    // routed once by the executor's consume seam (ADR-0103); here we only detect
    // them — without routing again — to skip the destructive retry UI, since the
    // shared handler owns the screen.
    if (isUrgentException(failure)) return;

    mailboxDashBoardController.updateRefreshAllEmailState(Left(RefreshAllEmailFailure()));
    mailboxDashBoardController.emailsInCurrentMailbox.clear();
    showRetryToast(failure);
  }

  /// Handles a load-more that never started because session/account is missing.
  /// Keep the page and allow retry, matching [LoadMoreState.failure].
  void _handleSearchMoreEmailFailure() {
    loadingMoreStatus.value = LoadingMoreStatus.completed;
  }

  SearchEmailFailure _asSearchEmailFailure(Object? error) {
    if (error is SearchEmailFailure) return error;
    if (error is FeatureFailure) return SearchEmailFailure(error.exception);
    return SearchEmailFailure(error);
  }
}
