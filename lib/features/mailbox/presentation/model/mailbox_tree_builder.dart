import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/mailbox_name_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/mailbox_state.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';

import 'mailbox_node.dart';
import 'mailbox_tree.dart';

class TreeBuilder {
  Future<MailboxTree> generateMailboxTree(List<PresentationMailbox> mailboxesList) async {
    final Map<MailboxId, MailboxNode> mailboxDictionary = HashMap();

    final tree = MailboxTree(MailboxNode.root());
    for (var mailbox in mailboxesList) {
      mailboxDictionary[mailbox.id] = MailboxNode(mailbox);
    }
    for (var mailbox in mailboxesList) {
      final node = mailboxDictionary[mailbox.id];
      if (node == null) continue;

      final parentId = mailbox.parentId;
      final parentNode = mailboxDictionary[parentId];
      if (parentNode != null) {
        parentNode.addChildNode(node);
        sortByMailboxNameNodeChildren(parentNode);
      } else {
        tree.root.addChildNode(node);
        sortByMailboxNameNodeChildren(tree.root);
      }
    }
    return tree;
  }

  Future<({
    List<PresentationMailbox> allMailboxes,
    MailboxTree defaultTree,
    MailboxTree personalTree,
    MailboxTree teamMailboxTree
  })> generateMailboxTreeInUI({
    required List<PresentationMailbox> allMailboxes,
    required MailboxTree currentDefaultTree,
    required MailboxTree currentPersonalTree,
    required MailboxTree currentTeamMailboxTree,
    MailboxId? mailboxIdSelected,
  }) async {
    final Map<MailboxId, MailboxNode> mailboxDictionary = HashMap();

    final newDefaultTree = MailboxTree(MailboxNode.root());
    final newPersonalTree = MailboxTree(MailboxNode.root());
    final newTeamMailboxTree = MailboxTree(MailboxNode.root());
  
    final List<PresentationMailbox> newAllMailboxes = <PresentationMailbox>[];

    for (var mailbox in allMailboxes) {
      final currentMailboxNode = findExistingNode(
        id: mailbox.id,
        currentDefaultTree: currentDefaultTree,
        currentPersonalTree: currentPersonalTree,
        currentTeamMailboxTree: currentTeamMailboxTree,
      );

      final isDeactivated = mailbox.id == mailboxIdSelected;
      final newMailboxNode = MailboxNode(
        isDeactivated ? mailbox.withMailboxSate(MailboxState.deactivated) : mailbox,
        nodeState: isDeactivated ? MailboxState.deactivated : MailboxState.activated,
        expandMode: currentMailboxNode?.expandMode ?? ExpandMode.COLLAPSE,
        selectMode: currentMailboxNode?.selectMode ?? SelectMode.INACTIVE,
      );

      mailboxDictionary[mailbox.id] = newMailboxNode;
    }

    for (var mailbox in allMailboxes) {
      final currentNode = mailboxDictionary[mailbox.id];
      if (currentNode == null) continue;

      final parentId = mailbox.parentId;
      final parentNode = parentId != null ? mailboxDictionary[parentId] : null;

      if (parentNode != null) {
        if (parentNode.nodeState == MailboxState.deactivated) {
          currentNode.updateItem(mailbox.withMailboxSate(MailboxState.deactivated));
          currentNode.updateNodeState(MailboxState.deactivated);
        }
        parentNode.addChildNode(currentNode);

        sortByMailboxNameNodeChildren(parentNode);
      } else {
        final targetTree = mailbox.hasRole()
          ? newDefaultTree
          : (mailbox.isPersonal ? newPersonalTree : newTeamMailboxTree);
        targetTree.root.addChildNode(currentNode);

        sortByMailboxNameNodeChildren(targetTree.root);
      }

      newAllMailboxes.add(currentNode.item);
    }

    sortNodeChildren(newDefaultTree.root);

    return (
      allMailboxes: newAllMailboxes,
      defaultTree: newDefaultTree,
      personalTree: newPersonalTree,
      teamMailboxTree: newTeamMailboxTree,
    );
  }

  Future<({
    MailboxTree defaultTree,
    MailboxTree personalTree,
    MailboxTree teamMailboxTree
  })> generateMailboxTreeInUIAfterRefreshChanges({
    required List<PresentationMailbox> allMailboxes,
    required MailboxTree currentDefaultTree,
    required MailboxTree currentPersonalTree,
    required MailboxTree currentTeamMailboxTree,
  }) async {
    final Map<MailboxId, MailboxNode> mailboxDictionary = HashMap();

    final newDefaultTree = MailboxTree(MailboxNode.root());
    final newPersonalTree = MailboxTree(MailboxNode.root());
    final newTeamMailboxTree = MailboxTree(MailboxNode.root());

    for (var mailbox in allMailboxes) {
      final currentMailboxNode = findExistingNode(
        id: mailbox.id,
        currentDefaultTree: currentDefaultTree,
        currentPersonalTree: currentPersonalTree,
        currentTeamMailboxTree: currentTeamMailboxTree,
      );

      final newMailboxNode = MailboxNode(
        mailbox,
        expandMode: currentMailboxNode?.expandMode ?? ExpandMode.COLLAPSE,
        selectMode: currentMailboxNode?.selectMode ?? SelectMode.INACTIVE,
      );

      mailboxDictionary[mailbox.id] = newMailboxNode;
    }

    for (var mailbox in allMailboxes) {
      final currentNode = mailboxDictionary[mailbox.id];
      if (currentNode == null) continue;

      final parentId = mailbox.parentId;
      final parentNode = parentId != null ? mailboxDictionary[parentId] : null;

      if (parentNode != null) {
        parentNode.addChildNode(currentNode);
        sortByMailboxNameNodeChildren(parentNode);
      } else {
        final targetTree = mailbox.hasRole()
          ? newDefaultTree
          : (mailbox.isPersonal ? newPersonalTree : newTeamMailboxTree);
        targetTree.root.addChildNode(currentNode);

        sortByMailboxNameNodeChildren(targetTree.root);
      }
    }

    sortNodeChildren(newDefaultTree.root);

    return (
      defaultTree: newDefaultTree,
      personalTree: newPersonalTree,
      teamMailboxTree: newTeamMailboxTree,
    );
  }

  void sortNodeChildren(MailboxNode mailboxNode) {
    mailboxNode.childrenItems?.sort((a, b) => a.compareTo(b));
  }

  void sortByMailboxNameNodeChildren(MailboxNode mailboxNode) {
    mailboxNode.childrenItems?.sortByCompare<MailboxName?>(
      (node) => node.item.name,
      (name, other) => name?.compareAlphabetically(other) ?? -1,
    );
  }

  MailboxNode? findExistingNode({
    required MailboxId id,
    required MailboxTree currentDefaultTree,
    required MailboxTree currentPersonalTree,
    required MailboxTree currentTeamMailboxTree,
  }) {
    return currentDefaultTree.findNode((node) => node.item.id == id) ??
      currentPersonalTree.findNode((node) => node.item.id == id) ??
      currentTeamMailboxTree.findNode((node) => node.item.id == id);
  }
}