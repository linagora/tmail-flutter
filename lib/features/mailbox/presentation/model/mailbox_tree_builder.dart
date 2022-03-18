import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

import 'mailbox_node.dart';
import 'mailbox_tree.dart';

class TreeBuilder {
  Future<MailboxTree> generateMailboxTree(List<PresentationMailbox> mailboxesList) async {
    final Map<MailboxId, MailboxNode> mailboxDictionary = HashMap();

    final tree = MailboxTree(MailboxNode.root());
    mailboxesList.forEach((mailbox) {
      mailboxDictionary[mailbox.id] = MailboxNode(mailbox);
    });
    mailboxesList.forEach((mailbox) {
      final parentId = mailbox.parentId;
      final parentNode = mailboxDictionary[parentId];
      final node = mailboxDictionary[mailbox.id];
      if (node != null) {
        if (parentNode != null) {
          parentNode.addChildNode(node);
          parentNode.childrenItems?.sortByCompare<MailboxName?>(
            (node) => node.item.name,
            (name, other) => name?.compareAlphabetically(other) ?? -1
          );
        } else {
          tree.root.addChildNode(node);
          tree.root.childrenItems?.sortByCompare<MailboxName?>(
            (node) => node.item.name,
            (name, other) => name?.compareAlphabetically(other) ?? -1
          );
        }
      }
    });
    return tree;
  }

  Future<Tuple2<MailboxTree, MailboxTree>> generateMailboxTreeInUI(List<PresentationMailbox> allMailboxes) async {
    final Map<MailboxId, MailboxNode> mailboxDictionary = HashMap();

    final defaultTree = MailboxTree(MailboxNode.root());
    final folderTree = MailboxTree(MailboxNode.root());

    allMailboxes.forEach((mailbox) {
      mailboxDictionary[mailbox.id] = MailboxNode(mailbox);
    });

    allMailboxes.forEach((mailbox) {
      final parentId = mailbox.parentId;
      final parentNode = mailboxDictionary[parentId];
      final node = mailboxDictionary[mailbox.id];
      if (node != null) {
        if (parentNode != null) {
          parentNode.addChildNode(node);
          parentNode.childrenItems?.sortByCompare<MailboxName?>(
            (node) => node.item.name,
            (name, other) => name?.compareAlphabetically(other) ?? -1
          );
        } else {
          var tree = mailbox.hasRole() ? defaultTree : folderTree;

          tree.root.addChildNode(node);
          tree.root.childrenItems?.sortByCompare<MailboxName?>(
            (node) => node.item.name,
            (name, other) => name?.compareAlphabetically(other) ?? -1
          );
        }
      }
    });

    defaultTree.root.childrenItems?.sort((thisMailbox, thatMailbox) => thisMailbox.compareTo(thatMailbox));
    return Tuple2(defaultTree, folderTree);
  }
}