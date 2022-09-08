import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:tmail_ui_user/features/login/data/local/encryption_key_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/model/account_cache.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';
import 'package:tmail_ui_user/features/login/data/model/encryption_key_cache.dart';
import 'package:tmail_ui_user/features/login/data/model/token_oidc_cache.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_cache.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_rights_cache.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_cache.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/recent_search_cache.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_address_hive_cache.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_cache.dart';

class HiveCacheConfig {

  Future setUp({String? cachePath}) async {
    await initializeDatabase(databasePath: cachePath);
    registerAdapter();
  }

  Future initializeDatabase({String? databasePath}) async {
    if (databasePath != null) {
      Hive.init(databasePath);
    } else {
      if (!GetPlatform.isWeb) {
        Directory directory = await path_provider.getApplicationDocumentsDirectory();
        Hive.init(directory.path);
      }
    }
  }

  static Future<void> initializeEncryptionKey() async {
    final encryptionKeyCacheManager = Get.find<EncryptionKeyCacheManager>();
    final encryptionKeyCache = await encryptionKeyCacheManager.getEncryptionKeyStored();
    if (encryptionKeyCache == null) {
      final secureKey = Hive.generateSecureKey();
      final secureKeyEncode = base64Encode(secureKey);
      log('HiveCacheConfig::_initializeEncryptionKey(): secureKeyEncode: $secureKeyEncode');
      await encryptionKeyCacheManager.storeEncryptionKey(EncryptionKeyCache(secureKeyEncode));
    }
  }

  static Future<Uint8List?> getEncryptionKey() async {
    final encryptionKeyCacheManager = Get.find<EncryptionKeyCacheManager>();
    var encryptionKeyCache = await encryptionKeyCacheManager.getEncryptionKeyStored();

    if (encryptionKeyCache != null) {
      final encryptionKey = encryptionKeyCache.value;
      log('HiveCacheConfig::getEncryptionKey(): encryptionKey: $encryptionKey');
      final encryptionKeyDecode = base64Decode(encryptionKeyCache.value);
      return encryptionKeyDecode;
    } else {
      return null;
    }
  }

  void registerAdapter() {
    Hive.registerAdapter(MailboxCacheAdapter());
    Hive.registerAdapter(MailboxRightsCacheAdapter());
    Hive.registerAdapter(StateCacheAdapter());
    Hive.registerAdapter(StateTypeAdapter());
    Hive.registerAdapter(EmailAddressHiveCacheAdapter());
    Hive.registerAdapter(EmailCacheAdapter());
    Hive.registerAdapter(RecentSearchCacheAdapter());
    Hive.registerAdapter(TokenOidcCacheAdapter());
    Hive.registerAdapter(AccountCacheAdapter());
    Hive.registerAdapter(EncryptionKeyCacheAdapter());
    Hive.registerAdapter(AuthenticationInfoCacheAdapter());
  }

  Future closeHive() async {
    await Hive.close();
  }
}