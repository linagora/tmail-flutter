import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:tmail_ui_user/features/caching/clients/account_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/detailed_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/opened_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/session_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/caching/clients/email_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/fcm_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/hive_cache_version_client.dart';
import 'package:tmail_ui_user/features/caching/clients/mailbox_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/recent_search_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/state_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/subscription_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/features/offline_mode/controller/work_scheduler_controller.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/sending_email_cache_manager.dart';

class CachingManager {
  final MailboxCacheClient _mailboxCacheClient;
  final StateCacheClient _stateCacheClient;
  final EmailCacheClient _emailCacheClient;
  final RecentSearchCacheClient _recentSearchCacheClient;
  final AccountCacheClient _accountCacheClient;
  final FcmCacheClient _fcmCacheClient;
  final FCMSubscriptionCacheClient _fcmSubscriptionCacheClient;
  final HiveCacheVersionClient _hiveCacheVersionClient;
  final DetailedEmailHiveCacheClient _detailedEmailHiveCacheClient;
  final OpenedEmailHiveCacheClient _openedEmailHiveCacheClient;
  final FileUtils _fileUtils;
  final SendingEmailCacheManager _sendingEmailCacheManager;
  final SessionHiveCacheClient _sessionHiveCacheClient;

  CachingManager(
    this._mailboxCacheClient,
    this._stateCacheClient,
    this._emailCacheClient,
    this._recentSearchCacheClient,
    this._accountCacheClient,
    this._fcmCacheClient,
    this._fcmSubscriptionCacheClient,
    this._hiveCacheVersionClient,
    this._detailedEmailHiveCacheClient,
    this._openedEmailHiveCacheClient,
    this._fileUtils,
    this._sendingEmailCacheManager,
    this._sessionHiveCacheClient,
  );

  Future<void> clearAll() async {
    await Future.wait([
      _stateCacheClient.clearAllData(),
      _mailboxCacheClient.clearAllData(),
      _emailCacheClient.clearAllData(),
      _fcmCacheClient.clearAllData(),
      _fcmSubscriptionCacheClient.clearAllData(),
      _recentSearchCacheClient.clearAllData(),
      _accountCacheClient.clearAllData(),
      if (PlatformInfo.isMobile)
        ...[
          _sessionHiveCacheClient.clearAllData(),
          _detailedEmailHiveCacheClient.clearAllData(),
          _openedEmailHiveCacheClient.clearAllData(),
          _clearSendingEmailCache(),
        ]
    ], eagerError: true);
  }

  Future<void> clearData() async {
    await Future.wait([
      _stateCacheClient.clearAllData(),
      _mailboxCacheClient.clearAllData(),
      _emailCacheClient.clearAllData(),
      _fcmCacheClient.clearAllData(),
      _fcmSubscriptionCacheClient.clearAllData(),
      _recentSearchCacheClient.clearAllData(),
      if (PlatformInfo.isMobile)
       ...[
         _detailedEmailHiveCacheClient.clearAllData(),
         _openedEmailHiveCacheClient.clearAllData(),
         _clearSendingEmailCache(),
       ]
    ], eagerError: true);
  }

  Future<void> clearEmailCache() {
    return Future.wait([
      _stateCacheClient.deleteItem(StateType.email.value),
      _emailCacheClient.clearAllData(),
    ], eagerError: true);
  }

  Future<void> onUpgradeCache(int oldVersion, int newVersion) async {
    log('CachingManager::onUpgradeCache():oldVersion $oldVersion | newVersion: $newVersion');
    await clearData();
    await storeCacheVersion(newVersion);
    return Future.value();
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

  void clearAllFileInStorage() {
    if (PlatformInfo.isMobile) {
      _fileUtils.removeFolder(CachingConstants.incomingEmailedContentFolderName);
      _fileUtils.removeFolder(CachingConstants.openedEmailContentFolderName);
    }
  }

  Future<void> _clearSendingEmailCache() async {
    final listSendingEmails = await _sendingEmailCacheManager.getAllSendingEmails();
    final sendingIds = listSendingEmails.map((sendingEmail) => sendingEmail.sendingId).toSet().toList();
    if (sendingIds.isNotEmpty) {
      await Future.wait(
        sendingIds.map(WorkSchedulerController().cancelByUniqueId),
        eagerError: true
      );
      await _sendingEmailCacheManager.clearAllSendingEmails();
    }
  }
}
