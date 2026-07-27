part of 'thread_controller.dart';

class ThreadSearchExecutionObserver implements SearchExecutionObserver {
  final ThreadController _controller;

  ThreadSearchExecutionObserver(this._controller);

  // The thread list owns search results only in the web desktop layout, where
  // it renders them inline (across both the thread and threadDetailed routes).
  // On small screens the dedicated SearchEmailView owns them, so the thread must
  // ignore executor events dispatched by SearchEmailController to avoid mutating
  // the off-screen mailbox list and emitting duplicate toasts. This mirrors the
  // layout's own ownership predicate (see MailboxDashBoardView web build).
  bool get _ownsSearchResults {
    final context = currentContext;
    return context != null && _controller.responsiveUtils.isWebDesktop(context);
  }

  @override
  void onNewSearchStarted() {
    if (!_ownsSearchResults) return;
    if (_controller.listEmailController.hasClients) {
      _controller.isListEmailScrollViewJumping = true;
      _controller.listEmailController.jumpTo(0);
    }
    _controller.mailboxDashBoardController.emailsInCurrentMailbox.clear();
    appProviderContainer
        .read(searchEmailPresentationProvider.notifier)
        .resetSearchMore();
    _controller.loadingMoreStatus.value = LoadingMoreStatus.idle;
    _controller.searchController.activateSimpleSearch();
  }

  @override
  void onSearchLoading() {
    if (!_ownsSearchResults) return;
    _controller.dispatchState(Right(SearchingState()));
  }

  @override
  void onSearchResult(
    SearchEmailResult result, {
    required bool isFreshResult,
  }) {
    if (!_ownsSearchResults) return;
    _controller.mailboxDashBoardController
        .updateRefreshAllEmailState(Right(RefreshAllEmailSuccess()));
    final emailList = result.emails;
    log('ThreadController::onSearchResult: COUNT = ${emailList.length}');
    final syncedEmails = emailList
        .map((email) => email.toSearchPresentationEmail(
            _controller.mailboxDashBoardController.mapMailboxById))
        .toList()
        .combine(_controller.mailboxDashBoardController.emailsInCurrentMailbox)
        .syncPresentationEmail(
          mapMailboxById:
              _controller.mailboxDashBoardController.mapMailboxById,
          selectedMailbox: _controller.selectedMailbox,
          searchQuery: _controller.searchController.searchQuery,
          isSearchEmailRunning: _controller.isSearchActive,
        );
    _controller.mailboxDashBoardController.updateEmailList(syncedEmails);
    // Leave the loading state the spinner watches (SearchingState set by
    // onSearchLoading), otherwise ThreadViewLoadingBarWidget spins forever.
    _controller.dispatchState(Right(SearchEmailSuccess(syncedEmails)));
    if (_controller.mailboxDashBoardController.isSelectionEnabled()) {
      _controller.mailboxDashBoardController.listEmailSelected.value =
          _controller.listEmailSelected;
    }

    appProviderContainer
        .read(searchEmailPresentationProvider.notifier)
        .setCanSearchMore(result.canLoadMore);
    _controller.loadingMoreStatus.value =
        result.loadMore == LoadMoreState.inProgress
            ? LoadingMoreStatus.running
            : LoadingMoreStatus.completed;
    if (result.loadMore != LoadMoreState.idle) return;
    if (!result.canLoadMore) return;
    if (!_controller._isAutoLoadMore) return;
    _controller._performAutomaticallyLoadMoreEmails();
  }

  @override
  void onSearchFailure(Object error) {
    if (!_ownsSearchResults) return;
    final failure = asSearchEmailFailure(error);
    _controller.mailboxDashBoardController
        .updateRefreshAllEmailState(Left(RefreshAllEmailFailure()));
    appProviderContainer
        .read(searchEmailPresentationProvider.notifier)
        .setCanSearchMore(false);
    _controller.loadingMoreStatus.value = LoadingMoreStatus.idle;
    _controller.mailboxDashBoardController.emailsInCurrentMailbox.clear();
    // Clear the loading state so the spinner stops on a failed search too.
    _controller.dispatchState(Left(failure));
    _controller.showRetryToast(failure);
  }
}
