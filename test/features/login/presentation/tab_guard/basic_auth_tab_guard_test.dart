import 'dart:async';

import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/caching/utils/sign_out_marker_storage.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/composer_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/authentication_info_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';
import 'package:tmail_ui_user/features/login/presentation/tab_guard/basic_auth_tab_guard.dart';
import 'package:tmail_ui_user/features/login/presentation/tab_guard/tab_guard_browser.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';

import '../../data/local/authentication_info_cache_test_doubles.dart';

class FakeTabGuardBrowser implements TabGuardBrowser {
  final storageKeys = StreamController<String?>.broadcast(sync: true);
  final activations = StreamController<void>.broadcast(sync: true);
  final List<String> calls;
  @override
  bool isEmlPreviewRoute = false;
  bool closeSucceeds = true;

  FakeTabGuardBrowser(this.calls);

  @override
  Stream<String?> get storageEventKeys => storageKeys.stream;

  @override
  Stream<void> get pageActivations => activations.stream;

  @override
  bool tryCloseTab() {
    calls.add('close');
    return closeSucceeds;
  }

  @override
  void replaceWithLoginPage() => calls.add('login');
}

class _FakeComposerManager extends ComposerManager {
  int savedAll = 0;

  @override
  void saveAllReloadSnapshots() => savedAll++;
}

