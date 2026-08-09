
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/mailbox_key.dart';
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

  /// Finds the node identified by [mailboxKey].
  ///
  /// Always prefer this over a raw [findNode] on `item.id`: the same
  /// [MailboxId] can legitimately exist in several accounts, so matching on the
  /// id alone can return another user's mailbox.
  MailboxNode? findNodeByKey(MailboxKey mailboxKey) =>
      findNode((node) => node.item.key == mailboxKey);

  MailboxNode? updateExpandedNode(MailboxNode selectedNode, ExpandMode newExpandMode) {
    var matchedNode = findNodeByKey(selectedNode.item.key);
    matchedNode?.expandMode = newExpandMode;
    return matchedNode;
  }

  MailboxNode? updateSelectedNode(MailboxNode selectedNode, SelectMode newSelectMode) {
    var matchedNode = findNodeByKey(selectedNode.item.key);
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

  bool updateMailboxNameByKey(MailboxKey mailboxKey, MailboxName mailboxName) {
    final matchedNode = findNodeByKey(mailboxKey);
    if (matchedNode != null) {
      matchedNode.item = matchedNode.item.copyWith(name: mailboxName);
      return true;
    }
    return false;
  }

  bool updateMailboxUnreadCountByKey(MailboxKey mailboxKey, int unreadCount) {
    final matchedNode = findNodeByKey(mailboxKey);
    if (matchedNode != null) {
      final currentUnreadCount = matchedNode.item.unreadEmails?.value.value ?? 0;
      final updatedUnreadCount = currentUnreadCount + unreadCount;
      if (updatedUnreadCount < 0) return true;
      matchedNode.item = matchedNode.item.copyWith(
        unreadEmails: UnreadEmails(UnsignedInt(updatedUnreadCount)),
      );
      return true;
    }
    return false;
  }

  bool updateMailboxTotalEmailsCountByKey(MailboxKey mailboxKey, int totalEmailsCount) {
    final matchedNode = findNodeByKey(mailboxKey);
    if (matchedNode != null) {
      final currentTotalEmailsCount = matchedNode.item.totalEmails?.value.value ?? 0;
      final updatedTotalEmailsCount = currentTotalEmailsCount + totalEmailsCount;
      if (updatedTotalEmailsCount < 0) return true;
      matchedNode.item = matchedNode.item.copyWith(
        totalEmails: TotalEmails(UnsignedInt(updatedTotalEmailsCount)),
      );
      return true;
    }
    return false;
  }

  String? getNodePath(MailboxKey mailboxKey, String pathSeparator) {
    final matchedNode = findNodeByKey(mailboxKey);
    if (matchedNode == null) {
      return null;
    }
    String path = '';
    if (currentContext != null) {
      path = matchedNode.item.getDisplayName(currentContext!);
    } else {
      path = '${matchedNode.item.name?.name}';
    }

    // A mailbox's parent always belongs to the same account, so the walk stays
    // inside the starting node's account. Resolving the parent by id alone
    // would let the path cross into another user's identically numbered folder.
    final accountId = mailboxKey.accountId;
    var parentId = matchedNode.item.parentId;

    while(parentId != null) {
      var parentNode = findNodeByKey(MailboxKey(accountId, parentId));
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
    // Same account-scoping reasoning as getNodePath.
    final accountId = mailboxNode.item.key.accountId;
    var parentId = mailboxNode.item.parentId;
    List<MailboxNode> ancestor = <MailboxNode>[];
    while(parentId != null) {
      final parentNode = findNodeByKey(MailboxKey(accountId, parentId));
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