import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/login/data/local/encryption_key_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/model/account_cache.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';
import 'package:tmail_ui_user/features/login/data/model/encryption_key_cache.dart';
import 'package:tmail_ui_user/features/login/data/model/recent_login_url_cache.dart';
import 'package:tmail_ui_user/features/login/data/model/recent_login_username_cache.dart';
import 'package:tmail_ui_user/features/login/data/model/token_oidc_cache.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_cache.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_rights_cache.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_cache.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/recent_search_cache.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/fcm_token_cache.dart';
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
    registerCacheAdapter<MailboxCache>(
      MailboxCacheAdapter(),
      CachingConstants.MAILBOX_CACHE_IDENTIFY
    );
    registerCacheAdapter<MailboxRightsCache>(
      MailboxRightsCacheAdapter(),
      CachingConstants.MAILBOX_RIGHTS_CACHE_IDENTIFY
    );
    registerCacheAdapter<StateCache>(
      StateCacheAdapter(),
      CachingConstants.STATE_CACHE_IDENTIFY
    );
    registerCacheAdapter<StateType>(
      StateTypeAdapter(),
      CachingConstants.STATE_TYPE_IDENTIFY
    );
    registerCacheAdapter<EmailAddressHiveCache>(
      EmailAddressHiveCacheAdapter(),
      CachingConstants.EMAIL_ADDRESS_HIVE_CACHE_IDENTIFY
    );
    registerCacheAdapter<EmailCache>(
      EmailCacheAdapter(),
      CachingConstants.EMAIL_CACHE_IDENTIFY
    );
    registerCacheAdapter<RecentSearchCache>(
      RecentSearchCacheAdapter(),
      CachingConstants.RECENT_SEARCH_HIVE_CACHE_IDENTIFY
    );
    registerCacheAdapter<TokenOidcCache>(
      TokenOidcCacheAdapter(),
      CachingConstants.TOKEN_OIDC_HIVE_CACHE_IDENTIFY
    );
    registerCacheAdapter<AccountCache>(
      AccountCacheAdapter(),
      CachingConstants.ACCOUNT_HIVE_CACHE_IDENTIFY
    );
    registerCacheAdapter<EncryptionKeyCache>(
      EncryptionKeyCacheAdapter(),
      CachingConstants.ENCRYPTION_KEY_HIVE_CACHE_IDENTIFY
    );
    registerCacheAdapter<AuthenticationInfoCache>(
      AuthenticationInfoCacheAdapter(),
      CachingConstants.AUTHENTICATION_INFO_HIVE_CACHE_IDENTIFY
    );
    registerCacheAdapter<RecentLoginUrlCache>(
      RecentLoginUrlCacheAdapter(),
      CachingConstants.RECENT_LOGIN_URL_HIVE_CACHE_IDENTITY
    );
    registerCacheAdapter<RecentLoginUsernameCache>(
      RecentLoginUsernameCacheAdapter(),
      CachingConstants.RECENT_LOGIN_USERNAME_HIVE_CACHE_IDENTITY
    );
    registerCacheAdapter<FCMTokenCache>(
      FCMTokenCacheAdapter(),
      CachingConstants.FCM_TOKEN_CACHE_IDENTITY
    );
  }

  void registerCacheAdapter<T>(TypeAdapter<T> typeAdapter, int typeId) {
    if (!Hive.isAdapterRegistered(typeId)) {
      Hive.registerAdapter<T>(typeAdapter);
    }
  }

  Future closeHive() async {
    await Hive.close();
  }
}