import 'package:flutter/foundation.dart';
import 'package:tmail_ui_user/features/caching/account_cache_client.dart';
import 'package:tmail_ui_user/features/caching/email_cache_client.dart';
import 'package:tmail_ui_user/features/caching/fcm_token_cache_client.dart';
import 'package:tmail_ui_user/features/caching/mailbox_cache_client.dart';
import 'package:tmail_ui_user/features/caching/recent_search_cache_client.dart';
import 'package:tmail_ui_user/features/caching/state_cache_client.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';

class CachingManager {
  final MailboxCacheClient _mailboxCacheClient;
  final StateCacheClient _stateCacheClient;
  final EmailCacheClient _emailCacheClient;
  final RecentSearchCacheClient _recentSearchCacheClient;
  final AccountCacheClient _accountCacheClient;
  final FcmTokenCacheClient _fcmTokenCacheClient;

  CachingManager(
    this._mailboxCacheClient,
    this._stateCacheClient,
    this._emailCacheClient,
    this._recentSearchCacheClient,
    this._accountCacheClient,
    this._fcmTokenCacheClient,
  );

  Future<void> clearAll() async {
    if (kIsWeb) {
      await Future.wait([
        _stateCacheClient.clearAllData(),
        _mailboxCacheClient.clearAllData(),
        _emailCacheClient.clearAllData(),
        _recentSearchCacheClient.clearAllData(),
        _accountCacheClient.clearAllData(),
        _fcmTokenCacheClient.clearAllData(),
      ]);
    } else {
      await Future.wait([
        _stateCacheClient.deleteBox(),
        _mailboxCacheClient.deleteBox(),
        _emailCacheClient.deleteBox(),
        _recentSearchCacheClient.deleteBox(),
        _accountCacheClient.deleteBox(),
        _fcmTokenCacheClient.deleteBox(),
      ]);
    }
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
}
