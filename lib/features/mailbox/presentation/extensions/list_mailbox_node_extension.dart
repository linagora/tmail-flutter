
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';

extension ListMailboxNodeExtensions on List<MailboxNode> {
  List<MailboxNode>? updateNode(MailboxId currentMailboxId, MailboxNode newNode) {
    return map((MailboxNode child) {
      if (child.item.id == currentMailboxId) {
        return newNode;
      } else {
        if (child.hasChildren()) {
          return child.copyWith(mailboxNodes: child.updateNode(currentMailboxId, newNode));
        }
        return child;
      }
    }).toList();
  }
}