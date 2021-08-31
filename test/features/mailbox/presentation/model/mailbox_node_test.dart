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
      node.addChildNode(MailboxNode(childMailbox));

      expect(node.childrenItems?.length, equals(1));
    });

    test('addChildNode should add other new mailbox to a node', () async {
      final parentMailbox = PresentationMailbox(MailboxId(Id('1')));
      final node = MailboxNode(parentMailbox);
      final childMailbox = PresentationMailbox(MailboxId(Id('11')), parentId: MailboxId(Id('1')));
      node.addChildNode(MailboxNode(childMailbox));
      final childMailbox2 = PresentationMailbox(MailboxId(Id('12')), parentId: MailboxId(Id('1')));
      node.addChildNode(MailboxNode(childMailbox2));

      expect(node.childrenItems!.length, equals(2));
    });
  });
}