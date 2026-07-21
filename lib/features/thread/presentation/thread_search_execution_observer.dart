part of 'thread_controller.dart';

class ThreadSearchExecutionObserver implements SearchExecutionObserver {
  final ThreadController _controller;

  ThreadSearchExecutionObserver(this._controller);

  @override
  void onNewSearchStarted() {
    if (_controller.listEmailController.hasClients) {
      _controller.isListEmailScrollViewJumping = true;
      _controller.listEmailController.jumpTo(0);
    }
    _controller.mailboxDashBoardController.emailsInCurrentMailbox.clear();
    _controller.canSearchMore = true;
    _controller.loadingMoreStatus.value = LoadingMoreStatus.idle;
    _controller.searchController.activateSimpleSearch();
  }

  @override
  void onSearchLoading() => _controller.dispatchState(Right(SearchingState()));

  @override
  void onSearchResult(
    SearchEmailResult result, {
    required bool isFreshResult,
  }) {
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
    if (_controller.mailboxDashBoardController.isSelectionEnabled()) {
      _controller.mailboxDashBoardController.listEmailSelected.value =
          _controller.listEmailSelected;
    }

    _controller.canSearchMore = result.canLoadMore;
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
    // Urgent failures are already routed by the executor's consume seam.
    if (isUrgentException(error)) return;
    _controller.mailboxDashBoardController
        .updateRefreshAllEmailState(Left(RefreshAllEmailFailure()));
    _controller.canSearchMore = false;
    _controller.loadingMoreStatus.value = LoadingMoreStatus.idle;
    _controller.mailboxDashBoardController.emailsInCurrentMailbox.clear();
    _controller.showRetryToast(asSearchEmailFailure(error));
  }
}
