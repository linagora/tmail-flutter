import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/clients/account_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/email_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/fcm_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/firebase_registration_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/hive_cache_version_client.dart';
import 'package:tmail_ui_user/features/caching/clients/mailbox_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/new_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/opened_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/recent_login_url_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/recent_login_username_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/recent_search_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/session_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/state_cache_client.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/local/local_spam_report_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/sending_email_cache_manager.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_sharing_manager.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/extensions/type_name_extension.dart';

class CachingManager {
  final MailboxCacheClient _mailboxCacheClient;
  final StateCacheClient _stateCacheClient;
  final EmailCacheClient _emailCacheClient;
  final RecentSearchCacheClient _recentSearchCacheClient;
  final RecentLoginUrlCacheClient _recentLoginUrlCacheClient;
  final RecentLoginUsernameCacheClient _recentLoginUsernameCacheClient;
  final AccountCacheClient _accountCacheClient;
  final FcmCacheClient _fcmCacheClient;
  final FirebaseRegistrationCacheClient _firebaseRegistrationCacheClient;
  final HiveCacheVersionClient _hiveCacheVersionClient;
  final NewEmailHiveCacheClient _newEmailHiveCacheClient;
  final OpenedEmailHiveCacheClient _openedEmailHiveCacheClient;
  final FileUtils _fileUtils;
  final SendingEmailCacheManager _sendingEmailCacheManager;
  final SessionHiveCacheClient _sessionHiveCacheClient;
  final LocalSpamReportManager _localSpamReportManager;
  final KeychainSharingManager _keychainSharingManager;

  CachingManager(
    this._mailboxCacheClient,
    this._stateCacheClient,
    this._emailCacheClient,
    this._recentSearchCacheClient,
    this._recentLoginUrlCacheClient,
    this._recentLoginUsernameCacheClient,
    this._accountCacheClient,
    this._fcmCacheClient,
    this._firebaseRegistrationCacheClient,
    this._hiveCacheVersionClient,
    this._newEmailHiveCacheClient,
    this._openedEmailHiveCacheClient,
    this._fileUtils,
    this._sendingEmailCacheManager,
    this._sessionHiveCacheClient,
    this._localSpamReportManager,
    this._keychainSharingManager,
  );

  Future<void> clearAll() async {
    await Future.wait([
      _stateCacheClient.clearAllData(),
      _mailboxCacheClient.clearAllData(),
      _emailCacheClient.clearAllData(),
      _fcmCacheClient.clearAllData(),
      _firebaseRegistrationCacheClient.clearAllData(),
      _accountCacheClient.clearAllData(),
      _localSpamReportManager.clear(),
      if (PlatformInfo.isMobile)
        ...[
          _sessionHiveCacheClient.clearAllData(),
          _newEmailHiveCacheClient.clearAllData(),
          _openedEmailHiveCacheClient.clearAllData(),
          _sendingEmailCacheManager.clearAllSendingEmails(),
        ],
      if (PlatformInfo.isIOS)
        _keychainSharingManager.delete()
    ], eagerError: true);
  }

  Future<void> clearData() async {
    await Future.wait([
      _stateCacheClient.clearAllData(),
      _mailboxCacheClient.clearAllData(),
      _emailCacheClient.clearAllData(),
      _fcmCacheClient.clearAllData(),
      _firebaseRegistrationCacheClient.clearAllData(),
      _localSpamReportManager.clear(),
      if (PlatformInfo.isMobile)
       ...[
         _newEmailHiveCacheClient.clearAllData(),
         _openedEmailHiveCacheClient.clearAllData(),
         _sendingEmailCacheManager.clearAllSendingEmails(),
       ]
    ], eagerError: true);
  }

  Future<void> clearEmailAndStateCache({AccountId? accountId, UserName? userName}) {
    log('CachingManager::clearEmailAndStateCache:userName = $userName');
    if (accountId != null && userName != null) {
      final emailKey = TupleKey(accountId.asString, userName.value).encodeKey;
      final stateKey = StateType.email.getTupleKeyStored(accountId, userName);

      return Future.wait([
        _emailCacheClient.clearAllDataContainKey(emailKey),
        _stateCacheClient.deleteItem(stateKey),
        if (PlatformInfo.isMobile)
          clearFCMEmailStateCache(accountId: accountId, userName: userName),
      ]);
    } else {
      final stateKey = StateType.email.getTupleKeyStoredWithoutAccount();
      return Future.wait([
        _emailCacheClient.clearAllData(),
        _stateCacheClient.deleteItem(stateKey),
        if (PlatformInfo.isMobile) clearFCMEmailStateCache(),
      ]);
    }
  }

  Future<void> clearDetailedEmailCache({AccountId? accountId, UserName? userName}) {
    log('CachingManager::clearDetailedEmailCache:userName = $userName');
    if (accountId != null && userName != null) {
      final emailKey = TupleKey(accountId.asString, userName.value).encodeKey;
      return Future.wait([
        _newEmailHiveCacheClient.clearAllDataContainKey(emailKey),
        _openedEmailHiveCacheClient.clearAllDataContainKey(emailKey),
        clearAllFileInStorage(),
      ]);
    } else {
      return Future.wait([
        _newEmailHiveCacheClient.clearAllData(),
        _openedEmailHiveCacheClient.clearAllData(),
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
      _stateCacheClient.deleteItem(StateType.mailbox.getTupleKeyStoredWithoutAccount()),
      _mailboxCacheClient.clearAllData(),
    ], eagerError: true);
  }

  Future<bool> storeCacheVersion(int newVersion) async {
    log('CachingManager::storeCacheVersion():newVersion = $newVersion');
    return _hiveCacheVersionClient.storeVersion(newVersion);
  }

  Future<int?> getLatestVersion() {
    return _hiveCacheVersionClient.getLatestVersion();
  }

  Future<void> closeHive() async {
    return await HiveCacheConfig.instance.closeHive();
  }

  Future<void> clearAllFileInStorage() async {
    await _fileUtils.removeFolder(CachingConstants.openedEmailContentFolderName);
    await _fileUtils.removeFolder(CachingConstants.newEmailsContentFolderName);
  }
  
  Future<void> clearFCMEmailStateCache({AccountId? accountId, UserName? userName}) async {
    if (accountId != null && userName != null) {
      await _fcmCacheClient.deleteItem(
        TypeName.emailDelivery.getTupleKeyStored(accountId, userName));
      await _fcmCacheClient.deleteItem(
        TypeName.emailType.getTupleKeyStored(accountId, userName));
    } else {
      await _fcmCacheClient.deleteItem(
        TypeName.emailDelivery.getTupleKeyStoredWithoutAccount());
      await _fcmCacheClient.deleteItem(
        TypeName.emailType.getTupleKeyStoredWithoutAccount());
    }
  }

  Future<void> clearLoginRecentData() async {
    await Future.wait([
      _recentLoginUrlCacheClient.clearAllData(),
      _recentLoginUsernameCacheClient.clearAllData(),
    ]);
  }

  Future<void> clearRecentSearchData() async {
    await _recentSearchCacheClient.clearAllData();
  }
}
