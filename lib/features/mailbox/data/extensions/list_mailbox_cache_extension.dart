
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_cache.dart';

extension ListMailboxCacheExtension on List<MailboxCache> {
  Map<String, MailboxCache> toMap() {
    return Map<String, MailboxCache>.fromIterable(
        this,
        key: (mailboxCache) => mailboxCache.id,
        value: (mailboxCache) => mailboxCache);
  }
}