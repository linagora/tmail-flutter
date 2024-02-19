
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

class FcmConstants {
  static final List<Role> mailboxRuleDoNotAllowPushNotifications = [
    PresentationMailbox.roleDrafts,
    PresentationMailbox.roleSent,
    PresentationMailbox.roleOutbox,
    PresentationMailbox.roleSpam,
    PresentationMailbox.roleTrash
  ];

  static const String firebaseRegistrationExpiredTimeProperty = 'expires';

  static const int MAX_NUMBER_NEW_EMAILS_RETRIEVED = 5;
}