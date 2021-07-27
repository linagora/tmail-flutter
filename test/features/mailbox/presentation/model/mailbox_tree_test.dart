import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';

void main() {
  group('test findNode in mailbox tree', () {
    late MailboxTree? tree;
    final level1Node = PresentationMailbox(MailboxId(Id('1')));
    final level1Node1 = PresentationMailbox(MailboxId(Id('1_1')));
    final level1Node2 = PresentationMailbox(MailboxId(Id('1_2')));
    final level2Node1 = PresentationMailbox(MailboxId(Id('2_1')), parentId: MailboxId(Id('1')));
    final level3Node1 = PresentationMailbox(MailboxId(Id('3_1')), parentId: MailboxId(Id('2_1')));

    setUp(() {
      tree = MailboxTree(MailboxNode.root());
      tree!.insertNode(level1Node);
      tree!.insertNode(level1Node1);
      tree!.insertNode(level1Node2);
      tree!.insertNode(level2Node1);
      tree!.insertNode(level3Node1);
    });

    test('findNode should find a node in tree at level 1', () {
      final node1 = tree!.findNode(MailboxId(Id('1')));
      expect(node1!.item, equals(level1Node));
    });

    test('findNode should find a node in tree at level 2', () {
      final node1 = tree!.findNode(MailboxId(Id('1_2')));
      expect(node1!.item, equals(level1Node2));
    });

    test('findNode should find a leaf in tree', () {
      final node1 = tree!.findNode(MailboxId(Id('3_1')));
      expect(node1!.item, equals(level3Node1));
    });

    test('findNode should find a node which have children in tree', () {
      final node1 = tree!.findNode(MailboxId(Id('2_1')));
      expect(node1!.item, equals(level2Node1));
      expect(node1.childrenItems.length, equals(1));
      expect(node1.childrenItems[0].item, equals(level3Node1));
    });

    test('findNode should not find a node not in tree', () {
      expect(tree!.findNode(MailboxId(Id('4_1'))), null);
    });

    tearDown(() {
      tree = null;
    });
  });

  group('test insertNode in mailbox tree', () {

    test('insertNode should insert a node without parent at level 1', () {
      final tree = MailboxTree(MailboxNode.root());
      final mailbox = PresentationMailbox(MailboxId(Id("1")));
      final insertedNode = tree.insertNode(mailbox);

      expect(tree.root.childrenItems, contains(insertedNode));
    });

    test('insertNode should insert a node to correctly parent', () {
      final tree = MailboxTree(MailboxNode.root());
      final level1Node = PresentationMailbox(MailboxId(Id('1')));
      final level1Node1 = PresentationMailbox(MailboxId(Id('1_1')));
      final level1Node2 = PresentationMailbox(MailboxId(Id('1_2')));
      tree.insertNode(level1Node);
      tree.insertNode(level1Node1);
      tree.insertNode(level1Node2);

      final insertedNode = tree.insertNode(PresentationMailbox(MailboxId(Id('2_1_2')), parentId: MailboxId(Id('1_2'))));

      final foundLevel1Node2 = tree.findNode(MailboxId(Id('1_2')));
      expect(foundLevel1Node2?.childrenItems.length, equals(1));
      expect(foundLevel1Node2?.childrenItems, contains(insertedNode));
    });

    test('insertNode should insert a node to root if parent not found', () {
      final tree = MailboxTree(MailboxNode.root());
      final level1Node = PresentationMailbox(MailboxId(Id('1')));
      final level1Node1 = PresentationMailbox(MailboxId(Id('1_1')));
      final level1Node2 = PresentationMailbox(MailboxId(Id('1_2')));
      tree.insertNode(level1Node);
      tree.insertNode(level1Node1);
      tree.insertNode(level1Node2);

      final insertedNode = tree.insertNode(PresentationMailbox(MailboxId(Id('1_1_1_exp')), parentId: MailboxId(Id('e1_2'))));

      expect(tree.root.childrenItems.length, equals(4));
      expect(tree.root.childrenItems.map((childNode) => childNode.item).toList(),
        containsAll({level1Node, level1Node2, level1Node1, insertedNode!.item}));
    });
  });
}