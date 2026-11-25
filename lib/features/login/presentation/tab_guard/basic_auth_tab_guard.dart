import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/caching/utils/sign_out_marker_storage.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/composer_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/authentication_info_cache_manager.dart';
import 'package:tmail_ui_user/features/login/presentation/tab_guard/tab_guard_browser.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';

/// Web basic auth: once another tab signed out, this tab must stop using its
/// copy of the login and leave. It never clears shared data (Hive, marker,
/// composer snapshots): another tab may already be signed in again.
class BasicAuthTabGuard {
  final AuthenticationInfoCacheManager _cacheManager;
  final TabGuardBrowser _browser;
  final void Function() _saveOpenComposers;

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _hasLeft = false;

  BasicAuthTabGuard(
    this._cacheManager,
    this._browser,
    this._saveOpenComposers,
  );

  factory BasicAuthTabGuard.forApp() => BasicAuthTabGuard(
        Get.find<AuthenticationInfoCacheManager>(),
        WebTabGuardBrowser(),
        _saveComposersIfDashboardExists,
      );

  static void _saveComposersIfDashboardExists() {
    if (Get.isRegistered<ComposerManager>()) {
      Get.find<ComposerManager>().saveAllReloadSnapshots();
    }
    // Drafts are saved, so the dashboard beforeunload must not ask to stay.
    if (Get.isRegistered<TwakeAppManager>()) {
      Get.find<TwakeAppManager>().setExecutingBeforeReconnect(true);
    }
  }

  void start() {
    if (!PlatformInfo.isWeb || _subscriptions.isNotEmpty) return;
    _cacheManager.adoptInheritedTabTag();
    checkAndLeaveIfRevoked();
    _subscriptions
      ..add(_browser.storageEventKeys.listen(_onStorageEvent))
      ..add(_browser.pageActivations.listen((_) => checkAndLeaveIfRevoked()));
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  /// Called from inside request handling: only schedules, never works inline.
  void onRevokedRequest() => scheduleMicrotask(checkAndLeaveIfRevoked);

  // EML preview content also writes to localStorage, so only the marker key counts.
  void _onStorageEvent(String? key) {
    if (key == null || key == SignOutMarkerStorage.markerKey) {
      checkAndLeaveIfRevoked();
    }
  }

  void checkAndLeaveIfRevoked() {
    if (_hasLeft || !_cacheManager.isLoginRevokedInThisTab()) return;
    _hasLeft = true;
    _leave();
  }

  void _leave() {
    try {
      _cacheManager.dropLoginCopyInThisTab();
      if (_browser.isEmlPreviewRoute && _browser.tryCloseTab()) return;
      _saveOpenComposers();
    } catch (e) {
      logWarning('$runtimeType::_leave: $e');
    }
    _browser.replaceWithLoginPage();
  }
}

/// Request-time probe for the interceptors: also wakes the guard, which does the leaving.
bool isBasicLoginRevokedAndNotifyGuard() {
  final revoked = Get.find<AuthenticationInfoCacheManager>().isLoginRevokedInThisTab();
  if (revoked && Get.isRegistered<BasicAuthTabGuard>()) {
    Get.find<BasicAuthTabGuard>().onRevokedRequest();
  }
  return revoked;
}
