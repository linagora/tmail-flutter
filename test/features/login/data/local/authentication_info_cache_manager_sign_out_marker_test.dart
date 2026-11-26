import 'package:core/utils/platform_info.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/login/data/local/authentication_info_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';

import 'authentication_info_cache_test_doubles.dart';

void main() {
  const key = AuthenticationInfoCacheManager.signOutTagKey;
  const loginKey = AuthenticationInfoCache.keyCacheValue;
  final info = AuthenticationInfoCache('alice@example.com', 'alice');

  late FakeHiveLoginBox hive;
  late FakeSignOutMarkerStorage marker;

  setUp(() {
    PlatformInfo.isTestingForWeb = true;
    FlutterSecureStorage.setMockInitialValues({});
    hive = FakeHiveLoginBox();
    marker = FakeSignOutMarkerStorage();
  });

  tearDown(() => PlatformInfo.isTestingForWeb = false);

  // Each manager + session storage pair models one browser tab sharing the same localStorage.
  (AuthenticationInfoCacheManager, FakeSessionStorage) newTab() {
    final session = FakeSessionStorage();
    final manager = AuthenticationInfoCacheManager(
      hive.mock,
      session,
      secureStorage: const FlutterSecureStorage(),
      markerStorage: marker,
    );
    return (manager, session);
  }

  // A tab opened by the app: the browser copies sessionStorage, the in-memory state is new.
  (AuthenticationInfoCacheManager, FakeSessionStorage) openChildTab(FakeSessionStorage parent) {
    final (manager, session) = newTab();
    session.values.addAll(parent.values);
    return (manager, session);
  }

  group('login store', () {
    test('creates the marker and tags the stored login with it', () async {
      final (manager, session) = newTab();

      await manager.storeAuthenticationInfo(info);

      expect(marker.value, isNotEmpty);
      expect(session.values[key], marker.value);
      expect(manager.isLoginRevokedInThisTab(), isFalse);
    });

    test('keeps an existing marker', () async {
      marker.value = 'existing';
      final (manager, session) = newTab();

      await manager.storeAuthenticationInfo(info);

      expect(marker.value, 'existing');
      expect(session.values[key], 'existing');
    });

    test('re-tags when another tab changed the marker during the login', () async {
      marker.replaceAfterNextWrite = 'other-tab';
      final (manager, session) = newTab();

      await manager.storeAuthenticationInfo(info);

      expect(marker.value, 'other-tab');
      expect(session.values[key], 'other-tab');
      expect(manager.isLoginRevokedInThisTab(), isFalse);
      expect(await manager.getAuthenticationInfoStored(), info);
    });

    test('does not write the password when the marker cannot be written', () async {
      marker.failWrites = true;
      final (manager, session) = newTab();

      await manager.storeAuthenticationInfo(info);

      expect(session.values.containsKey(loginKey), isFalse);
      expect(session.values.containsKey(key), isFalse);
      expect(await manager.getAuthenticationInfoStored(), info);
      expect(manager.isLoginRevokedInThisTab(), isFalse);
    });

    test('a failed marker write does not leave the previous login in session storage', () async {
      final (manager, session) = newTab();
      await manager.storeAuthenticationInfo(info);
      marker.value = null;
      marker.failWrites = true;

      await manager.storeAuthenticationInfo(AuthenticationInfoCache('bob@example.com', 'bob'));

      expect(session.values.containsKey(loginKey), isFalse);
      expect(manager.isLoginRevokedInThisTab(), isFalse);
    });
  });

  group('login read', () {
    test('a tag that differs from the marker deletes the copy and throws', () async {
      final (manager, session) = newTab();
      await manager.storeAuthenticationInfo(info);
      marker.value = 'rotated';
      hive.item = info;

      await expectLater(
        manager.getAuthenticationInfoStored(),
        throwsA(isA<NotFoundAuthenticationInfoCache>()),
      );

      expect(session.values.containsKey(loginKey), isFalse);
      expect(session.values.containsKey(key), isFalse);
      // Hive keeps its item: the legacy login is not consulted or moved.
      expect(hive.item, info);
      expect(hive.insertCalls, 0);
    });

    test('a missing marker is a mismatch', () async {
      final (manager, session) = newTab();
      await manager.storeAuthenticationInfo(info);
      marker.value = null;
      hive.item = info;

      await expectLater(
        manager.getAuthenticationInfoStored(),
        throwsA(isA<NotFoundAuthenticationInfoCache>()),
      );
      expect(session.values.containsKey(loginKey), isFalse);
    });

    test('a copy without a tag is a mismatch', () async {
      marker.value = 'current';
      final (manager, session) = newTab();
      session.values[loginKey] = '{"username":"alice@example.com","password":"alice"}';
      hive.item = info;

      await expectLater(
        manager.getAuthenticationInfoStored(),
        throwsA(isA<NotFoundAuthenticationInfoCache>()),
      );
      expect(session.values.containsKey(loginKey), isFalse);
      expect(hive.item, info);
    });

    test('a tab keeps reporting revoked after its copy was deleted', () async {
      final (manager, _) = newTab();
      await manager.storeAuthenticationInfo(info);
      marker.value = 'rotated';
      await manager.getAuthenticationInfoStored().then((_) {}, onError: (_) {});

      expect(manager.isLoginRevokedInThisTab(), isTrue);
    });
  });

  group('sign out', () {
    test('clear forgets the tag, so a later sign out elsewhere does not revoke this tab', () async {
      final (manager, _) = newTab();
      await manager.storeAuthenticationInfo(info);

      await manager.clear();
      marker.value = 'rotated-by-other-tab';

      expect(manager.isLoginRevokedInThisTab(), isFalse);
    });

    test('clear does not rotate the marker', () async {
      final (manager, _) = newTab();
      await manager.storeAuthenticationInfo(info);
      final before = marker.value;

      await manager.clear();

      expect(marker.value, before);
      expect(manager.isLoginRevokedInThisTab(), isFalse);
    });

    test('clear keeps another tab signed in', () async {
      final (tabA, sessionA) = newTab();
      await tabA.storeAuthenticationInfo(info);
      final (tabB, _) = openChildTab(sessionA);
      await tabB.getAuthenticationInfoStored();

      await tabA.clear();

      expect(await tabB.getAuthenticationInfoStored(), info);
      expect(tabB.isLoginRevokedInThisTab(), isFalse);
    });

    test('revokeOtherTabs rotates the marker and keeps the calling tab valid', () async {
      final (manager, session) = newTab();
      await manager.storeAuthenticationInfo(info);
      final before = marker.value;

      manager.revokeOtherTabs();

      expect(marker.value, isNot(before));
      expect(session.values[key], marker.value);
      expect(manager.isLoginRevokedInThisTab(), isFalse);
      expect(await manager.getAuthenticationInfoStored(), info);
    });

    test('revokeOtherTabs revokes another tab holding the old tag', () async {
      final (tabA, sessionA) = newTab();
      await tabA.storeAuthenticationInfo(info);
      final (tabB, sessionB) = openChildTab(sessionA);
      expect(await tabB.getAuthenticationInfoStored(), info);
      expect(tabB.isLoginRevokedInThisTab(), isFalse);

      tabA.revokeOtherTabs();

      expect(tabB.isLoginRevokedInThisTab(), isTrue);
      await expectLater(
        tabB.getAuthenticationInfoStored(),
        throwsA(isA<NotFoundAuthenticationInfoCache>()),
      );
      expect(sessionB.values.containsKey(loginKey), isFalse);
    });

    test('revokeOtherTabs removes the marker when the new one cannot be written', () async {
      final (tabA, sessionA) = newTab();
      await tabA.storeAuthenticationInfo(info);
      final (tabB, _) = openChildTab(sessionA);
      await tabB.getAuthenticationInfoStored();
      marker.failWrites = true;

      tabA.revokeOtherTabs();

      expect(marker.value, isNull);
      expect(tabB.isLoginRevokedInThisTab(), isTrue);
    });

    test('the signing-out tab can still send its own requests when the marker cannot be rewritten', () async {
      final (tabA, _) = newTab();
      await tabA.storeAuthenticationInfo(info);
      marker.failWrites = true;

      tabA.revokeOtherTabs();

      expect(tabA.isLoginRevokedInThisTab(), isFalse);
    });

    test('revokeOtherTabs rotates for a tab whose login lives only in memory', () async {
      marker.failWrites = true;
      final (manager, session) = newTab();
      await manager.storeAuthenticationInfo(info);
      marker.failWrites = false;
      marker.value = 'other-tab-login';

      manager.revokeOtherTabs();

      expect(marker.value, isNot('other-tab-login'));
      expect(session.values.containsKey(loginKey), isFalse);
    });

    test('revokeOtherTabs does nothing outside web', () async {
      final (manager, _) = newTab();
      await manager.storeAuthenticationInfo(info);
      final before = marker.value;
      PlatformInfo.isTestingForWeb = false;

      manager.revokeOtherTabs();

      expect(marker.value, before);
    });
  });

  group('isLoginRevokedInThisTab', () {
    test('is false when the tab has no login tag', () {
      marker.value = 'anything';
      final (manager, _) = newTab();

      expect(manager.isLoginRevokedInThisTab(), isFalse);
    });

    test('is false outside web even if the marker changed', () async {
      final (manager, _) = newTab();
      await manager.storeAuthenticationInfo(info);
      marker.value = 'rotated';
      PlatformInfo.isTestingForWeb = false;

      expect(manager.isLoginRevokedInThisTab(), isFalse);
    });

    test('is true when the marker changed or disappeared', () async {
      final (manager, _) = newTab();
      await manager.storeAuthenticationInfo(info);

      marker.value = 'rotated';
      expect(manager.isLoginRevokedInThisTab(), isTrue);

      marker.value = null;
      expect(manager.isLoginRevokedInThisTab(), isTrue);
    });
  });
}
