enum CollapsedOverlapDecision { resync, continueWithBias, stop }

sealed class CollapsedOverlapPolicy {
  const CollapsedOverlapPolicy();
}

final class CollapsedOverlapIdle extends CollapsedOverlapPolicy {
  const CollapsedOverlapIdle();
}

final class CollapsedOverlapResynced extends CollapsedOverlapPolicy {
  const CollapsedOverlapResynced(this.listedCount);

  final int listedCount;

  @override
  bool operator ==(Object other) =>
      other is CollapsedOverlapResynced && other.listedCount == listedCount;

  @override
  int get hashCode => listedCount.hashCode;
}

final class CollapsedOverlapFailedOnce extends CollapsedOverlapPolicy {
  const CollapsedOverlapFailedOnce(this.listedCount);

  final int listedCount;

  @override
  bool operator ==(Object other) =>
      other is CollapsedOverlapFailedOnce && other.listedCount == listedCount;

  @override
  int get hashCode => listedCount.hashCode;
}

final class CollapsedOverlapGivenUp extends CollapsedOverlapPolicy {
  const CollapsedOverlapGivenUp();
}

class CollapsedFolderPager {
  CollapsedFolderPager() : token = Object();

  CollapsedFolderPager._({
    required this.token,
    required this.positionBias,
    required int? resyncedAtCount,
    required int? failedAtCount,
    required bool giveUp,
    Object? loadMoreOwner,
  }) : _resyncedAtCount = resyncedAtCount,
       _failedAtCount = failedAtCount,
       _giveUp = giveUp,
       _loadMoreOwner = loadMoreOwner;

  final Object token;
  int positionBias = 0;
  Object? _loadMoreOwner;
  int? _resyncedAtCount;
  int? _failedAtCount;
  bool _giveUp = false;

  bool isCurrent(Object token) => identical(this.token, token);

  bool get isLoadMoreOwner =>
      _loadMoreOwner == null || identical(_loadMoreOwner, token);

  CollapsedOverlapPolicy get policy {
    if (_giveUp) return const CollapsedOverlapGivenUp();
    if (_resyncedAtCount != null) {
      return CollapsedOverlapResynced(_resyncedAtCount!);
    }
    if (_failedAtCount != null) {
      return CollapsedOverlapFailedOnce(_failedAtCount!);
    }
    return const CollapsedOverlapIdle();
  }

  void claimLoadMore() {
    _loadMoreOwner = token;
  }

  CollapsedOverlapDecision onOverlappingPage(
    int listedCount, {
    required int cap,
    required int pageSize,
  }) {
    if (_giveUp) return CollapsedOverlapDecision.stop;
    if (listedCount >= cap) {
      positionBias += pageSize;
      return CollapsedOverlapDecision.continueWithBias;
    }
    if (_resyncedAtCount == listedCount) {
      return CollapsedOverlapDecision.stop;
    }
    _resyncedAtCount = listedCount;
    return CollapsedOverlapDecision.resync;
  }

  void onResyncFailed(int listedCount) {
    if (_failedAtCount == listedCount) {
      _giveUp = true;
      return;
    }
    _failedAtCount = listedCount;
    _resyncedAtCount = null;
  }

  void onRowsAppended() {
    _resyncedAtCount = null;
  }

  void abandonResync() {
    _resyncedAtCount = null;
  }

  CollapsedFolderPager replace({required bool keepGiveUp}) {
    return CollapsedFolderPager._(
      token: Object(),
      positionBias: 0,
      resyncedAtCount: null,
      failedAtCount: keepGiveUp ? _failedAtCount : null,
      giveUp: keepGiveUp && _giveUp,
      loadMoreOwner: _loadMoreOwner,
    );
  }
}
