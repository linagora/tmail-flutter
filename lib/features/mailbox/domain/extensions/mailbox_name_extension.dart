import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

extension MailboxNameExtension on MailboxName {
  int compareAlphabetically(MailboxName? other) {
    if (other == null) {
      return 1;
    }
    return name.toLowerCase().compareTo(other.name.toLowerCase());
  }
}