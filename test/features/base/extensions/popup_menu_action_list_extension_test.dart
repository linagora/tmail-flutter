import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/extensions/popup_menu_action_list_extension.dart';
import 'package:tmail_ui_user/features/base/model/popup_menu_item_action.dart';

/// A simple fake implementation of PopupMenuItemAction
class FakePopupAction extends PopupMenuItemAction<String> {
  FakePopupAction(super.action, {super.key, super.category});

  @override
  String get actionName => action;
}

void main() {
  group('PopupMenuActionListExtension.groupByCategory', () {
    test('should group actions by category correctly', () {
      // Arrange
      final actions = [
        FakePopupAction('A1', category: 1),
        FakePopupAction('A2', category: 1),
        FakePopupAction('B1', category: 2),
        FakePopupAction('C1', category: 3),
        FakePopupAction('NoCategory', category: -1),
      ];

      // Act
      final grouped = actions.groupByCategory();

      // Assert
      expect(grouped.length, 4);
      expect(grouped.keys, orderedEquals([1, 2, 3, -1])); // sorted with -1 last

      expect(grouped[1]!.map((e) => e.action), ['A1', 'A2']);
      expect(grouped[2]!.map((e) => e.action), ['B1']);
      expect(grouped[3]!.map((e) => e.action), ['C1']);
      expect(grouped[-1]!.map((e) => e.action), ['NoCategory']);
    });

    test('should return empty map when list is empty', () {
      // Arrange
      final actions = <FakePopupAction>[];

      // Act
      final grouped = actions.groupByCategory();

      // Assert
      expect(grouped, isEmpty);
    });

    test('should correctly sort integer keys ascending and move -1 to bottom',
        () {
      // Arrange
      final actions = [
        FakePopupAction('A', category: 5),
        FakePopupAction('B', category: 2),
        FakePopupAction('C', category: -1),
        FakePopupAction('D', category: 3),
      ];

      // Act
      final grouped = actions.groupByCategory();

      // Assert
      expect(grouped.keys.toList(), orderedEquals([2, 3, 5, -1]));
    });

    test('should handle multiple actions with same category', () {
      // Arrange
      final actions = [
        FakePopupAction('A1', category: 0),
        FakePopupAction('A2', category: 0),
        FakePopupAction('B1', category: 1),
      ];

      // Act
      final grouped = actions.groupByCategory();

      // Assert
      expect(grouped[0]!.length, 2);
      expect(grouped[1]!.length, 1);
    });

    test('should place all -1 category items at the end regardless of position',
        () {
      // Arrange
      final actions = [
        FakePopupAction('No1', category: -1),
        FakePopupAction('Cat1', category: 0),
        FakePopupAction('No2', category: -1),
      ];

      // Act
      final grouped = actions.groupByCategory();

      // Assert
      expect(grouped.keys.toList(), orderedEquals([0, -1]));
      expect(grouped[-1]!.map((e) => e.action).toList(), ['No1', 'No2']);
    });
  });
}
