import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

extension ListMailboxExtension on List<PresentationMailbox> {

  PresentationMailbox? findMailboxInList(MailboxId? mailboxId) {
    if (mailboxId != null) {
      final listMailbox = where((item) => item.id == mailboxId).toList();
      if (listMailbox.isNotEmpty) {
        return listMailbox.first;
      }
    }
    return null;
  }

  void sortBySortOrderAndQualifiedName() {
    // sort((mailbox1, mailbox2) {
    //   if (mailbox1.qualifiedName != null && mailbox2.qualifiedName != null) {
    //     return mailbox1.qualifiedName!.compareToSort(mailbox2.qualifiedName!);
    //   } else if (mailbox1.sortOrder != null && mailbox2.sortOrder != null) {
    //     return mailbox1.sortOrder!.compareToSort(mailbox2.sortOrder!);
    //   }
    //   return 0;
    // });
  }
}