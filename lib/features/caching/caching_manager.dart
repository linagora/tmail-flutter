import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:core/utils/sentry/sentry_config.dart';
import 'package:tmail_ui_user/features/caching/clients/hive_cache_version_client.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/caching/extensions/sentry_config_extension.dart';
import 'package:tmail_ui_user/features/caching/extensions/sentry_configuration_cache_extension.dart';
import 'package:tmail_ui_user/features/caching/manager/sentry_configuration_cache_manager.dart';
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
  final SentryConfigurationCacheManager _sentryConfigurationCacheManager;

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
    this._sentryConfigurationCacheManager,
  );

  Future<void> clearAll() async {
    try {
      await Future.wait([
        clearMailDataCached(),
        clearAccountDataCached(),
      ]);
    } catch (e) {
      logWarning('CachingManager::clearAll: Cannot clear all cache: $e');
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
    } catch (e) {
      logWarning('CachingManager::clearMailDataCached: Cannot clear mail data cache: $e');
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
    } catch (e) {
      logWarning('CachingManager::clearAccountDataCached: Cannot clear account data cache: $e');
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
    } catch (e) {
      logWarning('CachingManager::clearAllEmailAndStateCache: Cannot clear email and state cache: $e');
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
      logWarning('CachingManager::clearDetailedEmailCache: Cannot clear detailed email cache: $e');
    }
  }

  Future<void> _clearEmailContentFileInStorage() async {
    try {
      await Future.wait([
        _fileUtils.removeFolder(
          CachingConstants.openedEmailContentFolderName,
        ),
        _fileUtils.removeFolder(
          CachingConstants.newEmailsContentFolderName,
        ),
      ]);
    } catch (e) {
      logWarning(
        'CachingManager::_clearEmailContentFileInStorage: Cannot clear file in storage: $e',
      );
    }
  }

  Future<void> _clearFCMStateCache() async {
    try {
      await _fcmCacheManager.clear();
    } catch (e) {
      logWarning('CachingManager::_clearFCMStateCache: Cannot clear fcm state cache: $e');
    }
  }

  Future<void> clearMailboxAndStateCache() async {
    try {
      await Future.wait([
        _mailboxCacheManager.clear(),
        _stateCacheManager.clear(),
      ], eagerError: true);
    } catch (e) {
      logWarning('CachingManager::clearMailboxAndStateCache: Cannot clear mailbox cache: $e');
    }
  }

  Future<bool> storeCacheVersion(int newVersion) async {
    log('CachingManager::storeCacheVersion():newVersion = $newVersion');
    return _hiveCacheVersionClient.storeVersion(newVersion);
  }

  Future<int?> getLatestVersion() {
    return _hiveCacheVersionClient.getLatestVersion();
  }

  Future<void> closeHive({bool isolated = true}) =>
      HiveCacheConfig.instance.closeHive(isolated: isolated);

  Future<void> clearLoginRecentData() async {
    await Future.wait([
      _recentLoginUrlCacheManager.clear(),
      _recentLoginUsernameCacheManager.clear(),
    ]);
  }

  Future<void> clearRecentSearchData() async {
    await _recentSearchCacheManager.clear();
  }

  Future<void> migrateHiveToIsolatedHive() async {
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
  }

  Future<void> saveSentryConfiguration(SentryConfig sentryConfig) async {
    try {
      await _sentryConfigurationCacheManager.saveSentryConfiguration(
        sentryConfig.toSentryConfigurationCache(),
      );
      log('CachingManager::saveSentryConfiguration: Sentry configuration saved successfully');
    } catch (e, st) {
      logError(
        'CachingManager::saveSentryConfiguration: Cannot save sentry configuration',
        exception: e,
        stackTrace: st,
      );
    }
  }

  Future<SentryConfig?> getSentryConfiguration() async {
    try {
      final sentryConfigurationCache =
          await _sentryConfigurationCacheManager.getSentryConfiguration();
      final sentryConfig = sentryConfigurationCache.toSentryConfig();
      log('CachingManager::getSentryConfiguration: Sentry configuration: $sentryConfig');
      return sentryConfig;
    } catch (e, st) {
      logError(
        'CachingManager::getSentryConfiguration: Cannot get sentry configuration',
        exception: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
