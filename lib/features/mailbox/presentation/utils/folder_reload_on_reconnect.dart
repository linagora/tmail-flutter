import 'dart:async';

import 'package:flutter/foundation.dart';

/// Loads the folders again each time the internet is back, until a load succeeds.
class FolderReloadOnReconnect {
  FolderReloadOnReconnect(Stream<void> onInternetRestored, this._reload) {
    _subscription = onInternetRestored.listen((_) => _onInternetRestored());
  }

  final VoidCallback _reload;
  late final StreamSubscription<void> _subscription;
  bool _isLoadFailed = false;

  void markLoadFailed() => _isLoadFailed = true;

  void markLoaded() => _isLoadFailed = false;

  void _onInternetRestored() {
    if (_isLoadFailed) _reload();
  }

  Future<void> dispose() => _subscription.cancel();
}
