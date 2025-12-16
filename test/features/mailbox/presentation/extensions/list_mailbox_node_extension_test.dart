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

  group('ListMailboxNodeExtension::insertAfterStarredOrInbox', () {
    late List<MailboxNode> nodes;

    MailboxNode buildNode(String id, {String? name, String? role}) {
      final mailbox = PresentationMailbox(
        MailboxId(Id(id)),
        name: name != null ? MailboxName(name) : null,
        role: role != null ? Role(role) : null,
      );
      return MailboxNode(mailbox);
    }

    test('should insert after Starred when Starred exists (by role)', () {
      nodes = [
        buildNode('1', name: 'Inbox', role: 'inbox'),
        buildNode('2', name: 'Starred', role: 'favorite'),
        buildNode('3', name: 'Trash'),
      ];

      final newNode = buildNode('4', name: 'Draft');
      nodes.insertAfterStarredOrInbox(newNode);

      final ids = nodes.mailboxIds.map((id) => id.id.value).toList();
      expect(ids, ['1', '2', '4', '3']);
    });

    test(
        'should insert after Starred when role missing but name matches (case-insensitive)',
            () {
          nodes = [
            buildNode('1', name: 'Inbox'),
            buildNode('2', name: 'STARRED'), // no role
            buildNode('3', name: 'Trash'),
          ];

          final newNode = buildNode('4', name: 'Draft');
          nodes.insertAfterStarredOrInbox(newNode);

          final ids = nodes.mailboxIds.map((id) => id.id.value).toList();
          expect(ids, ['1', '2', '4', '3']);
        });

    test('should insert after Inbox when Starred not found', () {
      nodes = [
        buildNode('1', name: 'Sent'),
        buildNode('2', name: 'Inbox', role: 'inbox'),
        buildNode('3', name: 'Trash'),
      ];

      final newNode = buildNode('4', name: 'Archive');
      nodes.insertAfterStarredOrInbox(newNode);

      final ids = nodes.mailboxIds.map((id) => id.id.value).toList();
      expect(ids, ['1', '2', '4', '3']);
    });

    test('should insert at beginning when neither Starred nor Inbox found', () {
      nodes = [
        buildNode('1', name: 'Sent'),
        buildNode('2', name: 'Trash'),
      ];

      final newNode = buildNode('3', name: 'Draft');
      nodes.insertAfterStarredOrInbox(newNode);

      final ids = nodes.mailboxIds.map((id) => id.id.value).toList();
      expect(ids, ['3', '1', '2']);
    });

    test('should not insert if node with same id already exists', () {
      nodes = [
        buildNode('1', name: 'Inbox', role: 'inbox'),
        buildNode('2', name: 'Starred', role: 'favorite'),
      ];

      final newNode =
      buildNode('2', name: 'Starred', role: 'favorite'); // duplicate id
      nodes.insertAfterStarredOrInbox(newNode);

      final ids = nodes.mailboxIds.map((id) => id.id.value).toList();
      expect(ids, ['1', '2']);
    });
  });

  group('ListMailboxNodeExtension::insertAfterByPriority', () {
    late List<MailboxNode> nodes;

    MailboxNode buildNode(String id, {String? name, String? role}) {
      final mailbox = PresentationMailbox(
        MailboxId(Id(id)),
        name: name != null ? MailboxName(name) : null,
        role: role != null ? Role(role) : null,
      );
      return MailboxNode(mailbox);
    }

    bool isInbox(MailboxNode node) =>
        node.item.role?.value == PresentationMailbox.inboxRole ||
            node.item.name?.name.toLowerCase() == 'inbox';

    bool isStarred(MailboxNode node) =>
        node.item.role?.value == PresentationMailbox.favoriteRole ||
            node.item.name?.name.toLowerCase() == 'starred';

    bool isSent(MailboxNode node) =>
        node.item.role?.value == PresentationMailbox.sentRole ||
            node.item.name?.name.toLowerCase() == 'sent';

    test('should insert after first matched priority', () {
      nodes = [
        buildNode('1', name: 'Inbox', role: 'inbox'),
        buildNode('2', name: 'Starred', role: 'favorite'),
        buildNode('3', name: 'Sent', role: 'sent'),
      ];

      final newNode = buildNode('4', name: 'Draft');

      nodes.insertAfterByPriority(
        newNode,
        [isStarred, isInbox, isSent],
      );

      final ids = nodes.mailboxIds.map((id) => id.id.value).toList();
      expect(ids, ['1', '2', '4', '3']);
    });

    test('should fallback to second priority when first not found', () {
      nodes = [
        buildNode('1', name: 'Inbox', role: 'inbox'),
        buildNode('2', name: 'Trash'),
      ];

      final newNode = buildNode('3', name: 'Draft');

      nodes.insertAfterByPriority(
        newNode,
        [isStarred, isInbox],
      );

      final ids = nodes.mailboxIds.map((id) => id.id.value).toList();
      expect(ids, ['1', '3', '2']);
    });

    test('should insert at beginning when no priority matched', () {
      nodes = [
        buildNode('1', name: 'Trash'),
        buildNode('2', name: 'Archive'),
      ];

      final newNode = buildNode('3', name: 'Draft');

      nodes.insertAfterByPriority(
        newNode,
        [isStarred, isInbox, isSent],
      );

      final ids = nodes.mailboxIds.map((id) => id.id.value).toList();
      expect(ids, ['3', '1', '2']);
    });

    test('should not insert when node with same id already exists', () {
      nodes = [
        buildNode('1', name: 'Inbox', role: 'inbox'),
        buildNode('2', name: 'Sent', role: 'sent'),
      ];

      final newNode = buildNode('2', name: 'Sent', role: 'sent');

      nodes.insertAfterByPriority(
        newNode,
        [isInbox, isSent],
      );

      final ids = nodes.mailboxIds.map((id) => id.id.value).toList();
      expect(ids, ['1', '2']);
    });

    test('should insert into empty list as first element', () {
      nodes = [];

      final newNode = buildNode('1', name: 'Inbox', role: 'inbox');

      nodes.insertAfterByPriority(
        newNode,
        [isInbox],
      );

      final ids = nodes.mailboxIds.map((id) => id.id.value).toList();
      expect(ids, ['1']);
    });
  });
}
