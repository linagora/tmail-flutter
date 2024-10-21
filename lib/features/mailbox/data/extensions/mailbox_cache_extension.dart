
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/namespace.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/mailbox_rights_cache_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_cache.dart';

extension MailboxCacheExtension on MailboxCache {
  Mailbox toMailbox() {
    return Mailbox(
        id: MailboxId(Id(id)),
        name: name != null ? MailboxName(name!) : null,
        parentId: parentId != null ? MailboxId(Id(parentId!)) : null,
        role: role != null ? Role(role!) : null,
        sortOrder: sortOrder != null ? SortOrder(sortValue: sortOrder!) : null,
        totalEmails: totalEmails != null ? TotalEmails(UnsignedInt(totalEmails!)) : null,
        unreadEmails: unreadEmails != null ? UnreadEmails(UnsignedInt(unreadEmails!)) : null,
        totalThreads: totalThreads != null ? TotalThreads(UnsignedInt(totalThreads!)) : null,
        unreadThreads: unreadThreads != null ? UnreadThreads(UnsignedInt(unreadThreads!)) : null,
        myRights: myRights?.toMailboxRights(),
        isSubscribed: isSubscribed != null ? IsSubscribed(isSubscribed!) : null,
        namespace: namespace != null ? Namespace(namespace!) : null,
        rights: rights != null ? Map<String, List<String>?>.from(rights!) : null,
    );
  }
}