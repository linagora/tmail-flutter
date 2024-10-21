import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/mailbox_property.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

class MailboxConstants {
  static final propertiesDefault = Properties({
    MailboxProperty.id,
    MailboxProperty.name,
    MailboxProperty.parentId,
    MailboxProperty.role,
    MailboxProperty.sortOrder,
    MailboxProperty.isSubscribed,
    MailboxProperty.totalEmails,
    MailboxProperty.totalThreads,
    MailboxProperty.unreadEmails,
    MailboxProperty.unreadThreads,
    MailboxProperty.myRights,
    MailboxProperty.namespace,
    MailboxProperty.rights
  });

  static final List<Role> defaultMailboxRoles = [
    PresentationMailbox.roleInbox,
    PresentationMailbox.roleOutbox,
    PresentationMailbox.roleDrafts,
    PresentationMailbox.roleSent,
    PresentationMailbox.roleTrash,
    PresentationMailbox.roleJunk,
    PresentationMailbox.roleTemplates,
  ];
}