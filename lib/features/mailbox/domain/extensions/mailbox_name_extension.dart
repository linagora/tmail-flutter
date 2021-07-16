import 'package:model/model.dart';

extension MailboxNameExtension on MailboxName {
  int compareToSort(MailboxName mailboxName) => name.compareTo(mailboxName.name);
}