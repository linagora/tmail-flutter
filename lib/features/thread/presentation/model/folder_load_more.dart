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
/// | any      | [holdForRefresh]      | Deferred            |
/// | Deferred | [releaseAfterRefresh] | Idle(idle)          |
///
/// Leaving InFlight drops its token, so a late response is not applied.
class FolderLoadMore {
  FolderLoadMoreState _state = const FolderLoadMoreIdle(LoadingMoreStatus.idle);

  /// Whether the folder may hold more emails than the list shows.
  bool hasMore = true;

  FolderLoadMoreState get state => _state;

  LoadingMoreStatus get status => switch (_state) {
        FolderLoadMoreIdle(:final status) => status,
        FolderLoadMoreInFlight() => LoadingMoreStatus.running,
        FolderLoadMoreDeferred() => LoadingMoreStatus.idle,
      };

  /// Starts a page request and returns its token, or returns null when no
  /// request should be sent now.
  Object? begin() {
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
        return token;
    }
  }

  bool accepts(Object token) {
    final state = _state;
    return state is FolderLoadMoreInFlight && identical(state.token, token);
  }

  void pageLoaded({required int serverCount, required int appendedCount}) {
    _state = const FolderLoadMoreIdle(LoadingMoreStatus.completed);
    // Without an appended email the date cursor does not move, so another
    // request would repeat the same page forever.
    hasMore = appendedCount > 0 && serverCount >= ThreadConstants.maxCountEmails;
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
  }

  void holdForRefresh() {
    final state = _state;
    final pending = state is FolderLoadMoreInFlight ||
        (state is FolderLoadMoreDeferred && state.pending);
    _state = FolderLoadMoreDeferred(pending: pending);
  }

  /// Ends a hold. Returns whether a page was asked for, or dropped, during it.
  bool releaseAfterRefresh() {
    final state = _state;
    if (state is! FolderLoadMoreDeferred) return false;
    _state = const FolderLoadMoreIdle(LoadingMoreStatus.idle);
    return state.pending;
  }
}
