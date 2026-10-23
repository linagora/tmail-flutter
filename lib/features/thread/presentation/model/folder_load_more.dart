import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/loading_more_status.dart';

sealed class FolderLoadMoreState {
  const FolderLoadMoreState();
}

/// No page request is running. [status] is what the list shows: `idle` after
/// a reset, `completed` after a page or a failed page.
final class FolderLoadMoreIdle extends FolderLoadMoreState {
  const FolderLoadMoreIdle(this.status);

  final LoadingMoreStatus status;
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
  const FolderLoadMoreRequest._(this.token, {this.position, this.oldestEmail});

  final Object token;

  /// Server rows to skip, when collapsed threads page by offset.
  final int? position;

  /// Listed email whose `receivedAt` bounds the page, when paging by date.
  final PresentationEmail? oldestEmail;
}

/// Load-more lifecycle of a folder list.
///
/// | From     | Event                 | To                  |
/// |----------|-----------------------|---------------------|
/// | Idle     | [begin], [hasMore]    | InFlight (new token)|
/// | Idle     | [begin], no more      | Idle                |
/// | InFlight | [begin]               | InFlight            |
/// | Deferred | [begin]               | Deferred, pending   |
/// | any      | [pageLoaded]          | Idle(completed)     |
/// | any      | [pageFailed]          | Idle(completed)     |
/// | InFlight | [abort]               | Idle(idle)          |
/// | any      | [resetList]           | Idle(idle)          |
/// | not held | [listLoadedFromTop]   | Idle(idle)          |
/// | any      | [holdForRefresh]      | Deferred            |
/// | Deferred | [releaseAfterRefresh] | Idle(idle)          |
///
/// Leaving InFlight drops its token, so a late response is not applied.
///
/// Paging: a collapsed row stands for a whole thread whose emails have
/// different dates, so a date cursor would match older emails of listed
/// threads. Collapsed lists page by offset: `position` = listed rows + server
/// rows skipped since the list was last loaded from the top. A skipped row is
/// a duplicate of a listed thread (pushed down by new threads above it) or an
/// email that does not belong in the list; either way it took a server slot.
/// Other lists page by date, which new emails on top cannot shift.
class FolderLoadMore {
  FolderLoadMoreState _state = const FolderLoadMoreIdle(LoadingMoreStatus.idle);
  int _skippedRows = 0;

  /// Whether the folder may hold more emails than the list shows.
  bool hasMore = true;

  FolderLoadMoreState get state => _state;

  LoadingMoreStatus get status => switch (_state) {
        FolderLoadMoreIdle(:final status) => status,
        FolderLoadMoreInFlight() => LoadingMoreStatus.running,
        FolderLoadMoreDeferred() => LoadingMoreStatus.idle,
      };

  /// Starts a page request after [listed], or returns null when no request
  /// should be sent now.
  FolderLoadMoreRequest? begin(
    List<PresentationEmail> listed, {
    required bool collapseThreads,
  }) {
    switch (_state) {
      case FolderLoadMoreInFlight():
        return null;
      case FolderLoadMoreDeferred():
        _state = const FolderLoadMoreDeferred(pending: true);
        return null;
      case FolderLoadMoreIdle():
        if (!hasMore) return null;
        final token = Object();
        _state = FolderLoadMoreInFlight(token);
        return collapseThreads
            ? FolderLoadMoreRequest._(token, position: listed.length + _skippedRows)
            : FolderLoadMoreRequest._(token, oldestEmail: listed.lastOrNull);
    }
  }

  bool accepts(Object token) {
    final state = _state;
    return state is FolderLoadMoreInFlight && identical(state.token, token);
  }

  void pageLoaded({
    required int serverCount,
    required int appendedCount,
    required bool collapseThreads,
  }) {
    _state = const FolderLoadMoreIdle(LoadingMoreStatus.completed);
    final isFullPage = serverCount >= ThreadConstants.maxCountEmails;
    if (collapseThreads) {
      // The offset moves past every server row, appended or not, so a page
      // of duplicates still makes progress.
      _skippedRows += serverCount - appendedCount;
      hasMore = isFullPage;
    } else {
      // Without an appended email the date cursor does not move, so another
      // request would repeat the same page forever.
      hasMore = appendedCount > 0 && isFullPage;
    }
  }

  void pageFailed() {
    _state = const FolderLoadMoreIdle(LoadingMoreStatus.completed);
    hasMore = true;
  }

  /// An error stopped the running request.
  void abort() {
    if (_state is FolderLoadMoreInFlight) {
      _state = const FolderLoadMoreIdle(LoadingMoreStatus.idle);
    }
  }

  /// The list is being loaded again from the top.
  void resetList() {
    _state = const FolderLoadMoreIdle(LoadingMoreStatus.idle);
    _skippedRows = 0;
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
    _skippedRows = 0;
  }

  /// Ends a hold. Returns whether a page was asked for, or dropped, during it.
  bool releaseAfterRefresh() {
    final state = _state;
    if (state is! FolderLoadMoreDeferred) return false;
    _state = const FolderLoadMoreIdle(LoadingMoreStatus.idle);
    return state.pending;
  }
}
