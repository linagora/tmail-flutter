import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_tree.dart';

extension ListMailboxTreeExtension on List<MailboxTree> {

  void sortBySortOrderAndQualifiedName() {
    // sort((mailboxTree1, mailboxTree2) {
    //   if (mailboxTree1.item.qualifiedName != null && mailboxTree2.item.qualifiedName != null) {
    //     return mailboxTree1.item.qualifiedName!.compareToSort(mailboxTree2.item.qualifiedName!);
    //   } else if (mailboxTree1.item.name != null && mailboxTree2.item.name != null) {
    //     return mailboxTree1.item.name!.compareToSort(mailboxTree2.item.name!);
    //   } else if (mailboxTree1.item.sortOrder != null && mailboxTree2.item.sortOrder != null) {
    //     return mailboxTree1.item.sortOrder!.compareToSort(mailboxTree2.item.sortOrder!);
    //   }
    //   return 0;
    // });
  }
}