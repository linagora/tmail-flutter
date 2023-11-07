import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:model/mailbox/mailbox_property.dart';

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
    MailboxProperty.namespace
  });
}