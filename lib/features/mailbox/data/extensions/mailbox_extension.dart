import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_cache.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/mailbox_rights_extension.dart';

extension MailboxExtension on Mailbox {

  MailboxCache toMailboxCache() {
    return MailboxCache(
      id!.id.value,
      name: name?.name,
      parentId: parentId?.id.value,
      role: role?.value,
      sortOrder: sortOrder?.value.value.round(),
      totalEmails: totalEmails?.value.value.round(),
      unreadEmails: unreadEmails?.value.value.round(),
      totalThreads: totalThreads?.value.value.round(),
      unreadThreads: unreadThreads?.value.value.round(),
      myRights: myRights != null ? myRights!.toMailboxRightsCache() : null,
      isSubscribed: isSubscribed?.value
    );
  }

  int compareTo(Mailbox other) {
    return this.sortOrder!.value.value.compareTo(other.sortOrder!.value.value);
  }
}