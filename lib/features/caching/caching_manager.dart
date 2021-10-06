
import 'package:tmail_ui_user/features/caching/mailbox_cache_client.dart';
import 'package:tmail_ui_user/features/caching/state_cache_client.dart';

class CachingManager {

  final MailboxCacheClient _mailboxCacheClient;
  final StateCacheClient _stateCacheClient;

  CachingManager(this._mailboxCacheClient, this._stateCacheClient);

  Future<void> clearAll() async {
    await Future.wait([
      _stateCacheClient.deleteBox(),
      _mailboxCacheClient.deleteBox(),
    ]);
  }
}