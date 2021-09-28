
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

extension ListMailboxCacheExtension on List<MailboxCache> {
  Map<String, MailboxCache> toMap() {
    return Map<String, MailboxCache>.fromIterable(
        this,
        key: (mailboxCache) => mailboxCache.id,
        value: (mailboxCache) => mailboxCache);
  }

  List<Mailbox> toMailboxList() {
    return map((mailboxCache) => mailboxCache.toMailbox()).toList();
  }
}