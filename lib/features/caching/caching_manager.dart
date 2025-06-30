import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/clients/hive_cache_version_client.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/caching/manager/session_cache_manger.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
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
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/local/local_spam_report_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/new_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/sending_email_cache_manager.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_sharing_manager.dart';
import 'package:tmail_ui_user/features/push_notification/data/local/fcm_cache_manager.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/extensions/type_name_extension.dart';
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
  final LocalSpamReportManager _localSpamReportManager;
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
    this._localSpamReportManager,
    this._keychainSharingManager,
    this._tokenOidcCacheManager,
    this._oidcConfigurationCacheManager,
    this._encryptionKeyCacheManager,
    this._authenticationInfoCacheManager,
  );

  Future<void> clearAll() async {
    await Future.wait([
      _stateCacheManager.clear(),
      _mailboxCacheManager.clear(),
      _emailCacheManager.clear(),
      _fcmCacheManager.clear(),
      _accountCacheManager.clear(),
      _localSpamReportManager.clear(),
      if (PlatformInfo.isMobile)
        ...[
          _sessionCacheManager.clear(),
          _newEmailCacheManager.clear(),
          _openedEmailCacheManager.clear(),
          _sendingEmailCacheManager.clearAllSendingEmails(),
        ],
      if (PlatformInfo.isIOS)
        _keychainSharingManager.delete()
    ], eagerError: true);
  }

  Future<void> clearEmailAndStateCache({AccountId? accountId, UserName? userName}) {
    log('CachingManager::clearEmailAndStateCache:userName = $userName');
    if (accountId != null && userName != null) {
      final emailKey = TupleKey(accountId.asString, userName.value).encodeKey;
      final stateKey = StateType.email.getTupleKeyStored(accountId, userName);

      return Future.wait([
        _emailCacheManager.deleteByKey(emailKey),
        _stateCacheManager.deleteByKey(stateKey),
        if (PlatformInfo.isMobile)
          clearFCMEmailStateCache(accountId: accountId, userName: userName),
      ]);
    } else {
      final stateKey = StateType.email.getTupleKeyStoredWithoutAccount();
      return Future.wait([
        _emailCacheManager.clear(),
        _stateCacheManager.deleteByKey(stateKey),
        if (PlatformInfo.isMobile) clearFCMEmailStateCache(),
      ]);
    }
  }

  Future<void> clearDetailedEmailCache({AccountId? accountId, UserName? userName}) {
    log('CachingManager::clearDetailedEmailCache:userName = $userName');
    if (accountId != null && userName != null) {
      final emailKey = TupleKey(accountId.asString, userName.value).encodeKey;
      return Future.wait([
        _newEmailCacheManager.deleteByKey(emailKey),
        _openedEmailCacheManager.deleteByKey(emailKey),
        clearAllFileInStorage(),
      ]);
    } else {
      return Future.wait([
        _newEmailCacheManager.clear(),
        _openedEmailCacheManager.clear(),
        clearAllFileInStorage(),
      ]);
    }
  }

  Future<void> clearAllEmailAndStateCache({AccountId? accountId, UserName? userName}) {
    log('CachingManager::clearAllEmailAndStateCache:userName = $userName');
    return Future.wait([
      clearEmailAndStateCache(accountId: accountId, userName: userName),
      if (PlatformInfo.isMobile)
        clearDetailedEmailCache(accountId: accountId, userName: userName),
    ]);
  }

  Future<void> clearMailboxCache() {
    return Future.wait([
      _stateCacheManager.deleteByKey(
        StateType.mailbox.getTupleKeyStoredWithoutAccount(),
      ),
      _mailboxCacheManager.clear(),
    ], eagerError: true);
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

  Future<void> clearAllFileInStorage() async {
    await _fileUtils.removeFolder(CachingConstants.openedEmailContentFolderName);
    await _fileUtils.removeFolder(CachingConstants.newEmailsContentFolderName);
  }
  
  Future<void> clearFCMEmailStateCache({AccountId? accountId, UserName? userName}) async {
    if (accountId != null && userName != null) {
      await _fcmCacheManager.deleteByKey(
        TypeName.emailDelivery.getTupleKeyStored(accountId, userName));
      await _fcmCacheManager.deleteByKey(
        TypeName.emailType.getTupleKeyStored(accountId, userName));
    } else {
      await _fcmCacheManager.deleteByKey(
        TypeName.emailDelivery.getTupleKeyStoredWithoutAccount());
      await _fcmCacheManager.deleteByKey(
        TypeName.emailType.getTupleKeyStoredWithoutAccount());
    }
  }

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
}
