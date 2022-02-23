import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

extension MailboxExtension on Mailbox {

  bool hasRole() => role != null && role!.value.isNotEmpty;

  PresentationMailbox toPresentationMailbox({SelectMode selectMode = SelectMode.INACTIVE}) {
    return PresentationMailbox(
      id!,
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
      selectMode: selectMode
    );
  }

  Mailbox combineMailbox(Mailbox newMailbox, Properties updatedProperties) {
    return Mailbox(
      id: newMailbox.id,
      name: updatedProperties.contain(MailboxProperty.name) ? newMailbox.name : name,
      parentId: updatedProperties.contain(MailboxProperty.parentId) ? newMailbox.parentId : parentId,
      role: updatedProperties.contain(MailboxProperty.role) ? newMailbox.role : role,
      sortOrder: updatedProperties.contain(MailboxProperty.sortOrder) ? newMailbox.sortOrder : sortOrder,
      totalEmails: updatedProperties.contain(MailboxProperty.totalEmails) ? newMailbox.totalEmails : totalEmails,
      unreadEmails: updatedProperties.contain(MailboxProperty.unreadEmails) ? newMailbox.unreadEmails : unreadEmails,
      totalThreads: updatedProperties.contain(MailboxProperty.totalThreads) ? newMailbox.totalThreads : totalThreads,
      unreadThreads: updatedProperties.contain(MailboxProperty.unreadThreads) ? newMailbox.unreadThreads : unreadThreads,
      myRights: updatedProperties.contain(MailboxProperty.myRights) ? newMailbox.myRights : myRights,
      isSubscribed: updatedProperties.contain(MailboxProperty.isSubscribed) ? newMailbox.isSubscribed : isSubscribed,
    );
  }

  Mailbox addMailboxName(Mailbox newMailbox, MailboxName mailboxName, {MailboxId? parentId}) {
    return Mailbox(
        id: id,
        name: mailboxName,
        parentId: parentId,
        role: role,
        sortOrder: sortOrder,
        totalEmails: totalEmails,
        unreadEmails: unreadEmails,
        totalThreads: totalThreads,
        unreadThreads: unreadThreads,
        myRights: myRights,
        isSubscribed: isSubscribed,
    );
  }
}