import 'dart:async';

import 'package:flutter/foundation.dart';

/// Loads the folders again each time the internet is back, until a load succeeds.
/// A restore during the first load reloads once if that load then fails.
class FolderReloadOnReconnect {
  FolderReloadOnReconnect(Stream<void> onInternetRestored, this._reload) {
    _subscription = onInternetRestored.listen((_) => _onInternetRestored());
  }

  final VoidCallback _reload;
  late final StreamSubscription<void> _subscription;
  // Null until the first load answers.
  bool? _isLoadFailed;
  bool _isRestoredBeforeFirstAnswer = false;

  void markLoadFailed() {
    _isLoadFailed = true;
    if (!_isRestoredBeforeFirstAnswer) return;
    _isRestoredBeforeFirstAnswer = false;
    _reload();
  }

  void markLoaded() {
    _isLoadFailed = false;
    _isRestoredBeforeFirstAnswer = false;
  }

  void _onInternetRestored() {
    if (_isLoadFailed == true) {
      _reload();
    } else if (_isLoadFailed == null) {
      // The launch load can still fail on the outage: reload once it answers.
      _isRestoredBeforeFirstAnswer = true;
    }
  }

  Future<void> dispose() => _subscription.cancel();
}
