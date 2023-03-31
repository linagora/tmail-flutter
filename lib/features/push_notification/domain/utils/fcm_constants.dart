
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

class FcmConstants {

  static final List<Role> mailboxRuleAllowPushNotifications = [
    PresentationMailbox.roleDrafts,
    PresentationMailbox.roleSent,
    PresentationMailbox.roleOutbox,
    PresentationMailbox.roleSpam,
    PresentationMailbox.roleTrash
  ];
}