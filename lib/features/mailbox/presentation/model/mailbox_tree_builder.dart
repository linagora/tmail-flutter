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
    for (var mailbox in mailboxesList) {
      mailboxDictionary[mailbox.id] = MailboxNode(mailbox);
    }
    for (var mailbox in mailboxesList) {
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
    }
    return tree;
  }

  Future<Tuple2<MailboxTree, MailboxTree>> generateMailboxTreeInUI(List<PresentationMailbox> allMailboxes) async {
    final Map<MailboxId, MailboxNode> mailboxDictionary = HashMap();

    final defaultTree = MailboxTree(MailboxNode.root());
    final folderTree = MailboxTree(MailboxNode.root());

    for (var mailbox in allMailboxes) {
      mailboxDictionary[mailbox.id] = MailboxNode(mailbox);
    }

    for (var mailbox in allMailboxes) {
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
    }

    defaultTree.root.childrenItems?.sort((thisMailbox, thatMailbox) => thisMailbox.compareTo(thatMailbox));
    return Tuple2(defaultTree, folderTree);
  }

  Future<Tuple2<MailboxTree, MailboxTree>> generateMailboxTreeInUIAfterRefreshChanges(
      List<PresentationMailbox> allMailboxes,
      MailboxTree defaultTreeBeforeChanges,
      MailboxTree folderTreeBeforeChanges,
  ) async {
    final Map<MailboxId, MailboxNode> mailboxDictionary = HashMap();

    final newDefaultTree = MailboxTree(MailboxNode.root());
    final newFolderTree = MailboxTree(MailboxNode.root());

    for (var mailbox in allMailboxes) {
      final mailboxNodeBeforeChanges = defaultTreeBeforeChanges.findNode((node) => node.item.id == mailbox.id) ??
          folderTreeBeforeChanges.findNode((node) => node.item.id == mailbox.id);
      if (mailboxNodeBeforeChanges != null) {
        mailboxDictionary[mailbox.id] = MailboxNode(
            mailbox,
            expandMode: mailboxNodeBeforeChanges.expandMode,
            selectMode: mailboxNodeBeforeChanges.selectMode);
      } else {
        mailboxDictionary[mailbox.id] = MailboxNode(mailbox);
      }
    }

    for (var mailbox in allMailboxes) {
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
          var tree = mailbox.hasRole() ? newDefaultTree : newFolderTree;

          tree.root.addChildNode(node);
          tree.root.childrenItems?.sortByCompare<MailboxName?>(
            (node) => node.item.name,
            (name, other) => name?.compareAlphabetically(other) ?? -1
          );
        }
      }
    }

    newDefaultTree.root.childrenItems?.sort((thisMailbox, thatMailbox) => thisMailbox.compareTo(thatMailbox));
    return Tuple2(newDefaultTree, newFolderTree);
  }
}