import 'dart:convert';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tmail_ui_user/features/caching/clients/authentication_info_cache_client.dart';
import 'package:tmail_ui_user/features/caching/interaction/cache_manager_interaction.dart';
import 'package:tmail_ui_user/features/caching/utils/session_storage_manager.dart';
import 'package:tmail_ui_user/features/caching/utils/sign_out_marker_storage.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:uuid/uuid.dart';

class AuthenticationInfoCacheManager extends CacheManagerInteraction {
  static const String _usernameField = 'username';
  static const String _passwordField = 'password';
  static const String _key = AuthenticationInfoCache.keyCacheValue;

  /// Web: sessionStorage key holding the sign-out marker this tab logged in under.
  static const String signOutTagKey = 'basicAuthSignOutTag';

  // Own iOS service: KeychainSharingManager.delete() calls deleteAll() on the shared one.
  static const FlutterSecureStorage defaultSecureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accountName: 'tmail_auth_info_store',
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final AuthenticationInfoCacheClient _authenticationInfoCacheClient;
  final SessionStorageManager _sessionStorageManager;
  final FlutterSecureStorage _secureStorage;
  final SignOutMarkerStorage _markerStorage;

  // Login whose secure write failed; keeps this run signed in until the next cold start.
  AuthenticationInfoCache? _unsavedLogin;

  // Set once the Hive box is emptied this run; later reads skip the purge.
  bool _legacyHivePurged = false;

  // Web: marker value this tab's login was stored under. A copy is valid only
  // while the shared marker still equals it.
  String? _tabTag;

  // Bumped by clear(); a read that started before a logout must not move the login back.
  int _clearGeneration = 0;

  AuthenticationInfoCacheManager(
    this._authenticationInfoCacheClient,
    this._sessionStorageManager, {
    this._secureStorage = defaultSecureStorage,
    SignOutMarkerStorage? markerStorage,
  }) : _markerStorage = markerStorage ?? SignOutMarkerStorage();

  Future<void> storeAuthenticationInfo(AuthenticationInfoCache authenticationInfoCache) =>
      _saveLogin(authenticationInfoCache, keepLegacyOnFailure: false);

  Future<AuthenticationInfoCache> getAuthenticationInfoStored() async {
    final generation = _clearGeneration;
    final unsaved = _unsavedLogin;
    if (unsaved != null) {
      return unsaved;
    }
    final stored = _decode(await _readOwnedLogin());
    if (stored != null) {
      await _purgeLegacyHive();
      _throwIfClearedSince(generation);
      return stored;
    }
    final legacy = await _authenticationInfoCacheClient.getItem(_key);
    if (legacy == null) {
      throw NotFoundAuthenticationInfoCache();
    }
    _throwIfClearedSince(generation);
    // One-time move of an earlier login out of the Hive box; kept there if the move fails.
    await _saveLogin(legacy, keepLegacyOnFailure: true);
    _throwIfClearedSince(generation);
    return legacy;
  }

  bool get _isForeignCopy => PlatformInfo.isWeb && !_isCopyTagCurrent();

  Future<String?> _readOwnedLogin() async {
    final raw = await _readOutsideHive();
    if (raw != null && _isForeignCopy) {
      // A login copied from, or left over by, a signed-out session: never reuse it or the legacy login.
      await _removeOutsideHive();
      throw NotFoundAuthenticationInfoCache();
    }
    return raw;
  }

  // A read that started before a logout must not hand out the logged-out password.
  void _throwIfClearedSince(int generation) {
    if (generation != _clearGeneration) {
      throw NotFoundAuthenticationInfoCache();
    }
  }

  Future<void> clear() async {
    _clearGeneration++;
    _unsavedLogin = null;
    _tabTag = null;
    await _removeOutsideHive();
    await _authenticationInfoCacheClient.clearAllData();
  }

