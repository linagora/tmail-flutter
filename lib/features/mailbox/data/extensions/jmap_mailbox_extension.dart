import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart' as JmapMailbox;
import 'package:model/model.dart';

extension JmapMailboxExtension on JmapMailbox.Mailbox {
  PresentationMailbox toMailbox() {
    return PresentationMailbox(
      id,
      name: name,
      parentId: parentId,
      role: role,
      sortOrder: sortOrder,
      totalEmails: totalEmails,
      unreadEmails: unreadEmails,
      totalThreads: totalThreads,
      unreadThreads: unreadThreads,
      myRights: myRights,
      isSubscribed: isSubscribed
    );
  }
}