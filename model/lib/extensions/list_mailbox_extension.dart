
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

extension ListMailboxExtension on List<Mailbox> {

  Mailbox? findMailbox(MailboxId mailboxId) {
    try {
      return firstWhere((element) => element.id == mailboxId);
    } catch (e) {
      return null;
    }
  }
}