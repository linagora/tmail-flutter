import 'package:core/utils/app_logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

typedef SentryScopeSynchronizer = Future<void> Function(
  SentryUser? user, {
  required bool clearBreadcrumbs,
});

/// Remembers the latest user identity and serializes synchronization with the
/// Sentry SDK scope.
class SentryUserScopeCoordinator {
  final SentryScopeSynchronizer _synchronizeScope;

  SentryUser? _user;
  Future<void> _pendingSynchronization = Future.value();
  int _latestRequestedGeneration = 0;
  int _latestSynchronizedGeneration = 0;

  SentryUserScopeCoordinator({
    required SentryScopeSynchronizer synchronizeScope,
  }) : _synchronizeScope = synchronizeScope;

  Future<void> get pendingSynchronization => _pendingSynchronization;

  bool get isSynchronized =>
      _latestRequestedGeneration == _latestSynchronizedGeneration;

  SentryUser? userForScope({required bool shouldReport}) =>
      shouldReport ? _user : null;

  void setUser(SentryUser user) {
    _user = user;
  }

  void clearUser() {
    _user = null;
  }

  void synchronize({
    required bool isSentryAvailable,
    required bool shouldReport,
  }) {
    if (!isSentryAvailable) return;

    final synchronizationGeneration = ++_latestRequestedGeneration;
    final user = userForScope(shouldReport: shouldReport);
    final clearBreadcrumbs = !shouldReport;
    _pendingSynchronization = _pendingSynchronization.then((_) async {
      final isSynchronized = await _synchronize(
        user,
        clearBreadcrumbs: clearBreadcrumbs,
      );
      if (isSynchronized) {
        _latestSynchronizedGeneration = synchronizationGeneration;
      }
    });
  }

  Future<bool> _synchronize(
    SentryUser? user, {
    required bool clearBreadcrumbs,
  }) async {
    try {
      await _synchronizeScope(
        user,
        clearBreadcrumbs: clearBreadcrumbs,
      );
      log(
        '[SentryUserScopeCoordinator] User scope '
        '${user == null ? 'cleared' : 'set'}',
      );
      return true;
    } catch (e) {
      logWarning(
        '[SentryUserScopeCoordinator] Sync user scope failed. Exception: $e',
      );
      return false;
    }
  }
}
