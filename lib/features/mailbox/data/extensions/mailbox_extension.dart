import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/mailbox_rights_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_cache.dart';

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
      myRights: myRights?.toMailboxRightsCache(),
      isSubscribed: isSubscribed?.value,
      namespace: namespace?.value,
      rights: rights?.map((key, value) => MapEntry(key, value)),
    );
  }
}