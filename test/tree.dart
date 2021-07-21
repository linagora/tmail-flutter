import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';

void main() {
  group('test tree', () {
    final testCase1 = [
      PresentationMailbox(MailboxId(Id("1")), parentId: null),
      PresentationMailbox(MailboxId(Id("2")), parentId: null),
      PresentationMailbox(MailboxId(Id("3")), parentId: null),
      PresentationMailbox(MailboxId(Id("1.1")), parentId: MailboxId(Id('1'))),
      PresentationMailbox(MailboxId(Id("1.2")), parentId: MailboxId(Id('1'))),
      PresentationMailbox(MailboxId(Id("1.2.1")), parentId: MailboxId(Id('1.2'))),
      PresentationMailbox(MailboxId(Id("2.1")), parentId: MailboxId(Id('2'))),
      PresentationMailbox(MailboxId(Id("2.2")), parentId: MailboxId(Id('2'))),
      PresentationMailbox(MailboxId(Id("2.1.1")), parentId: MailboxId(Id('2.1'))),
      PresentationMailbox(MailboxId(Id("2.1.1.1")), parentId: MailboxId(Id('2.1.1'))),
      PresentationMailbox(MailboxId(Id("2.1.2")), parentId: MailboxId(Id('2.1'))),
      PresentationMailbox(MailboxId(Id("3.1")), parentId: MailboxId(Id('3'))),
      PresentationMailbox(MailboxId(Id("3.2")), parentId: MailboxId(Id('3'))),
      PresentationMailbox(MailboxId(Id("3.1.1")), parentId: MailboxId(Id('3.1'))),
      PresentationMailbox(MailboxId(Id("3.2.1")), parentId: MailboxId(Id('3.2'))),
    ];

    final testCase2 = [
      PresentationMailbox(MailboxId(Id("2")), parentId: null),
      PresentationMailbox(MailboxId(Id("3")), parentId: null),
      PresentationMailbox(MailboxId(Id("1.1")), parentId: MailboxId(Id('1'))),
      PresentationMailbox(MailboxId(Id("1.2")), parentId: MailboxId(Id('1'))),
      PresentationMailbox(MailboxId(Id("1.2.1")), parentId: MailboxId(Id('1.2'))),
      PresentationMailbox(MailboxId(Id("2.1")), parentId: MailboxId(Id('2'))),
      PresentationMailbox(MailboxId(Id("2.2")), parentId: MailboxId(Id('2'))),
      PresentationMailbox(MailboxId(Id("2.1.1")), parentId: MailboxId(Id('2.1'))),
      PresentationMailbox(MailboxId(Id("2.1.1.1")), parentId: MailboxId(Id('2.1.1'))),
      PresentationMailbox(MailboxId(Id("2.1.2")), parentId: MailboxId(Id('2.1'))),
      PresentationMailbox(MailboxId(Id("1")), parentId: null),
      PresentationMailbox(MailboxId(Id("3.1")), parentId: MailboxId(Id('3'))),
      PresentationMailbox(MailboxId(Id("3.2")), parentId: MailboxId(Id('3'))),
      PresentationMailbox(MailboxId(Id("3.1.1")), parentId: MailboxId(Id('3.1'))),
      PresentationMailbox(MailboxId(Id("3.2.1")), parentId: MailboxId(Id('3.2'))),
    ];

    final testCase3 = [
      PresentationMailbox(MailboxId(Id("1")), parentId: null),
      PresentationMailbox(MailboxId(Id("2")), parentId: null),
      PresentationMailbox(MailboxId(Id("3")), parentId: null),
      PresentationMailbox(MailboxId(Id("1.2")), parentId: MailboxId(Id('1'))),
      PresentationMailbox(MailboxId(Id("1.2.1")), parentId: MailboxId(Id('1.2'))),
      PresentationMailbox(MailboxId(Id("2.1")), parentId: MailboxId(Id('2'))),
      PresentationMailbox(MailboxId(Id("2.2")), parentId: MailboxId(Id('2'))),
      PresentationMailbox(MailboxId(Id("2.1.1")), parentId: MailboxId(Id('2.1'))),
      PresentationMailbox(MailboxId(Id("2.1.1.1")), parentId: MailboxId(Id('2.1.1'))),
      PresentationMailbox(MailboxId(Id("2.1.2")), parentId: MailboxId(Id('2.1'))),
      PresentationMailbox(MailboxId(Id("1.1")), parentId: MailboxId(Id('1'))),
      PresentationMailbox(MailboxId(Id("3.1")), parentId: MailboxId(Id('3'))),
      PresentationMailbox(MailboxId(Id("3.2")), parentId: MailboxId(Id('3'))),
      PresentationMailbox(MailboxId(Id("3.1.1")), parentId: MailboxId(Id('3.1'))),
      PresentationMailbox(MailboxId(Id("3.2.1")), parentId: MailboxId(Id('3.2'))),
    ];

    test('create a tree', () async {
      final tree1 = await TreeBuilder().generateMailboxTree(testCase1);
      print('$tree1');
    });

    test('test case 2', () async {
      final tree2 = await TreeBuilder().generateMailboxTree(testCase2);
      print('$tree2');
    });

    test('test case 3', () async {
      final tree3 = await TreeBuilder().generateMailboxTree(testCase3);
      print('$tree3');
    });

  });
}


