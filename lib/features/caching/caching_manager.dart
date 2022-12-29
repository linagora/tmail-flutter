import 'package:flutter/foundation.dart';
import 'package:tmail_ui_user/features/caching/account_cache_client.dart';
import 'package:tmail_ui_user/features/caching/email_cache_client.dart';
import 'package:tmail_ui_user/features/caching/mailbox_cache_client.dart';
import 'package:tmail_ui_user/features/caching/recent_search_cache_client.dart';
import 'package:tmail_ui_user/features/caching/state_cache_client.dart';
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

  CachingManager(
    this._mailboxCacheClient,
    this._stateCacheClient,
    this._emailCacheClient,
    this._recentSearchCacheClient,
    this._accountCacheClient,
    this._fcmCacheManager,
  );

  Future<void> clearAll() async {
    await Future.wait([
      _stateCacheClient.clearAllData(),
      _mailboxCacheClient.clearAllData(),
      _emailCacheClient.clearAllData(),
      _recentSearchCacheClient.clearAllData(),
      _accountCacheClient.clearAllData(),
      _fcmCacheManager.clearAllStateToRefresh()
    ]);  
  }

  Future<void> cleanEmailCache() async {
    if (kIsWeb) {
      await Future.wait([
        _stateCacheClient.deleteItem(StateType.email.value),
        _emailCacheClient.clearAllData(),
      ]);
    } else {
      await Future.wait([
        _stateCacheClient.deleteItem(StateType.email.value),
        _emailCacheClient.deleteBox(),
      ]);
    }
  }

  Future<void> closeHive() async {
    return await HiveCacheConfig().closeHive();
  }
}