  Future<void> _saveLogin(AuthenticationInfoCache login, {required bool keepLegacyOnFailure}) async {
    final generation = _clearGeneration;
    final saved = await _writeOutsideHive(jsonEncode({
      _usernameField: login.username,
      _passwordField: login.password,
    }));
    if (generation != _clearGeneration) {
      // Logout ran while the write was pending; undo it.
      await _removeOutsideHive();
      return;
    }
    _unsavedLogin = saved ? null : login;
    // A new login supersedes the Hive copy even when the secure write failed.
    if (saved || !keepLegacyOnFailure) {
      await _purgeLegacyHive();
    }
  }

  // True only when secure storage reads the value back; fss 8 on iOS can drop a write without throwing.
  Future<bool> _writeOutsideHive(String value) async {
    if (PlatformInfo.isWeb) return _writeTaggedSessionLogin(value);
    try {
      await _secureStorage.write(key: _key, value: value);
      if (await _secureStorage.read(key: _key) == value) {
        return true;
      }
      logError('$runtimeType::_writeOutsideHive: secure_write_verify_failed=true');
    } catch (e, st) {
      // Login still works this run through _unsavedLogin.
      logError('$runtimeType::_writeOutsideHive: secure_write_failed=true', exception: e, stackTrace: st);
    }
    // A failed overwrite must not leave the previous login for the next cold start.
    await _removeOutsideHive();
    return false;
  }

  // The password reaches sessionStorage only together with a tag; no marker means no copy.
  bool _writeTaggedSessionLogin(String value) {
    final marker = _ensureMarker();
    if (marker == null) {
      _tabTag = null;
      _sessionStorageManager.remove(_key);
      _sessionStorageManager.remove(signOutTagKey);
      return false;
    }
    _sessionStorageManager.save(_key, value);
    _tagThisTab(marker);
    // Another tab may have replaced the marker meanwhile; follow it once.
    final latest = _readMarker();
    if (latest != null && latest != marker) {
      _tagThisTab(latest);
    }
    return true;
  }

  String? _ensureMarker() {
    try {
      final existing = _markerStorage.read();
      if (existing != null && existing.isNotEmpty) return existing;
      final created = const Uuid().v4();
      _markerStorage.write(created);
      return created;
    } catch (e) {
      logWarning('$runtimeType::_ensureMarker: $e');
      return null;
    }
  }

  String? _readMarker() {
    try {
      return _markerStorage.read();
    } catch (e) {
      logWarning('$runtimeType::_readMarker: $e');
      return null;
    }
  }

  void _tagThisTab(String marker) {
    _sessionStorageManager.save(signOutTagKey, marker);
    _tabTag = marker;
  }

  // Remembers the tag even when stale, so this tab's in-memory login stays blocked.
  bool _isCopyTagCurrent() {
    String? tag;
    try {
      tag = _sessionStorageManager.get(signOutTagKey);
    } catch (_) {
      return false;
    }
    _tabTag = tag;
    return tag.isNotEmpty && tag == _readMarker();
  }

  /// Web only. A tab opened by the app inherits a login copy and its tag but
  /// never reads them when it shows no account screen (EML preview); without
  /// the tag it could not tell that a sign out elsewhere revoked the copy.
  void adoptInheritedTabTag() {
    if (!PlatformInfo.isWeb || _tabTag != null) return;
    try {
      final login = _sessionStorageManager.get(_key);
      final tag = _sessionStorageManager.get(signOutTagKey);
      if (login.isNotEmpty && tag.isNotEmpty) _tabTag = tag;
    } catch (_) {
      // No inherited login in this tab.
    }
  }

  /// Web only. True when a sign out in another tab replaced the marker this
  /// tab's login was stored under. Cheap: one direct localStorage lookup.
  bool isLoginRevokedInThisTab() {
    final tag = _tabTag;
    if (!PlatformInfo.isWeb || tag == null) return false;
    return _readMarker() != tag;
  }

