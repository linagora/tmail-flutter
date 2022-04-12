
import 'package:flutter/foundation.dart';
import 'package:tmail_ui_user/features/caching/email_cache_client.dart';
import 'package:tmail_ui_user/features/caching/mailbox_cache_client.dart';
import 'package:tmail_ui_user/features/caching/state_cache_client.dart';

class CachingManager {

  final MailboxCacheClient _mailboxCacheClient;
  final StateCacheClient _stateCacheClient;
  final EmailCacheClient _emailCacheClient;

  CachingManager(
    this._mailboxCacheClient,
    this._stateCacheClient,
    this._emailCacheClient
  );

  Future<void> clearAll() async {
    if (kIsWeb) {
      await Future.wait([
        _stateCacheClient.clearAllData(),
        _mailboxCacheClient.clearAllData(),
        _emailCacheClient.clearAllData(),
      ]);
    } else {
      await Future.wait([
        _stateCacheClient.deleteBox(),
        _mailboxCacheClient.deleteBox(),
        _emailCacheClient.deleteBox(),
      ]);
    }
  }
}