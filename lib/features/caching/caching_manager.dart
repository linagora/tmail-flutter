import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:tmail_ui_user/features/caching/clients/hive_cache_version_client.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/caching/manager/session_cache_manger.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/cleanup/data/local/recent_login_url_cache_manager.dart';
import 'package:tmail_ui_user/features/cleanup/data/local/recent_login_username_cache_manager.dart';
import 'package:tmail_ui_user/features/cleanup/data/local/recent_search_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/authentication_info_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/encryption_key_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/oidc_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/mailbox_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/state_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/new_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/sending_email_cache_manager.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_sharing_manager.dart';
import 'package:tmail_ui_user/features/push_notification/data/local/fcm_cache_manager.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';

class CachingManager {
  final MailboxCacheManager _mailboxCacheManager;
  final StateCacheManager _stateCacheManager;
  final EmailCacheManager _emailCacheManager;
  final RecentSearchCacheManager _recentSearchCacheManager;
  final RecentLoginUrlCacheManager _recentLoginUrlCacheManager;
  final RecentLoginUsernameCacheManager _recentLoginUsernameCacheManager;
  final AccountCacheManager _accountCacheManager;
  final FCMCacheManager _fcmCacheManager;
  final HiveCacheVersionClient _hiveCacheVersionClient;
  final NewEmailCacheManager _newEmailCacheManager;
  final OpenedEmailCacheManager _openedEmailCacheManager;
  final FileUtils _fileUtils;
  final SendingEmailCacheManager _sendingEmailCacheManager;
  final SessionCacheManager _sessionCacheManager;
  final KeychainSharingManager _keychainSharingManager;
  final TokenOidcCacheManager _tokenOidcCacheManager;
  final OidcConfigurationCacheManager _oidcConfigurationCacheManager;
  final EncryptionKeyCacheManager _encryptionKeyCacheManager;
  final AuthenticationInfoCacheManager _authenticationInfoCacheManager;

  CachingManager(
    this._mailboxCacheManager,
    this._stateCacheManager,
    this._emailCacheManager,
    this._recentSearchCacheManager,
    this._recentLoginUrlCacheManager,
    this._recentLoginUsernameCacheManager,
    this._accountCacheManager,
    this._fcmCacheManager,
    this._hiveCacheVersionClient,
    this._newEmailCacheManager,
    this._openedEmailCacheManager,
    this._fileUtils,
    this._sendingEmailCacheManager,
    this._sessionCacheManager,
    this._keychainSharingManager,
    this._tokenOidcCacheManager,
    this._oidcConfigurationCacheManager,
    this._encryptionKeyCacheManager,
    this._authenticationInfoCacheManager,
  );

  Future<void> clearAll() async {
    try {
      await Future.wait([
        clearMailDataCached(),
        clearAccountDataCached(),
      ], eagerError: true);
      log(
        'CachingManager::clearAll: Clear all cache successfully',
        webConsole: true,
      );
    } catch (e) {
      logError(
        'CachingManager::clearAll: Cannot clear all cache: $e',
        webConsole: true,
      );
    }
  }

  Future<void> clearMailDataCached() async {
    try {
      await Future.wait([
        _stateCacheManager.clear(),
        _mailboxCacheManager.clear(),
        _emailCacheManager.clear(),
        _clearFCMStateCache(),
        if (PlatformInfo.isMobile)
          ...[
            clearDetailedEmailCache(),
            _sendingEmailCacheManager.clear(),
            _sessionCacheManager.clear(),
          ],
        if (PlatformInfo.isIOS)
          _keychainSharingManager.delete(),
      ], eagerError: true);
      log(
        'CachingManager::clearMailDataCached: Clear mail data cache successfully',
        webConsole: true,
      );
    } catch (e) {
      logError(
        'CachingManager::clearMailDataCached: Cannot clear mail data cache: $e',
        webConsole: true,
      );
    }
  }

  Future<void> clearAccountDataCached() async {
    try {
      await Future.wait([
        _accountCacheManager.clear(),
        _oidcConfigurationCacheManager.clear(),
        _tokenOidcCacheManager.clear(),
        _authenticationInfoCacheManager.clear(),
      ], eagerError: true);
      log(
        'CachingManager::clearAccountDataCached: Clear account data cache successfully',
        webConsole: true,
      );
    } catch (e) {
      logError(
        'CachingManager::clearAccountDataCached: Cannot clear account data cache: $e',
        webConsole: true,
      );
    }
  }

