import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';

extension ListMailboxNodeExtension on List<MailboxNode> {
  List<MailboxId> get mailboxIds => map((node) => node.item.id).toList();

  /// Insert [newNode] after Inbox if present, otherwise at the beginning.
  void insertAfterInbox(MailboxNode newNode) {
    insertAfterByPriority(
      newNode,
      [_isInbox],
    );
  }

  /// Insert [newNode] after Starred if present,
  /// otherwise after Inbox, otherwise at the beginning.
  void insertAfterStarredOrInbox(MailboxNode newNode) {
    insertAfterByPriority(
      newNode,
      [
        _isStarred,
        _isInbox,
      ],
    );
  }

  /// Insert [newNode] after the first mailbox matching [priorities].
  /// If no priorities match (or [priorities] is empty), inserts at the beginning.
  void insertAfterByPriority(
    MailboxNode newNode,
    List<bool Function(MailboxNode)> priorities,
  ) {
    if (_containsMailbox(newNode)) return;

    for (final predicate in priorities) {
      final index = indexWhere(predicate);
      if (index != -1) {
        insert(index + 1, newNode);
        return;
      }
    }

    insert(0, newNode);
  }

  bool _isInbox(MailboxNode node) {
    return node.item.role?.value == PresentationMailbox.inboxRole ||
        _equalsIgnoreCase(node.item.name?.name, 'inbox');
  }

  bool _isStarred(MailboxNode node) {
    return node.item.role?.value == PresentationMailbox.favoriteRole ||
        _equalsIgnoreCase(node.item.name?.name, 'starred');
  }

  bool _containsMailbox(MailboxNode node) {
    return any((e) => e.item.id == node.item.id);
  }

  bool _equalsIgnoreCase(String? value, String expected) {
    return value != null && value.toLowerCase() == expected.toLowerCase();
  }
}
