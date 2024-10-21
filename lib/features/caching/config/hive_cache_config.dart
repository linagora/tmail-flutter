import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:tmail_ui_user/features/base/upgradeable/upgrade_hive_database_steps_v10.dart';
import 'package:tmail_ui_user/features/base/upgradeable/upgrade_hive_database_steps_v11.dart';
import 'package:tmail_ui_user/features/base/upgradeable/upgrade_hive_database_steps_v12.dart';
import 'package:tmail_ui_user/features/base/upgradeable/upgrade_hive_database_steps_v13.dart';
import 'package:tmail_ui_user/features/base/upgradeable/upgrade_hive_database_steps_v7.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/caching/config/cache_version.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/home/data/model/session_hive_obj.dart';
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
import 'package:tmail_ui_user/features/offline_mode/model/attachment_hive_cache.dart';
import 'package:tmail_ui_user/features/offline_mode/model/detailed_email_hive_cache.dart';
import 'package:tmail_ui_user/features/offline_mode/model/email_header_hive_cache.dart';
import 'package:tmail_ui_user/features/offline_mode/model/sending_email_hive_cache.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/firebase_registration_cache.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_address_hive_cache.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_cache.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class HiveCacheConfig {

  HiveCacheConfig._internal();

  static final HiveCacheConfig _instance = HiveCacheConfig._internal();

  static HiveCacheConfig get instance => _instance;

  Future<void> setUp({String? cachePath}) async {
    await initializeDatabase(databasePath: cachePath);
    _registerAdapter();
  }

  Future<void> initializeDatabase({String? databasePath}) async {
    if (databasePath != null) {
      Hive.init(databasePath);
    } else {
      if (PlatformInfo.isMobile) {
        Directory directory = await path_provider.getApplicationDocumentsDirectory();
        Hive.init(directory.path);
      }
    }
  }

  Future<void> onUpgradeDatabase(CachingManager cachingManager) async {
    final oldVersion = await cachingManager.getLatestVersion() ?? 0;
    const newVersion = CacheVersion.hiveDBVersion;
    log('HiveCacheConfig::onUpgradeDatabase():oldVersion: $oldVersion | newVersion: $newVersion');

    await UpgradeHiveDatabaseStepsV7(cachingManager).onUpgrade(oldVersion, newVersion);
    await UpgradeHiveDatabaseStepsV10(cachingManager).onUpgrade(oldVersion, newVersion);
    await UpgradeHiveDatabaseStepsV11(cachingManager).onUpgrade(oldVersion, newVersion);
    await UpgradeHiveDatabaseStepsV12(cachingManager).onUpgrade(oldVersion, newVersion);
    await UpgradeHiveDatabaseStepsV13(cachingManager).onUpgrade(oldVersion, newVersion);

    if (oldVersion != newVersion) {
      await cachingManager.storeCacheVersion(newVersion);
    }
  }

  Future<void> initializeEncryptionKey() async {
    final encryptionKeyCacheManager = getBinding<EncryptionKeyCacheManager>() ?? getBinding<EncryptionKeyCacheManager>(tag: BindingTag.isolateTag);
    if (encryptionKeyCacheManager == null) {
      log('HiveCacheConfig::_initializeEncryptionKey(): encryptionKeyCacheManager not found');
      return;
    }
    final encryptionKeyCache = await encryptionKeyCacheManager.getEncryptionKeyStored();
    if (encryptionKeyCache == null) {
      final secureKey = Hive.generateSecureKey();
      final secureKeyEncode = base64Encode(secureKey);
      log('HiveCacheConfig::_initializeEncryptionKey(): secureKeyEncode: $secureKeyEncode');
      await encryptionKeyCacheManager.storeEncryptionKey(EncryptionKeyCache(secureKeyEncode));
    }
  }

  Future<Uint8List?> getEncryptionKey() async {
    final encryptionKeyCacheManager = getBinding<EncryptionKeyCacheManager>() ?? getBinding<EncryptionKeyCacheManager>(tag: BindingTag.isolateTag);
    if (encryptionKeyCacheManager == null) {
      log('HiveCacheConfig::getEncryptionKey(): encryptionKeyCacheManager not found');
      return null;
    }
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

  void _registerAdapter() {
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
    registerCacheAdapter<FirebaseRegistrationCache>(
      FirebaseRegistrationCacheAdapter(),
      CachingConstants.FIREBASE_REGISTRATION_HIVE_CACHE_IDENTITY
    );
    registerCacheAdapter<AttachmentHiveCache>(
      AttachmentHiveCacheAdapter(),
      CachingConstants.ATTACHMENT_HIVE_CACHE_ID
    );
    registerCacheAdapter<EmailHeaderHiveCache>(
      EmailHeaderHiveCacheAdapter(),
      CachingConstants.EMAIL_HEADER_HIVE_CACHE_ID
    );
    registerCacheAdapter<DetailedEmailHiveCache>(
      DetailedEmailHiveCacheAdapter(),
      CachingConstants.DETAILED_EMAIL_HIVE_CACHE_ID
    );
    registerCacheAdapter<SendingEmailHiveCache>(
      SendingEmailHiveCacheAdapter(),
      CachingConstants.SENDING_EMAIL_HIVE_CACHE_ID
    );
    registerCacheAdapter<SessionHiveObj>(
      SessionHiveObjAdapter(),
      CachingConstants.SESSION_HIVE_CACHE_ID
    );
  }

  void registerCacheAdapter<T>(TypeAdapter<T> typeAdapter, int typeId) {
    if (!Hive.isAdapterRegistered(typeId)) {
      Hive.registerAdapter<T>(typeAdapter);
    }
  }

  Future<void> closeHive() async {
    return await Hive.close();
  }
}