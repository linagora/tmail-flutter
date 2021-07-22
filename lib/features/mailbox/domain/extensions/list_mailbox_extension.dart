import 'package:built_collection/built_collection.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/mailbox_extension.dart';

extension ListPresentationMailboxExtension on List<PresentationMailbox> {

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

extension ListMailboxExtensions on List<Mailbox> {
  Tuple2<List<PresentationMailbox>, List<PresentationMailbox>> splitMailboxList(bool test(Mailbox element)) {
    final validBuilder = ListBuilder<PresentationMailbox>();
    final invalidBuilder = ListBuilder<PresentationMailbox>();
    forEach((element) {
      if (test(element)) {
        validBuilder.add(element.toPresentationMailbox());
      } else {
        invalidBuilder.add(element.toPresentationMailbox());
      }
    });
    return Tuple2(
        validBuilder.build().toList(),
        validBuilder.build().toList());
  }
}