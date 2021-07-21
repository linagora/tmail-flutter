import 'dart:collection';

import 'package:built_collection/built_collection.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

import 'mailbox_node.dart';
import 'mailbox_tree.dart';

class TreeBuilder {
  Future<MailboxTree> generateMailboxTree(List<PresentationMailbox> mailboxesList) async {
    final Map<MailboxId, BuiltList<PresentationMailbox>> mapNotFoundParentMailbox = HashMap();

    final tree = MailboxTree(MailboxNode.root());
    mailboxesList.forEach((mailbox) {
      if (mailbox.hasParentId()) {
        final parentId = mailbox.parentId!;
        final foundParent = tree.findNode(parentId);
        if (foundParent != null) {
          _addDescendant(tree, mailbox, maybeDescendant: mapNotFoundParentMailbox);
        } else {
          final siblingTrees = mapNotFoundParentMailbox[mailbox.parentId];
          if (siblingTrees != null) {
            mapNotFoundParentMailbox.addAll({
              parentId: (ListBuilder<PresentationMailbox>(siblingTrees)..add(mailbox)).build()
            });
          } else {
            mapNotFoundParentMailbox.addAll({parentId: (ListBuilder<PresentationMailbox>()..add(mailbox)).build()});
          }
        }
      } else {
        _addDescendant(tree, mailbox, maybeDescendant: mapNotFoundParentMailbox);
      }
    });
    return tree;
  }

  MailboxNode? _addDescendant(
      MailboxTree tree,
      PresentationMailbox mailboxChild,
      {Map<MailboxId, BuiltList<PresentationMailbox>>? maybeDescendant}
      ) {
    final queue = ListQueue<PresentationMailbox>();
    queue.addLast(mailboxChild);
    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      tree.insertNode(current);
      maybeDescendant?.remove(current.id)?.forEach((child) {
        queue.addLast(child);
      });
    }
  }
}