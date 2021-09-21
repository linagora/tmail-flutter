import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

extension PresentationMailboxExtension on PresentationMailbox {

  PresentationMailbox toPresentationMailboxWithMailboxPath(String mailboxPath) {
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
      isSubscribed: isSubscribed,
      selectMode: selectMode,
      mailboxPath: mailboxPath
    );
  }

  Mailbox toMailbox() {
    return Mailbox(
      id,
      name,
      parentId,
      role,
      sortOrder,
      totalEmails,
      unreadEmails,
      totalThreads,
      unreadThreads,
      myRights,
      isSubscribed
    );
  }
}