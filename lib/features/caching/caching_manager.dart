import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/caching/account_cache_client.dart';
import 'package:tmail_ui_user/features/caching/email_cache_client.dart';
import 'package:tmail_ui_user/features/caching/hive_cache_version_client.dart';
import 'package:tmail_ui_user/features/caching/mailbox_cache_client.dart';
import 'package:tmail_ui_user/features/caching/recent_search_cache_client.dart';
import 'package:tmail_ui_user/features/caching/state_cache_client.dart';
import 'package:tmail_ui_user/features/caching/subscription_cache_client.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/features/push_notification/data/local/fcm_cache_manager.dart';

import 'config/hive_cache_config.dart';

class CachingManager {
  final MailboxCacheClient _mailboxCacheClient;
  final StateCacheClient _stateCacheClient;
  final EmailCacheClient _emailCacheClient;
  final RecentSearchCacheClient _recentSearchCacheClient;
  final AccountCacheClient _accountCacheClient;
  final FCMCacheManager _fcmCacheManager;
  final FCMSubscriptionCacheClient _fcmSubscriptionCacheClient;
  final HiveCacheVersionClient _hiveCacheVersionClient;

  CachingManager(
    this._mailboxCacheClient,
    this._stateCacheClient,
    this._emailCacheClient,
    this._recentSearchCacheClient,
    this._accountCacheClient,
    this._fcmCacheManager,
    this._fcmSubscriptionCacheClient,
    this._hiveCacheVersionClient,
  );

  Future<void> clearAll() async {
    await Future.wait([
      _stateCacheClient.clearAllData(),
      _mailboxCacheClient.clearAllData(),
      _emailCacheClient.clearAllData(),
      _recentSearchCacheClient.clearAllData(),
      _accountCacheClient.clearAllData(),
      _fcmSubscriptionCacheClient.clearAllData(),
      _fcmCacheManager.clearAllStateToRefresh()
    ]);  
  }

  Future<void> clearEmailCache() async {
    await Future.wait([
      _stateCacheClient.deleteItem(StateType.email.value),
      _emailCacheClient.clearAllData(),
    ]);
    log('CachingManager::clearEmailCache(): success');
  }

  Future<void> clearMailboxCache() async {
    await Future.wait([
      _stateCacheClient.deleteItem(StateType.mailbox.value),
      _mailboxCacheClient.clearAllData(),
    ]);
    log('CachingManager::clearMailboxCache(): success');
  }

  Future<void> onUpgradeCache(int oldVersion, int newVersion) async {
    log('CachingManager::onUpgradeCache():oldVersion $oldVersion | newVersion: $newVersion');
    if (oldVersion == 0 && newVersion >= 1) {
      await Future.wait([
        clearMailboxCache(),
        clearEmailCache()
      ]);
    }
    storeCacheVersion(newVersion);
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
}
