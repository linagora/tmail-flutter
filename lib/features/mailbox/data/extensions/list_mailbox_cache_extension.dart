
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_cache.dart';

extension ListMailboxCacheExtension on List<MailboxCache> {
  Map<String, MailboxCache> toMap() {
    return { for (var mailboxCache in this) mailboxCache.id : mailboxCache };
  }
}