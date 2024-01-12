import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/caching/clients/account_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/email_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/fcm_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/firebase_registration_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/hive_cache_version_client.dart';
import 'package:tmail_ui_user/features/caching/clients/mailbox_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/new_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/opened_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/recent_search_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/session_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/state_cache_client.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/local/local_spam_report_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/controller/work_manager_controller.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/sending_email_cache_manager.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_sharing_manager.dart';

class CachingManager {
  final MailboxCacheClient _mailboxCacheClient;
  final StateCacheClient _stateCacheClient;
  final EmailCacheClient _emailCacheClient;
  final RecentSearchCacheClient _recentSearchCacheClient;
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
      _recentSearchCacheClient.clearAllData(),
      _accountCacheClient.clearAllData(),
      _localSpamReportManager.clear(),
      if (PlatformInfo.isMobile)
        ...[
          _sessionHiveCacheClient.clearAllData(),
          _newEmailHiveCacheClient.clearAllData(),
          _openedEmailHiveCacheClient.clearAllData(),
          _clearSendingEmailCache(),
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
      _recentSearchCacheClient.clearAllData(),
      _localSpamReportManager.clear(),
      if (PlatformInfo.isMobile)
       ...[
         _newEmailHiveCacheClient.clearAllData(),
         _openedEmailHiveCacheClient.clearAllData(),
         _clearSendingEmailCache(),
       ]
    ], eagerError: true);
  }

  Future<void> clearEmailCacheAndStateCacheByTupleKey(AccountId accountId, Session session) {
    return Future.wait([
      _stateCacheClient.deleteItem(StateType.email.getTupleKeyStored(accountId, session.username)),
      _emailCacheClient.clearAllData(),
    ], eagerError: true);
  }

  Future<void> clearEmailCacheAndAllStateCache() {
    return Future.wait([
      _stateCacheClient.clearAllData(),
      _emailCacheClient.clearAllData(),
    ], eagerError: true);
  }

  Future<void> onUpgradeCache(int oldVersion, int newVersion) async {
    log('CachingManager::onUpgradeCache():oldVersion $oldVersion | newVersion: $newVersion');
    await clearData();
    if (oldVersion > 0 && oldVersion < newVersion && newVersion == 7) {
      await clearAll();
    }
    await storeCacheVersion(newVersion);
  }

  Future<bool> storeCacheVersion(int newVersion) async {
    log('CachingManager::storeCacheVersion()');
    return _hiveCacheVersionClient.storeVersion(newVersion);
  }

  Future<int?> getLatestVersion() {
    return _hiveCacheVersionClient.getLatestVersion();
  }

  Future<void> closeHive() async {
    return await HiveCacheConfig().closeHive();
  }

  Future<void> clearAllFileInStorage() async {
    await Future.wait([
      _fileUtils.removeFolder(CachingConstants.newEmailsContentFolderName),
      _fileUtils.removeFolder(CachingConstants.openedEmailContentFolderName),
    ]);
  }

  Future<void> _clearSendingEmailCache() async {
    final listSendingEmails = await _sendingEmailCacheManager.getAllSendingEmails();
    final sendingIds = listSendingEmails.map((sendingEmail) => sendingEmail.sendingId).toSet().toList();
    if (sendingIds.isNotEmpty) {
      await _sendingEmailCacheManager.clearAllSendingEmails();
    }
  }
}
