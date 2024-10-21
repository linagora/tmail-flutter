import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

extension MailboxExtension on Mailbox {

  bool hasRole() => role != null && role!.value.isNotEmpty;

  bool get isSpam => role == PresentationMailbox.roleSpam || role == PresentationMailbox.roleJunk;

  bool get isTrash => role == PresentationMailbox.roleTrash;

  bool get isDrafts => role == PresentationMailbox.roleDrafts;

  bool get isSent => role == PresentationMailbox.roleSent;

  bool get isOutbox => name?.name == PresentationMailbox.outboxRole || role == PresentationMailbox.roleOutbox;

  bool get pushNotificationDeactivated => isOutbox || isSent || isDrafts || isTrash || isSpam;

  PresentationMailbox toPresentationMailbox() {
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
      namespace: namespace,
      rights: rights
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
      namespace: updatedProperties.contain(MailboxProperty.namespace) ? newMailbox.namespace : namespace,
      rights: updatedProperties.contain(MailboxProperty.rights) ? newMailbox.rights : rights,
    );
  }

  Mailbox toMailbox(MailboxName mailboxName, {MailboxId? parentId, Role? mailboxRole}) {
    return Mailbox(
        id: id,
        name: mailboxName,
        parentId: parentId,
        role: mailboxRole ?? role,
        sortOrder: sortOrder,
        totalEmails: totalEmails,
        unreadEmails: unreadEmails,
        totalThreads: totalThreads,
        unreadThreads: unreadThreads,
        myRights: myRights,
        isSubscribed: isSubscribed,
        namespace: namespace,
        rights: rights
    );
  }
}