  Future<void> clearAllEmailAndStateCache() async {
    try {
      await Future.wait([
        _emailCacheManager.clear(),
        _stateCacheManager.clear(),
        _clearFCMStateCache(),
        if (PlatformInfo.isMobile)
          clearDetailedEmailCache(),
      ]);
      log(
        'CachingManager::clearAllEmailAndStateCache: Clear email and state cache successfully',
        webConsole: true,
      );
    } catch (e) {
      logError(
        'CachingManager::clearAllEmailAndStateCache: Cannot clear email and state cache: $e',
        webConsole: true,
      );
    }
  }

  Future<void> clearDetailedEmailCache() async {
    try {
      await Future.wait([
        _newEmailCacheManager.clear(),
        _openedEmailCacheManager.clear(),
        _clearEmailContentFileInStorage(),
      ]);
    } catch (e) {
      logError(
        'CachingManager::clearDetailedEmailCache: Cannot clear detailed email cache: $e',
        webConsole: true,
      );
    }
  }

  Future<void> _clearEmailContentFileInStorage() async {
    try {
      await _fileUtils.removeFolder(
        CachingConstants.openedEmailContentFolderName,
      );
      await _fileUtils.removeFolder(
        CachingConstants.newEmailsContentFolderName,
      );
    } catch (e) {
      logError(
        'CachingManager::_clearEmailContentFileInStorage: Cannot clear file in storage: $e',
        webConsole: true,
      );
    }
  }

  Future<void> _clearFCMStateCache() async {
    try {
      await _fcmCacheManager.clear();
    } catch (e) {
      logError(
        'CachingManager::_clearFCMStateCache: Cannot clear fcm state cache: $e',
        webConsole: true,
      );
    }
  }

  Future<void> clearMailboxAndStateCache() async {
    try {
      await Future.wait([
        _mailboxCacheManager.clear(),
        _stateCacheManager.clear(),
      ], eagerError: true);
    } catch (e) {
      logError(
        'CachingManager::clearMailboxCache: Cannot clear mailbox cache: $e',
        webConsole: true,
      );
    }
  }

  Future<bool> storeCacheVersion(int newVersion) async {
    log('CachingManager::storeCacheVersion():newVersion = $newVersion');
    try {
      return _hiveCacheVersionClient.storeVersion(newVersion);
    } catch (e) {
      logError(
        'CachingManager::storeCacheVersion: Cannot store cache version: $e',
        webConsole: true,
      );
      return false;
    }
  }

  Future<int?> getLatestVersion() async {
    try {
      return _hiveCacheVersionClient.getLatestVersion();
    } catch (e) {
      logError(
        'CachingManager::getLatestVersion: Cannot get latest version: $e',
        webConsole: true,
      );
      return null;
    }
  }

  Future<void> closeHive({bool isolated = true}) async {
    try {
      await HiveCacheConfig.instance.closeHive(isolated: isolated);
    } catch (e) {
      logError(
        'CachingManager::closeHive: Cannot close hive: $e',
        webConsole: true,
      );
    }
  }

  Future<void> clearLoginRecentData() async {
    try {
      await Future.wait([
        _recentLoginUrlCacheManager.clear(),
        _recentLoginUsernameCacheManager.clear(),
      ]);
    } catch (e) {
      logError(
        'CachingManager::clearLoginRecentData: Cannot clear login recent data: $e',
        webConsole: true,
      );
    }
  }

  Future<void> clearRecentSearchData() async {
    try {
      await _recentSearchCacheManager.clear();
    } catch (e) {
      logError(
        'CachingManager::clearRecentSearchData: Cannot clear recent search data: $e',
        webConsole: true,
      );
    }
  }

  Future<void> migrateHiveToIsolatedHive() async {
    try {
      await Future.wait([
        _tokenOidcCacheManager.migrateHiveToIsolatedHive(),
        _accountCacheManager.migrateHiveToIsolatedHive(),
        _fcmCacheManager.migrateHiveToIsolatedHive(),
        _oidcConfigurationCacheManager.migrateHiveToIsolatedHive(),
        _encryptionKeyCacheManager.migrateHiveToIsolatedHive(),
        _authenticationInfoCacheManager.migrateHiveToIsolatedHive(),
        _recentLoginUrlCacheManager.migrateHiveToIsolatedHive(),
        _recentLoginUsernameCacheManager.migrateHiveToIsolatedHive(),
        _recentSearchCacheManager.migrateHiveToIsolatedHive(),
        if (PlatformInfo.isMobile)
          ...[
            _sessionCacheManager.migrateHiveToIsolatedHive(),
            _sendingEmailCacheManager.migrateHiveToIsolatedHive(),
          ]
      ]);
    } catch (e) {
      logError(
        'CachingManager::migrateHiveToIsolatedHive: Cannot migrate hive to isolated hive: $e',
        webConsole: true,
      );
    }
  }
}
