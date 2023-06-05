import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:tmail_ui_user/features/caching/clients/account_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/detailed_email_hive_cache_client.dart';
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
  final FileUtils _fileUtils;

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
    this._fileUtils,
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
      _detailedEmailHiveCacheClient.clearAllData(),
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
      _detailedEmailHiveCacheClient.clearAllData(),
    ], eagerError: true);
  }

  Future<void> clearEmailCache() async {
    await Future.wait([
      _stateCacheClient.deleteItem(StateType.email.value),
      _emailCacheClient.clearAllData(),
    ], eagerError: true);
    log('CachingManager::clearEmailCache(): success');
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
    _fileUtils.removeFolder(CachingConstants.incomingEmailedContentFolderName);
  }
}
