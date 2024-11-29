
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

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

  void updateNodesUIMode({SelectMode? selectMode, ExpandMode? expandMode}) {
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

  String? getNodePath(MailboxId mailboxId, String pathSeparator) {
    final matchedNode = findNode((node) => node.item.id == mailboxId);
    if (matchedNode == null) {
      return null;
    }
    String path = '';
    if (currentContext != null) {
      path = matchedNode.item.getDisplayName(currentContext!);
    } else {
      path = '${matchedNode.item.name?.name}';
    }

    var parentId = matchedNode.item.parentId;

    while(parentId != null) {
      var parentNode = findNode((node) => node.item.id == parentId);
      if (parentNode == null) {
        break;
      }
      if (currentContext != null) {
        path = '${parentNode.item.getDisplayName(currentContext!)}$pathSeparator$path';
      } else {
        path = '${parentNode.item.name?.name}$pathSeparator$path';
      }
      parentId = parentNode.item.parentId;
    }
    return path;
  }

  List<MailboxNode>? getAncestorList(MailboxNode mailboxNode) {
    var parentId = mailboxNode.item.parentId;
    List<MailboxNode> ancestor = <MailboxNode>[];
    while(parentId != null) {
      final parentNode = findNode((node) => node.item.id == parentId);
      if (parentNode == null) {
        break;
      }
      ancestor.add(parentNode);
      parentId = parentNode.item.parentId;
    }
    return ancestor.isNotEmpty ? ancestor : null;
  }

  Map<Role, PresentationMailbox> get mapPresentationMailboxByRole {
    if (root.childrenItems?.isNotEmpty == true) {
      final listPresentationMailboxHasRole = root.childrenItems!
        .where((node) => node.item.role != null)
        .map((node) => node.item)
        .toList();

      return {
        for (var mailbox in listPresentationMailboxHasRole)
          mailbox.role!: mailbox
      };
    } else {
      return {};
    }
  }

  MailboxNode? findNodeOnFirstLevel(NodeQuery nodeQuery) => root.childrenItems?.firstWhereOrNull(nodeQuery);

  @override
  List<Object?> get props => [root];
}