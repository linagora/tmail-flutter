import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/folder_paging.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/loading_more_status.dart';

sealed class FolderLoadMoreState {
  const FolderLoadMoreState();
}

/// No page request is running, and none has finished since the list was last
/// reset or the running one was stopped.
final class FolderLoadMoreIdle extends FolderLoadMoreState {
  const FolderLoadMoreIdle();
}

/// No page request is running, and the last one finished, loaded or failed.
final class FolderLoadMoreDone extends FolderLoadMoreState {
  const FolderLoadMoreDone();
}

/// A page request is running. Only a response carrying [token] is applied.
final class FolderLoadMoreInFlight extends FolderLoadMoreState {
  const FolderLoadMoreInFlight(this.token);

  final Object token;
}

/// A refresh is replacing the list, so no page is requested until it lands.
/// [pending] records that a page was asked for, or dropped, meanwhile.
final class FolderLoadMoreDeferred extends FolderLoadMoreState {
  const FolderLoadMoreDeferred({required this.pending});

  final bool pending;
}

/// Where a page request starts, and the token its response must carry.
class FolderLoadMoreRequest {
  const FolderLoadMoreRequest._(this.token, this.cursor);

  final Object token;

  final FolderPageCursor cursor;
}

/// Load-more lifecycle of a folder list.
///
/// | From      | Event                 | To                  |
/// |-----------|-----------------------|---------------------|
/// | Idle/Done | [begin], [hasMore]    | InFlight (new token)|
/// | Idle/Done | [begin], no more      | unchanged           |
/// | InFlight  | [begin]               | InFlight            |
/// | Deferred  | [begin]               | Deferred, pending   |
/// | any       | [pageLoaded]          | Done                |
/// | any       | [pageFailed]          | Done                |
/// | InFlight  | [abort]               | Idle                |
/// | any       | [resetList]           | Idle                |
/// | not held  | [listLoadedFromTop]   | Idle                |
/// | any       | [holdForRefresh]      | Deferred            |
/// | Deferred  | [releaseAfterRefresh] | Idle                |
///
/// Leaving InFlight drops its token, so a late response is not applied.
///
/// [paging] follows [collapseThreads] on every read: collapsed threads page by
/// position, other lists by date.
class FolderLoadMore {
  FolderLoadMore({required bool Function() collapseThreads})
      : _collapseThreads = collapseThreads;

  final bool Function() _collapseThreads;
  final _pagingByPosition = FolderPagingByPosition();
  final _pagingByDate = FolderPagingByDate();

  FolderLoadMoreState _state = const FolderLoadMoreIdle();

  /// Whether the folder may hold more emails than the list shows.
  bool hasMore = true;

  FolderLoadMoreState get state => _state;

  FolderPaging get paging =>
      _collapseThreads() ? _pagingByPosition : _pagingByDate;

  LoadingMoreStatus get status => switch (_state) {
        FolderLoadMoreIdle() => LoadingMoreStatus.idle,
        FolderLoadMoreDone() => LoadingMoreStatus.completed,
        FolderLoadMoreInFlight() => LoadingMoreStatus.running,
        FolderLoadMoreDeferred() => LoadingMoreStatus.idle,
      };

  /// Starts a page request after [listed], or returns null when no request
  /// should be sent now.
  FolderLoadMoreRequest? begin(List<PresentationEmail> listed) {
    switch (_state) {
      case FolderLoadMoreInFlight():
        return null;
      case FolderLoadMoreDeferred():
        _state = const FolderLoadMoreDeferred(pending: true);
        return null;
      case FolderLoadMoreIdle() || FolderLoadMoreDone():
        if (!hasMore) return null;
        final token = Object();
        _state = FolderLoadMoreInFlight(token);
        return FolderLoadMoreRequest._(token, paging.cursorAfter(listed));
    }
  }

  bool accepts(Object token) {
    final state = _state;
    return state is FolderLoadMoreInFlight && identical(state.token, token);
  }

  void pageLoaded({required int serverCount, required int appendedCount}) {
    _state = const FolderLoadMoreDone();
    hasMore = paging.pageLoaded(
      serverCount: serverCount,
      appendedCount: appendedCount,
    );
  }

  void pageFailed() {
    _state = const FolderLoadMoreDone();
    hasMore = true;
  }

  /// An error stopped the running request.
  void abort() {
    if (_state is FolderLoadMoreInFlight) {
      _state = const FolderLoadMoreIdle();
    }
  }

  /// The list is being loaded again from the top.
  void resetList() {
    _state = const FolderLoadMoreIdle();
    _resetPaging();
  }

  /// The list now holds the first server rows. A page requested against the
  /// previous rows is dropped; a hold stays until its refresh ends.
  void listLoadedFromTop() {
    if (_state is FolderLoadMoreDeferred) return;
    resetList();
  }

  /// A refresh is loading the list again from the top.
  void holdForRefresh() {
    final state = _state;
    final pending = state is FolderLoadMoreInFlight ||
        (state is FolderLoadMoreDeferred && state.pending);
    _state = FolderLoadMoreDeferred(pending: pending);
    _resetPaging();
  }

  /// Ends a hold. Returns whether a page was asked for, or dropped, during it.
  bool releaseAfterRefresh() {
    final state = _state;
    if (state is! FolderLoadMoreDeferred) return false;
    _state = const FolderLoadMoreIdle();
    return state.pending;
  }

  /// Both pagings reset, so switching mode later starts from the top too.
  void _resetPaging() {
    _pagingByPosition.reset();
    _pagingByDate.reset();
  }
}
