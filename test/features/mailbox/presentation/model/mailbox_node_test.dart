import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';

void main() {
  group('mailbox node test', () {

    test('addChild should add mailbox to a node', () async {
      final parentMailbox = PresentationMailbox(MailboxId(Id('1')));
      final node = MailboxNode(parentMailbox);
      final childMailbox = PresentationMailbox(MailboxId(Id('11')), parentId: MailboxId(Id('1')));
      final childNode = node.addChild(childMailbox);

      expect(node.childrenItems.length, equals(1));
      expect(node.childrenItems[0], equals(childNode));
    });

    test('addChild should add new mailbox to a node', () async {
      final parentMailbox = PresentationMailbox(MailboxId(Id('1')));
      final node = MailboxNode(parentMailbox);
      final childMailbox = PresentationMailbox(MailboxId(Id('11')), parentId: MailboxId(Id('1')));
      final childNode = node.addChild(childMailbox);
      final childMailbox2 = PresentationMailbox(MailboxId(Id('12')), parentId: MailboxId(Id('1')));
      final childNode2 = node.addChild(childMailbox2);

      expect(node.childrenItems.length, equals(2));
      expect(node.childrenItems, containsAll({childNode, childNode2}));
    });

    test('addChild add new mailbox without parentId to a node should return null', () async {
      final parentMailbox = PresentationMailbox(MailboxId(Id('1')));
      final node = MailboxNode(parentMailbox);
      final orphanMailbox = PresentationMailbox(MailboxId(Id('22')));

      expect(node.addChild(orphanMailbox), null);
    });

    test('addChild add new mailbox with other parentId to a node should return null', () async {
      final parentMailbox = PresentationMailbox(MailboxId(Id('1')));
      final node = MailboxNode(parentMailbox);
      final orphanMailbox = PresentationMailbox(MailboxId(Id('21')), parentId: MailboxId(Id('2')));

      expect(node.addChild(orphanMailbox), null);
    });
  });
}