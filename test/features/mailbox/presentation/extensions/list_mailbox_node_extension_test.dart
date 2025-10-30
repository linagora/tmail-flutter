import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/list_mailbox_node_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';

void main() {
  group('ListMailboxNodeExtension::insertAfterInbox', () {
    late List<MailboxNode> nodes;

    MailboxNode buildNode(String id, {String? name, String? role}) {
      final mailbox = PresentationMailbox(
        MailboxId(Id(id)),
        name: name != null ? MailboxName(name) : null,
        role: role != null ? Role(role) : null,
      );
      return MailboxNode(mailbox);
    }

    setUp(() {
      nodes = [
        buildNode('1', name: 'Sent'),
        buildNode('2', name: 'Inbox', role: 'inbox'),
        buildNode('3', name: 'Trash'),
      ];
    });

    test('should insert new node right after Inbox (by role)', () {
      final newNode = buildNode('4', name: 'Draft');
      nodes.insertAfterInbox(newNode);

      final ids = nodes.mailboxIds.map((id) => id.id.value).toList();
      expect(ids, ['1', '2', '4', '3']);
    });

    test('should insert new node right after Inbox (by name when role missing)',
        () {
      nodes = [
        buildNode('1', name: 'Sent'),
        buildNode('2', name: 'inbox'), // no role
        buildNode('3', name: 'Trash'),
      ];

      final newNode = buildNode('4', name: 'Archive');
      nodes.insertAfterInbox(newNode);

      final ids = nodes.mailboxIds.map((id) => id.id.value).toList();
      expect(ids, ['1', '2', '4', '3']);
    });

    test('should insert new node at the beginning when no Inbox found', () {
      nodes = [
        buildNode('1', name: 'Sent'),
        buildNode('2', name: 'Archive'),
      ];

      final newNode = buildNode('3', name: 'Draft');
      nodes.insertAfterInbox(newNode);

      final ids = nodes.mailboxIds.map((id) => id.id.value).toList();
      expect(ids, ['3', '1', '2']);
    });

    test('should not insert if node with same id already exists', () {
      final newNode =
          buildNode('2', name: 'Inbox', role: 'inbox'); // same id as existing
      nodes.insertAfterInbox(newNode);

      // The list should remain unchanged
      final ids = nodes.mailboxIds.map((id) => id.id.value).toList();
      expect(ids, ['1', '2', '3']);
    });

    test('should handle case-insensitive inbox name', () {
      nodes = [
        buildNode('1', name: 'Sent'),
        buildNode('2', name: 'INBOX'),
      ];

      final newNode = buildNode('3', name: 'Draft');
      nodes.insertAfterInbox(newNode);

      final ids = nodes.mailboxIds.map((id) => id.id.value).toList();
      expect(ids, ['1', '2', '3']);
    });

    test('should insert into empty list as the first element', () {
      nodes = [];
      final newNode = buildNode('1', name: 'Inbox', role: 'inbox');
      nodes.insertAfterInbox(newNode);

      final ids = nodes.mailboxIds.map((id) => id.id.value).toList();
      expect(ids, ['1']);
    });
  });
}
