
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

extension MailboxCacheExtension on MailboxCache {
  Mailbox toMailbox() {
    return Mailbox(
        MailboxId(Id(id)),
        name != null ? MailboxName(name!) : null,
        parentId != null ? MailboxId(Id(parentId!)) : null,
        role != null ? Role(role!) : null,
        sortOrder != null ? SortOrder(sortValue: sortOrder!) : null,
        totalEmails != null ? TotalEmails(UnsignedInt(totalEmails!)) : null,
        unreadEmails != null ? UnreadEmails(UnsignedInt(unreadEmails!)) : null,
        totalThreads != null ? TotalThreads(UnsignedInt(totalThreads!)) : null,
        unreadThreads != null ? UnreadThreads(UnsignedInt(unreadThreads!)) : null,
        myRights != null ? myRights!.toMailboxRights() : null,
        isSubscribed != null ? IsSubscribed(isSubscribed!) : null
    );
  }
}