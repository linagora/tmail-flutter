import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';

extension ListMailboxNodeExtension on List<MailboxNode> {
  List<MailboxId> get mailboxIds => map((node) => node.item.id).toList();

  void insertAfterInbox(MailboxNode newNode) {
    final alreadyExists = any((node) => node.item.id == newNode.item.id);
    if (alreadyExists) return;

    final index = indexWhere(
      (node) =>
          node.item.role?.value == PresentationMailbox.inboxRole ||
          node.item.name?.name.toLowerCase() == 'inbox',
    );

    if (index != -1) {
      insert(index + 1, newNode);
    } else {
      insert(0, newNode);
    }
  }
}
