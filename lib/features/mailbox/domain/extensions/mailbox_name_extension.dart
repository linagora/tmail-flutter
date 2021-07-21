import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

extension MailboxNameExtension on MailboxName {
  int compareToSort(MailboxName mailboxName) => name.compareTo(mailboxName.name);
}