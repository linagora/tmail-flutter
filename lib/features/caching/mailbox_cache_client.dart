
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_cache.dart';

class MailboxCacheClient extends HiveCacheClient<MailboxCache> {

  @override
  String get tableName => 'MailboxCache';
}