import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/extensions/context_menu_action_list_extension.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_item_action.dart';

/// Fake subclass to test grouping
class FakeContextMenuAction extends ContextMenuItemAction<String> {
  FakeContextMenuAction(super.action, {super.key, super.category});

  @override
  String get actionName => action;
}

void main() {
  group('ContextMenuActionListExt.groupByCategory', () {
    test('should group actions by category correctly', () {
      // Arrange
      final actions = [
        FakeContextMenuAction('Cut', category: 0),
        FakeContextMenuAction('Copy', category: 0),
        FakeContextMenuAction('Paste', category: 1),
        FakeContextMenuAction('SelectAll', category: 2),
        FakeContextMenuAction('Other', category: -1),
      ];

      // Act
      final grouped = actions.groupByCategory();

      // Assert
      expect(grouped.length, 4);
      expect(grouped.keys, orderedEquals([0, 1, 2, -1])); // sorted, -1 last

      expect(grouped[0]!.map((a) => a.action).toList(), ['Cut', 'Copy']);
      expect(grouped[1]!.map((a) => a.action).toList(), ['Paste']);
      expect(grouped[2]!.map((a) => a.action).toList(), ['SelectAll']);
      expect(grouped[-1]!.map((a) => a.action).toList(), ['Other']);
    });

    test('should return empty map when list is empty', () {
      // Arrange
      final actions = <FakeContextMenuAction>[];

      // Act
      final grouped = actions.groupByCategory();

      // Assert
      expect(grouped, isEmpty);
    });

    test('should correctly sort integer keys ascending and move -1 to bottom',
        () {
      // Arrange
      final actions = [
        FakeContextMenuAction('ActionA', category: 3),
        FakeContextMenuAction('ActionB', category: 1),
        FakeContextMenuAction('ActionC', category: -1),
        FakeContextMenuAction('ActionD', category: 2),
      ];

      // Act
      final grouped = actions.groupByCategory();

      // Assert
      expect(grouped.keys.toList(), orderedEquals([1, 2, 3, -1]));
    });

    test('should handle multiple actions with same category', () {
      // Arrange
      final actions = [
        FakeContextMenuAction('Cut', category: 0),
        FakeContextMenuAction('Copy', category: 0),
        FakeContextMenuAction('Paste', category: 1),
      ];

      // Act
      final grouped = actions.groupByCategory();

      // Assert
      expect(grouped[0]!.length, 2);
      expect(grouped[1]!.length, 1);
    });

    test('should place all -1 category items at the end regardless of order',
        () {
      // Arrange
      final actions = [
        FakeContextMenuAction('Unknown1', category: -1),
        FakeContextMenuAction('Edit', category: 0),
        FakeContextMenuAction('Unknown2', category: -1),
      ];

      // Act
      final grouped = actions.groupByCategory();

      // Assert
      expect(grouped.keys.toList(), orderedEquals([0, -1]));
      expect(
          grouped[-1]!.map((a) => a.action).toList(), ['Unknown1', 'Unknown2']);
    });
  });
}