void main() {
  const loginKey = AuthenticationInfoCache.keyCacheValue;
  const tagKey = AuthenticationInfoCacheManager.signOutTagKey;
  const markerKey = SignOutMarkerStorage.markerKey;

  late FakeHiveLoginBox hive;
  late FakeSignOutMarkerStorage marker;
  late FakeSessionStorage session;
  late AuthenticationInfoCacheManager manager;
  late FakeTabGuardBrowser browser;
  late BasicAuthTabGuard guard;
  late List<String> calls;

  AuthenticationInfoCacheManager newTab(FakeSessionStorage storage) =>
      AuthenticationInfoCacheManager(
        hive.mock,
        storage,
        secureStorage: const FlutterSecureStorage(),
        markerStorage: marker,
      );

  setUp(() async {
    PlatformInfo.isTestingForWeb = true;
    FlutterSecureStorage.setMockInitialValues({});
    hive = FakeHiveLoginBox();
    marker = FakeSignOutMarkerStorage();
    session = FakeSessionStorage();
    manager = newTab(session);
    await manager.storeAuthenticationInfo(AuthenticationInfoCache('alice@example.com', 'alice'));
    calls = [];
    browser = FakeTabGuardBrowser(calls);
    guard = BasicAuthTabGuard(manager, browser, () => calls.add('save'))..start();
  });

  tearDown(() {
    guard.dispose();
    PlatformInfo.isTestingForWeb = false;
  });

  // Another tab signs out: it replaces the shared marker.
  void signOutElsewhere() => marker.value = 'rotated-by-other-tab';

  test('revoked: drops only the login copy, saves composers, then goes to login', () {
    session.values['composerSnapshot'] = 'draft';
    signOutElsewhere();

    browser.storageKeys.add(markerKey);

    expect(calls, ['save', 'login']);
    expect(session.values.containsKey(loginKey), isFalse);
    expect(session.values.containsKey(tagKey), isFalse);
    expect(session.values['composerSnapshot'], 'draft');
  });

  test('never touches Hive or the shared marker', () {
    signOutElsewhere();
    final clearsBefore = hive.clearCalls;

    browser.storageKeys.add(markerKey);

    expect(hive.clearCalls, clearsBefore);
    expect(marker.value, 'rotated-by-other-tab');
  });

  test('leaves once even when several signals arrive', () async {
    signOutElsewhere();

    browser.storageKeys.add(markerKey);
    browser.storageKeys.add(null);
    browser.activations.add(null);
    guard.onRevokedRequest();
    guard.onRevokedRequest();
    await Future<void>.delayed(Duration.zero);

    expect(calls.where((c) => c == 'login'), hasLength(1));
    expect(calls.where((c) => c == 'save'), hasLength(1));
  });

  test('not revoked: nothing happens on any signal', () async {
    browser.storageKeys.add(markerKey);
    browser.storageKeys.add(null);
    browser.activations.add(null);
    guard.onRevokedRequest();
    await Future<void>.delayed(Duration.zero);

    expect(calls, isEmpty);
    expect(session.values.containsKey(loginKey), isTrue);
  });

  test('storage event for another key is ignored', () {
    signOutElsewhere();

    browser.storageKeys.add('emlPreviewContent');

    expect(calls, isEmpty);
  });

  test('cleared storage (null key) triggers a check', () {
    signOutElsewhere();

    browser.storageKeys.add(null);

    expect(calls, ['save', 'login']);
  });

  test('page becoming active triggers a check', () {
    signOutElsewhere();

    browser.activations.add(null);

    expect(calls, ['save', 'login']);
  });

  test('revoked request schedules the check instead of running it inline', () async {
    signOutElsewhere();

    guard.onRevokedRequest();
    expect(calls, isEmpty);

    await Future<void>.delayed(Duration.zero);
    expect(calls, ['save', 'login']);
  });

  test('EML preview tab closes first and stops when the tab is gone', () {
    browser.isEmlPreviewRoute = true;
    signOutElsewhere();

    browser.storageKeys.add(markerKey);

    expect(calls, ['close']);
  });

  test('EML preview tab that stays open continues to the login page', () {
    browser
      ..isEmlPreviewRoute = true
      ..closeSucceeds = false;
    signOutElsewhere();

    browser.storageKeys.add(markerKey);

    expect(calls, ['close', 'save', 'login']);
  });

  test('the tab that signs out is not kicked by its own marker change', () {
    manager.revokeOtherTabs();

    browser.storageKeys.add(markerKey);
    browser.activations.add(null);
    guard.onRevokedRequest();

    expect(calls, isEmpty);
    expect(session.values.containsKey(loginKey), isTrue);
  });

  test('another tab signing out does not kick a tab that logged in afterwards', () async {
    signOutElsewhere();
    final fresh = newTab(FakeSessionStorage());
    await fresh.storeAuthenticationInfo(AuthenticationInfoCache('bob@example.com', 'bob'));

    expect(fresh.isLoginRevokedInThisTab(), isFalse);
  });

  test('a tab that never read its inherited login still leaves after a sign out elsewhere', () {
    final childSession = FakeSessionStorage()..values.addAll(session.values);
    final childGuard = BasicAuthTabGuard(newTab(childSession), browser, () => calls.add('save'))..start();
    addTearDown(childGuard.dispose);
    guard.dispose();
    browser.isEmlPreviewRoute = true;
    signOutElsewhere();

    browser.storageKeys.add(markerKey);

    expect(calls, ['close']);
    expect(childSession.values.containsKey(loginKey), isFalse);
    expect(childSession.values.containsKey(tagKey), isFalse);
  });

  test('a restored tab with a stale copy leaves once at start, not again on activation', () async {
    signOutElsewhere();
    final restoredSession = FakeSessionStorage()..values.addAll(session.values);
    final restoredCalls = <String>[];
    final restoredBrowser = FakeTabGuardBrowser(restoredCalls);
    final restoredGuard = BasicAuthTabGuard(
      newTab(restoredSession), restoredBrowser, () => restoredCalls.add('save'))..start();
    addTearDown(restoredGuard.dispose);

    expect(restoredCalls, ['save', 'login']);
    expect(restoredSession.values.containsKey(loginKey), isFalse);

    restoredBrowser.activations.add(null);

    expect(restoredCalls, ['save', 'login']);
  });

  test('a tab without any login is never kicked', () {
    final emptyGuard = BasicAuthTabGuard(newTab(FakeSessionStorage()), browser, () => calls.add('save'))..start();
    addTearDown(emptyGuard.dispose);
    guard.dispose();
    signOutElsewhere();

    browser.storageKeys.add(markerKey);

    expect(calls, isEmpty);
  });

  group('isBasicLoginRevokedAndNotifyGuard', () {
    setUp(() {
      Get.put<AuthenticationInfoCacheManager>(manager);
      Get.put<BasicAuthTabGuard>(guard);
    });

    tearDown(Get.reset);

    test('not revoked: false and the guard stays idle', () async {
      expect(isBasicLoginRevokedAndNotifyGuard(), isFalse);
      await Future<void>.delayed(Duration.zero);

      expect(calls, isEmpty);
    });

    test('revoked: true and the guard leaves', () async {
      signOutElsewhere();

      expect(isBasicLoginRevokedAndNotifyGuard(), isTrue);
      await Future<void>.delayed(Duration.zero);

      expect(calls, ['save', 'login']);
    });
  });

  test('forApp: a kicked tab skips the dashboard leave prompt', () {
    final twakeAppManager = TwakeAppManager()..setHasComposer(true);
    Get.put<AuthenticationInfoCacheManager>(manager);
    Get.put<TwakeAppManager>(twakeAppManager);
    addTearDown(Get.reset);
    final appGuard = BasicAuthTabGuard.forApp();
    signOutElsewhere();

    appGuard.checkAndLeaveIfRevoked();

    expect(twakeAppManager.isExecutingBeforeReconnect, isTrue);
  });

  test('forApp: a kicked tab saves the open composers before it leaves', () {
    Get.put(ResponsiveUtils());
    final composerManager = _FakeComposerManager();
    Get.put<ComposerManager>(composerManager);
    Get.put<AuthenticationInfoCacheManager>(manager);
    addTearDown(Get.reset);
    final appGuard = BasicAuthTabGuard.forApp();
    signOutElsewhere();

    appGuard.checkAndLeaveIfRevoked();

    expect(composerManager.savedAll, 1);
  });

  test('inert when not on web', () {
    guard.dispose();
    PlatformInfo.isTestingForWeb = false;
    signOutElsewhere();
    final inert = BasicAuthTabGuard(manager, browser, () => calls.add('save'))..start();

    browser.storageKeys.add(markerKey);
    inert.checkAndLeaveIfRevoked();

    expect(calls, isEmpty);
  });
}
