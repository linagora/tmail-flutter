import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/email_action_type.dart';

void main() {
  group('EmailActionType.category grouped order', () {
    const trashGroup = [
      EmailActionType.moveToTrash,
      EmailActionType.deletePermanently,
      EmailActionType.archiveMessage,
    ];

    const otherActionsGroup = [
      EmailActionType.labelAs,
      EmailActionType.markAsRead,
      EmailActionType.markAsUnread,
      EmailActionType.markAsStarred,
      EmailActionType.unMarkAsStarred,
      EmailActionType.moveToMailbox,
      EmailActionType.moveToSpam,
    ];

    test('trash group shares a single category', () {
      final categories = trashGroup.map((type) => type.category).toSet();

      expect(categories.length, 1,
          reason: 'moveToTrash, deletePermanently and archiveMessage must '
              'stay in the same section');
    });

    test('other actions group shares a single category', () {
      final categories = otherActionsGroup.map((type) => type.category).toSet();

      expect(categories.length, 1,
          reason: 'labelAs, markAsRead/Unread, markAsStarred/unMarkAsStarred, '
              'moveToMailbox and moveToSpam must stay in the same section');
    });

    test('trash group is sorted before the other actions group', () {
      final trashCategory = trashGroup.first.category;
      final otherCategory = otherActionsGroup.first.category;

      expect(trashCategory, lessThan(otherCategory),
          reason: 'trash/archive section must render above the other '
              'selection actions in grouped menus');
    });
  });
}
