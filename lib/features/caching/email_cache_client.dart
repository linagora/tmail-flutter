
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_cache.dart';

class EmailCacheClient extends HiveCacheClient<EmailCache> {

  @override
  String get tableName => 'EmailCache';

  Future<List<EmailCache>> getListEmailCacheByMailboxId(MailboxId mailboxId) {
    return Future.sync(() async {
      final boxEmail = await openBox();
      return boxEmail.values.where((emailCache) {
        return emailCache.mailboxIds != null
          && emailCache.mailboxIds!.containsKey(mailboxId.id.value)
          && emailCache.mailboxIds![mailboxId.id.value] == true;
      }).toList();
    }).catchError((error) {
      throw error;
    });
  }
}