  /// Web only. Called by the tab where the user signs out: replaces the marker
  /// so every other tab's copy becomes invalid, and keeps this tab valid until
  /// its own sign out finishes. If the marker cannot be rewritten it is removed.
  void revokeOtherTabs() {
    if (!PlatformInfo.isWeb) return;
    final rotated = const Uuid().v4();
    try {
      _markerStorage.write(rotated);
    } catch (e) {
      logWarning('$runtimeType::revokeOtherTabs: marker_write_failed=true | $e');
      _removeMarker();
      // No marker left to match: stop checking this tab so its own sign out
      // requests still go out. Its stored copy is removed by the clear that follows.
      _tabTag = null;
      return;
    }
    if (_tabTag != null) {
      _tagThisTab(rotated);
    }
  }

  /// Web only. Removes just this tab's login copy and its tag from sessionStorage.
  /// The tab stays flagged as revoked, so its in-memory login remains blocked.
  void dropLoginCopyInThisTab() {
    if (!PlatformInfo.isWeb) return;
    try {
      _sessionStorageManager.remove(_key);
      _sessionStorageManager.remove(signOutTagKey);
    } catch (e) {
      logWarning('$runtimeType::dropLoginCopyInThisTab: $e');
    }
  }

  void _removeMarker() {
    try {
      _markerStorage.remove();
    } catch (e) {
      logWarning('$runtimeType::_removeMarker: $e');
    }
  }

  Future<String?> _readOutsideHive() async {
    try {
      return PlatformInfo.isWeb
          ? _sessionStorageManager.get(_key)
          : await _secureStorage.read(key: _key);
    } catch (_) {
      // Absent (NotFoundDataWithThisKeyException) or secure storage unavailable.
      return null;
    }
  }

  Future<void> _removeOutsideHive() async {
    try {
      await _putOutsideHive(null);
      // fss 8 iOS reports a failed Keychain delete as a normal result.
      if (await _readOutsideHive() == null) return;
      logWarning('$runtimeType::_removeOutsideHive: delete_verify_failed=true');
    } catch (e) {
      logWarning('$runtimeType::_removeOutsideHive: $e');
    }
    try {
      // An empty value decodes to no login, so a failed delete cannot resurrect it.
      await _putOutsideHive('');
    } catch (e) {
      logWarning('$runtimeType::_removeOutsideHive: blank_failed=true | $e');
    }
  }

  // A null value removes the entry.
  Future<void> _putOutsideHive(String? value) async {
    if (PlatformInfo.isWeb) {
      if (value == null) {
        _sessionStorageManager.remove(_key);
        _sessionStorageManager.remove(signOutTagKey);
      } else {
        _sessionStorageManager.save(_key, value);
      }
    } else {
      value == null
          ? await _secureStorage.delete(key: _key)
          : await _secureStorage.write(key: _key, value: value);
    }
  }

  AuthenticationInfoCache? _decode(String? raw) {
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AuthenticationInfoCache(
        json[_usernameField] as String,
        json[_passwordField] as String);
    } catch (_) {
      return null;
    }
  }

  Future<void> _purgeLegacyHive() async {
    if (_legacyHivePurged) return;
    try {
      await _authenticationInfoCacheClient.clearAllData();
      _legacyHivePurged = true;
    } catch (e) {
      logWarning('$runtimeType::_purgeLegacyHive: $e');
    }
  }

  @override
  Future<void> migrateHiveToIsolatedHive() async {
    try {
      final legacyMapItems = await _authenticationInfoCacheClient.getMapItems(
        isolated: false,
      );
      log('$runtimeType::migrateHiveToIsolatedHive(): Length of legacyMapItems: ${legacyMapItems.length}');
      await _authenticationInfoCacheClient.insertMultipleItem(legacyMapItems);
      log('$runtimeType::migrateHiveToIsolatedHive(): ✅ Migrate Hive box "${_authenticationInfoCacheClient.tableName}" → IsolatedHive DONE');
    } catch (e) {
      logWarning('$runtimeType::migrateHiveToIsolatedHive(): ❌ Migrate Hive box "${_authenticationInfoCacheClient.tableName}" → IsolatedHive FAILED, Error: $e');
    }
  }
}
