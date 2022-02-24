
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/select_mode.dart';
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

  List<MailboxNode>? toggleSelectMailboxNode(MailboxNode selectedMailboxMode) {
    return map((MailboxNode child) {
      if (child.item.id == selectedMailboxMode.item.id) {
        return child.toggleSelectMailboxNode();
      } else {
        if (child.hasChildren()) {
          return child.copyWith(mailboxNodes: child.toggleSelectNode(selectedMailboxMode));
        }
        return child;
      }
    }).toList();
  }

  List<MailboxNode>? toSelectMailboxNode({required SelectMode selectMode, ExpandMode? newExpandMode}) {
    return map((MailboxNode child) {
      if (child.hasChildren()) {
        return child.copyWith(
            mailboxNodes: child.toSelectedNode(selectMode: selectMode, newExpandMode: newExpandMode),
            newSelectMode: selectMode,
            newExpandMode: newExpandMode);
      }
      return child.toSelectedMailboxNode(selectMode: selectMode, newExpandMode: newExpandMode);
    }).toList();
  }
}