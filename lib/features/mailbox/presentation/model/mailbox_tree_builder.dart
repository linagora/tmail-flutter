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
    final nodeLookup = _buildNodeLookup(currentCollection);

    for (var mailbox in allMailboxes) {
      final currentMailboxNode = nodeLookup[mailbox.id];

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
        onBeforeAddToParent: _propagateDeactivationIfNeeded,
      );

      newAllMailboxes.add(currentNode.item);
    }

    _finalizeTrees(newDefaultTree, newPersonalTree, newTeamMailboxTree);

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
    final nodeLookup = _buildNodeLookup(currentCollection);

    for (var mailbox in allMailboxes) {
      final currentMailboxNode = nodeLookup[mailbox.id];

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

    _finalizeTrees(newDefaultTree, newPersonalTree, newTeamMailboxTree);

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
    } else {
      final targetTree = _resolveTargetTree(mailbox, defaultTree, personalTree, teamMailboxTree);
      targetTree.root.addChildNode(currentNode);
    }
  }

  void _finalizeTrees(MailboxTree defaultTree, MailboxTree personalTree, MailboxTree teamMailboxTree) {
    sortNodeChildren(defaultTree.root);
    defaultTree.root.childrenItems?.forEach(_sortChildrenAlphabetically);
    _sortChildrenAlphabetically(personalTree.root);
    _applyTeamMailboxSorting(teamMailboxTree.root);
  }

  void _sortChildrenAlphabetically(MailboxNode node) {
    final children = node.childrenItems;
    if (children == null || children.isEmpty) return;
    sortByMailboxNameNodeChildren(node);
    for (final child in children) {
      _sortChildrenAlphabetically(child);
    }
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
    final roleValue = node.item.role?.value ?? '';
    if (roleValue.isNotEmpty) {
      return _systemFolderRoleIndex[roleValue] ?? _systemFolderRoleIndex.length;
    }
    // No role: mayDelete=false means the server does not allow deletion,
    // which identifies a system folder. Fall back to case-insensitive name
    // matching to determine its canonical sort position.
    if (node.item.myRights?.mayDelete == false) {
      final nameLower = node.item.name?.name.toLowerCase() ?? '';
      return _systemFolderRoleIndex[nameLower] ?? _systemFolderRoleIndex.length;
    }
    return _systemFolderRoleIndex.length;
  }

  void _sortWithSystemFoldersFirst(MailboxNode node) {
    final children = node.childrenItems;
    if (children == null || children.isEmpty) return;
    final indexCache = {for (final child in children) child: _systemFolderSortIndex(child)};
    children.sort((a, b) {
      final aIndex = indexCache[a]!;
      final bIndex = indexCache[b]!;
      final aIsSystem = aIndex < _systemFolderRoleIndex.length;
      final bIsSystem = bIndex < _systemFolderRoleIndex.length;
      if (aIsSystem && bIsSystem) return aIndex.compareTo(bIndex);
      if (aIsSystem) return -1;
      if (bIsSystem) return 1;
      return a.item.name?.compareAlphabetically(b.item.name) ?? -1;
    });
  }

  // Traversal strategy by depth:
  //   virtual root (isPersonal=true)  → alphabetical — orders team account roots
  //   team account root (isTeamMailboxes=true, depth=1) → system folders first, then alphabetical
  //   children/grandchildren (hasParentId=true) → alphabetical
  void _applyTeamMailboxSorting(MailboxNode node) {
    final children = node.childrenItems;
    if (children == null || children.isEmpty) return;
    if (node.item.isTeamMailboxes) {
      _sortWithSystemFoldersFirst(node);
    } else {
      sortByMailboxNameNodeChildren(node);
    }
    for (final child in children) {
      _applyTeamMailboxSorting(child);
    }
  }

  // Flattens all three trees into a single O(1) lookup map.
  // Avoids repeated O(n) DFS calls when resolving existing nodes for each mailbox.
  Map<MailboxId, MailboxNode> _buildNodeLookup(MailboxCollection collection) {
    final lookup = HashMap<MailboxId, MailboxNode>();
    final stack = <MailboxNode>[
      ...?collection.defaultTree.root.childrenItems,
      ...?collection.personalTree.root.childrenItems,
      ...?collection.teamMailboxTree.root.childrenItems,
    ];
    while (stack.isNotEmpty) {
      final node = stack.removeLast();
      lookup[node.item.id] = node;
      final children = node.childrenItems;
      if (children != null) stack.addAll(children);
    }
    return lookup;
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

  void _propagateDeactivationIfNeeded(MailboxNode parentNode, MailboxNode currentNode) {
    if (parentNode.nodeState != MailboxState.deactivated) return;
    currentNode.updateItem(currentNode.item.withMailboxSate(MailboxState.deactivated));
    currentNode.updateNodeState(MailboxState.deactivated);
  }
}