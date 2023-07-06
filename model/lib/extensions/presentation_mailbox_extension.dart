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
      mailboxPath: mailboxPath,
      state: state,
      namespace: namespace,
      displayName: displayName,
    );
  }

  PresentationMailbox withDisplayName(String? displayName) {
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
      mailboxPath: mailboxPath,
      state: state,
      namespace: namespace,
      displayName: displayName,
    );
  }

  PresentationMailbox withMailboxSate(MailboxState newMailboxState) {
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
      mailboxPath: mailboxPath,
      state: newMailboxState,
      namespace: namespace,
      displayName: displayName,
    );
  }

  Mailbox toMailbox() {
    return Mailbox(
      id: id,
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
      namespace: namespace,
    );
  }

  PresentationMailbox toggleSelectPresentationMailbox() {
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
      mailboxPath: mailboxPath,
      selectMode: selectMode == SelectMode.INACTIVE ? SelectMode.ACTIVE : SelectMode.INACTIVE,
      state: state,
      namespace: namespace,
      displayName: displayName,
    );
  }

  PresentationMailbox toSelectedPresentationMailbox({required SelectMode selectMode}) {
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
      mailboxPath: mailboxPath,
      selectMode: selectMode,
      state: state,
      namespace: namespace,
      displayName: displayName,
    );
  }
}