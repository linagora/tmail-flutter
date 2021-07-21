import 'dart:collection';

import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

import 'mailbox_node.dart';

class MailboxTree {
  MailboxNode root;
  MailboxTree(this.root);

  MailboxNode? findNode(MailboxId? mailboxId) {
    var result;
    final queue = ListQueue<MailboxNode>();
    queue.addLast(root);
    while (queue.isNotEmpty && mailboxId != null) {
      final currentNode = queue.removeFirst();
      if (mailboxId == currentNode.item.id) {
        result = currentNode;
        break;
      }
      currentNode.childrenItems.forEach((child) {
        queue.addLast(child);
      });
    }
    return result;
  }

  MailboxNode? insertNode(PresentationMailbox mailbox, {MailboxNode? parent}) {
    if (mailbox.parentId == null) {
      return root.addChild(mailbox);
    }

    if (parent != null) {
      return parent.addChild(mailbox);
    } else {
      final foundParent = findNode(mailbox.parentId);
      return foundParent?.addChild(mailbox);
    }
  }
}