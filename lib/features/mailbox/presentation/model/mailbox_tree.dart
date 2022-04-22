
import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/select_mode.dart';

import 'mailbox_node.dart';

typedef NodeQuery = bool Function(MailboxNode node);

class MailboxTree with EquatableMixin {
  MailboxNode root;
  MailboxTree(this.root);

  MailboxNode? findNode(NodeQuery nodeQuery) {
    MailboxNode? result;
    final queue = ListQueue<MailboxNode>();
    queue.addLast(root);
    while (queue.isNotEmpty) {
      final currentNode = queue.removeFirst();
      if (nodeQuery(currentNode)) {
        result = currentNode;
        break;
      }
      currentNode.childrenItems?.forEach((child) {
        queue.addLast(child);
      });
    }
    return result;
  }

  List<MailboxNode> findNodes(NodeQuery nodeQuery) {
    final listResult = List<MailboxNode>.empty(growable: true);
    final queue = ListQueue<MailboxNode>();
    queue.addLast(root);
    while (queue.isNotEmpty) {
      final currentNode = queue.removeFirst();
      if (nodeQuery(currentNode)) {
        listResult.add(currentNode);
      }
      currentNode.childrenItems?.forEach((child) {
        queue.addLast(child);
      });
    }
    return listResult;
  }

  MailboxNode? updateExpandedNode(MailboxNode selectedNode, ExpandMode newExpandMode) {
    var matchedNode = findNode((node) => node.item.id == selectedNode.item.id);
    matchedNode?.expandMode = newExpandMode;
    return matchedNode;
  }

  MailboxNode? updateSelectedNode(MailboxNode selectedNode, SelectMode newSelectMode) {
    var matchedNode = findNode((node) => node.item.id == selectedNode.item.id);
    matchedNode?.selectMode = newSelectMode;
    return matchedNode;
  }

  void updateNodesUIMode(SelectMode? selectMode, ExpandMode? expandMode) {
    if (selectMode == null && expandMode == null) {
      return;
    }
    final queue = ListQueue<MailboxNode>();
    queue.addLast(root);
    while (queue.isNotEmpty) {
      final currentNode = queue.removeFirst();
      if (expandMode != null) {
        currentNode.expandMode = expandMode;
      }
      if (selectMode != null) {
        currentNode.selectMode = selectMode;
      }
      currentNode.childrenItems?.forEach((child) {
        queue.addLast(child);
      });
    }
  }

  String? getNodePath(MailboxId mailboxId) {
    final matchedNode = findNode((node) => node.item.id == mailboxId);
    if (matchedNode == null) {
      return null;
    }
    String path = '${matchedNode.item.name?.name}';

    var parentId = matchedNode.item.parentId;

    while(parentId != null) {
      var parentNode = findNode((node) => node.item.id == parentId);
      if (parentNode == null) {
        break;
      }
      path = '${parentNode.item.name?.name}/$path';
      parentId = parentNode.item.parentId;
    }
    return path;
  }

  @override
  List<Object?> get props => [root];
}