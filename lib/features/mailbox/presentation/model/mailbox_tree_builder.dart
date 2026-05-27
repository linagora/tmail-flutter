import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/mailbox_name_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/mailbox_state.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_collection.dart';

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

  Future<MailboxCollection> generateMailboxTreeInUI({
    required List<PresentationMailbox> allMailboxes,
    required MailboxCollection currentCollection,
    MailboxId? mailboxIdSelected,
    MailboxId? mailboxIdExpanded,
  }) async {
    final Map<MailboxId, MailboxNode> mailboxDictionary = HashMap();

    final newDefaultTree = MailboxTree(MailboxNode.root());
    final newPersonalTree = MailboxTree(MailboxNode.root());
    final newTeamMailboxTree = MailboxTree(MailboxNode.root());
  
    final List<PresentationMailbox> newAllMailboxes = <PresentationMailbox>[];

    for (var mailbox in allMailboxes) {
      final currentMailboxNode = findExistingNode(
        id: mailbox.id,
        currentCollection: currentCollection,
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

      _placeNodeInTree(
        mailbox: mailbox,
        currentNode: currentNode,
        mailboxDictionary: mailboxDictionary,
        defaultTree: newDefaultTree,
        personalTree: newPersonalTree,
        teamMailboxTree: newTeamMailboxTree,
        onBeforeAddToParent: (parent, child) =>
            _propagateDeactivationIfNeeded(parent, child, mailbox),
      );

      newAllMailboxes.add(currentNode.item);
    }

    _finalizeTrees(newDefaultTree, newTeamMailboxTree);

    return MailboxCollection(
      allMailboxes: newAllMailboxes,
      defaultTree: newDefaultTree,
      personalTree: newPersonalTree,
      teamMailboxTree: newTeamMailboxTree,
    );
  }

  Future<MailboxCollection> generateMailboxTreeInUIAfterRefreshChanges({
    required List<PresentationMailbox> allMailboxes,
    required MailboxCollection currentCollection,
  }) async {
    final Map<MailboxId, MailboxNode> mailboxDictionary = HashMap();

    final newDefaultTree = MailboxTree(MailboxNode.root());
    final newPersonalTree = MailboxTree(MailboxNode.root());
    final newTeamMailboxTree = MailboxTree(MailboxNode.root());

    for (var mailbox in allMailboxes) {
      final currentMailboxNode = findExistingNode(
        id: mailbox.id,
        currentCollection: currentCollection,
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

      _placeNodeInTree(
        mailbox: mailbox,
        currentNode: currentNode,
        mailboxDictionary: mailboxDictionary,
        defaultTree: newDefaultTree,
        personalTree: newPersonalTree,
        teamMailboxTree: newTeamMailboxTree,
      );
    }

    _finalizeTrees(newDefaultTree, newTeamMailboxTree);

    return MailboxCollection(
      allMailboxes: allMailboxes,
      defaultTree: newDefaultTree,
      personalTree: newPersonalTree,
      teamMailboxTree: newTeamMailboxTree,
    );
  }

  void _placeNodeInTree({
    required PresentationMailbox mailbox,
    required MailboxNode currentNode,
    required Map<MailboxId, MailboxNode> mailboxDictionary,
    required MailboxTree defaultTree,
    required MailboxTree personalTree,
    required MailboxTree teamMailboxTree,
    void Function(MailboxNode parent, MailboxNode child)? onBeforeAddToParent,
  }) {
    final parentId = mailbox.parentId;
    final parentNode = parentId != null ? mailboxDictionary[parentId] : null;

    if (parentNode != null) {
      onBeforeAddToParent?.call(parentNode, currentNode);
      parentNode.addChildNode(currentNode);
      sortByMailboxNameNodeChildren(parentNode);
    } else {
      final targetTree = _resolveTargetTree(mailbox, defaultTree, personalTree, teamMailboxTree);
      targetTree.root.addChildNode(currentNode);
      sortByMailboxNameNodeChildren(targetTree.root);
    }
  }

  void _finalizeTrees(MailboxTree defaultTree, MailboxTree teamMailboxTree) {
    sortNodeChildren(defaultTree.root);
    _sortTeamMailboxChildrenAlphabetically(teamMailboxTree.root);
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

  static const Map<String, int> _systemFolderRoleIndex = {
    PresentationMailbox.inboxRole:     0,
    PresentationMailbox.draftsRole:    1,
    PresentationMailbox.outboxRole:    2,
    PresentationMailbox.sentRole:      3,
    PresentationMailbox.trashRole:     4,
    PresentationMailbox.spamRole:      5,
    PresentationMailbox.junkRole:      6,
    PresentationMailbox.templatesRole: 7,
    PresentationMailbox.archiveRole:   8,
  };

  int _systemFolderSortIndex(MailboxNode node) {
    return _systemFolderRoleIndex[node.item.role?.value ?? '']
        ?? _systemFolderRoleIndex.length;
  }

  void _sortWithSystemFoldersFirst(MailboxNode node) {
    node.childrenItems?.sort((a, b) {
      final aIndex = _systemFolderSortIndex(a);
      final bIndex = _systemFolderSortIndex(b);
      final aIsSystem = aIndex < _systemFolderRoleIndex.length;
      final bIsSystem = bIndex < _systemFolderRoleIndex.length;
      if (aIsSystem && bIsSystem) return aIndex.compareTo(bIndex);
      if (aIsSystem) return -1;
      if (bIsSystem) return 1;
      return a.item.name?.compareAlphabetically(b.item.name) ?? -1;
    });
  }

  void _sortTeamMailboxChildrenAlphabetically(MailboxNode node) {
    if (node.childrenItems == null || node.childrenItems!.isEmpty) return;
    if (node.item.isTeamMailboxes) {
      _sortWithSystemFoldersFirst(node);
    } else {
      sortByMailboxNameNodeChildren(node);
    }
    for (final child in node.childrenItems!) {
      _sortTeamMailboxChildrenAlphabetically(child);
    }
  }

  MailboxNode? findExistingNode({
    required MailboxId id,
    required MailboxCollection currentCollection,
  }) {
    return currentCollection.defaultTree.findNode((node) => node.item.id == id) ??
      currentCollection.personalTree.findNode((node) => node.item.id == id) ??
      currentCollection.teamMailboxTree.findNode((node) => node.item.id == id);
  }

  MailboxTree _resolveTargetTree(
    PresentationMailbox mailbox,
    MailboxTree defaultTree,
    MailboxTree personalTree,
    MailboxTree teamMailboxTree,
  ) {
    if (mailbox.hasRole()) return defaultTree;
    return mailbox.isPersonal ? personalTree : teamMailboxTree;
  }

  void _propagateDeactivationIfNeeded(
    MailboxNode parentNode,
    MailboxNode currentNode,
    PresentationMailbox mailbox,
  ) {
    if (parentNode.nodeState != MailboxState.deactivated) return;
    currentNode.updateItem(mailbox.withMailboxSate(MailboxState.deactivated));
    currentNode.updateNodeState(MailboxState.deactivated);
  }
}