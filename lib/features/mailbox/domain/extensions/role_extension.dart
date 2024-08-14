
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

extension RoleExtension on Role {

  String get mailboxName {
    if (this == PresentationMailbox.roleInbox) {
      return 'Inbox';
    } else if (this == PresentationMailbox.roleSent) {
      return 'Sent';
    } else if (this == PresentationMailbox.roleOutbox) {
      return 'Outbox';
    } else if (this == PresentationMailbox.roleDrafts) {
      return 'Drafts';
    } else if (this == PresentationMailbox.roleTrash) {
      return 'Trash';
    } else if (this == PresentationMailbox.roleSpam || this == PresentationMailbox.roleJunk) {
      return 'Spam';
    } else if (this == PresentationMailbox.roleTemplates) {
      return 'Templates';
    } else {
      return '';
    }
  }
}