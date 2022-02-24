
import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

import 'mailbox_node.dart';

class MailboxTree with EquatableMixin {
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
      currentNode.childrenItems?.forEach((child) {
        queue.addLast(child);
      });
    }
    return result;
  }

  List<MailboxNode> getAllNodes(MailboxNode node){
    List<MailboxNode> listOfNodes = <MailboxNode>[];
    _addAllNodes(node, listOfNodes);
    return listOfNodes;
  }

  void _addAllNodes(MailboxNode? node, List<MailboxNode> listOfNodes) {
    if (node != null) {
      listOfNodes.add(node);
      List<MailboxNode>? childrenItems = node.childrenItems;
      if (childrenItems != null) {
        childrenItems.forEach((child) {
          _addAllNodes(child, listOfNodes);
        });
      }
    }
  }

  @override
  List<Object?> get props => [root];
}