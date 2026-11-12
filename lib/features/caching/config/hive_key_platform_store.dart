import 'dart:convert';
import 'dart:typed_data';

import 'package:core/utils/app_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive.dart';
import 'package:tmail_ui_user/features/login/data/local/encryption_key_cache_manager.dart';

/// Holds the Hive box key in the iOS Keychain instead of a Hive box.
class HiveKeyPlatformStore {
  static const String keyName = 'tmail_hive_box_key';

  // Own iOS service: KeychainSharingManager.delete() calls deleteAll() on logout.
  static const FlutterSecureStorage defaultStorage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accountName: 'tmail_hive_key_store',
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final FlutterSecureStorage _storage;

  const HiveKeyPlatformStore({FlutterSecureStorage storage = defaultStorage})
      : _storage = storage;

  /// Main isolate, app start. Returns false when the Keychain is unusable,
  /// so the caller falls back to the legacy box and the app keeps working.
  Future<bool> initialize(EncryptionKeyCacheManager? legacyManager) async {
    try {
      final stored = await _storage.read(key: keyName);
      if (stored != null) {
        await _deleteLegacyBox(legacyManager);
        return true;
      }
      final legacy = await legacyManager?.getEncryptionKeyStored();
      final value = legacy?.value ?? base64Encode(Hive.generateSecureKey());
      await _storage.write(key: keyName, value: value);
      if (await _storage.read(key: keyName) != value) {
        logError('HiveKeyPlatformStore::initialize: platform_key_verify_failed=true');
        return false;
      }
      await _deleteLegacyBox(legacyManager);
      return true;
    } catch (e, st) {
      logError('HiveKeyPlatformStore::initialize: platform_key_init_failed=true', exception: e, stackTrace: st);
      return false;
    }
  }

  /// Null when absent or unreadable (e.g. iOS before first unlock).
  Future<Uint8List?> read() async {
    try {
      final stored = await _storage.read(key: keyName);
      return stored == null ? null : base64Decode(stored);
    } catch (e, st) {
      logError('HiveKeyPlatformStore::read: platform_key_read_failed=true', exception: e, stackTrace: st);
      return null;
    }
  }

  Future<void> _deleteLegacyBox(EncryptionKeyCacheManager? legacyManager) async {
    try {
      await legacyManager?.deleteLegacyBox();
    } catch (e) {
      logWarning('HiveKeyPlatformStore::_deleteLegacyBox: retried next start | $e');
    }
  }
}
