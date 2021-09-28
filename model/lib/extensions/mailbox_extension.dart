import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

extension MailboxExtension on Mailbox {

  bool hasRole() => role != null && role!.value.isNotEmpty;

  PresentationMailbox toPresentationMailbox({SelectMode selectMode = SelectMode.INACTIVE}) {
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
      selectMode: selectMode
    );
  }

  MailboxCache toMailboxCache() {
    return MailboxCache(
      id.id.value,
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

  Mailbox combineMailbox(Mailbox newMailbox, Properties updatedProperties) {
    return Mailbox(
      newMailbox.id,
      updatedProperties.contain(MailboxProperty.name) ? newMailbox.name : name,
      updatedProperties.contain(MailboxProperty.parentId) ? newMailbox.parentId : parentId,
      updatedProperties.contain(MailboxProperty.role) ? newMailbox.role : role,
      updatedProperties.contain(MailboxProperty.sortOrder) ? newMailbox.sortOrder : sortOrder,
      updatedProperties.contain(MailboxProperty.totalEmails) ? newMailbox.totalEmails : totalEmails,
      updatedProperties.contain(MailboxProperty.unreadEmails) ? newMailbox.unreadEmails : unreadEmails,
      updatedProperties.contain(MailboxProperty.totalThreads) ? newMailbox.totalThreads : totalThreads,
      updatedProperties.contain(MailboxProperty.unreadThreads) ? newMailbox.unreadThreads : unreadThreads,
      updatedProperties.contain(MailboxProperty.myRights) ? newMailbox.myRights : myRights,
      updatedProperties.contain(MailboxProperty.isSubscribed) ? newMailbox.isSubscribed : isSubscribed,
    );
  }
}