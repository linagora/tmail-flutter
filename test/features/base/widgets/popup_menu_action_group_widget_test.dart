import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/model/popup_menu_item_action.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_action_group_widget.dart';

/// Fake action for test
class FakePopupAction extends PopupMenuItemAction<String> {
  FakePopupAction(super.action, {super.key, super.category});

  @override
  String get actionName => action;
}

void main() {
  group('PopupMenuActionGroupWidget', () {
    testWidgets(
        'should group actions correctly by category and render divider between groups',
        (tester) async {
      // Arrange
      final actions = [
        FakePopupAction('Reply', category: 0),
        FakePopupAction('Forward', category: 0),
        FakePopupAction('Delete', category: 1),
        FakePopupAction('Move', category: 2),
        FakePopupAction('Archive', category: -1),
      ];

      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    child: const Text('Open Menu'),
                    onPressed: () {
                      PopupMenuActionGroupWidget(
                        actions: actions,
                        onActionSelected: (_) => tapped = true,
                      ).show(
                        context,
                        const RelativeRect.fromLTRB(50, 50, 0, 0),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Open Menu'));
      await tester.pumpAndSettle();

      // Assert 1: Ensure all actions are displayed
      expect(find.text('Reply'), findsOneWidget);
      expect(find.text('Forward'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Move'), findsOneWidget);
      expect(find.text('Archive'), findsOneWidget);

      // Assert 2: Check divider count (should be categoryCount - 1)
      final dividers = find.byType(PopupMenuDivider);
      expect(dividers, findsNWidgets(3)); // 4 groups → 3 dividers

      // Assert 3: Check display order (0 → 1 → 2 → -1)
      final allTexts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .toList();
      final order = allTexts
          .where(
            (t) => [
              'Reply',
              'Forward',
              'Delete',
              'Move',
              'Archive',
            ].contains(t),
          )
          .toList();
      expect(order, ['Reply', 'Forward', 'Delete', 'Move', 'Archive']);

      // Act: tap action and verify callback
      await tester.tap(find.text('Reply'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('should show no dividers when only one category exists',
        (tester) async {
      // Arrange
      final actions = [
        FakePopupAction('Mark Read', category: 0),
        FakePopupAction('Mark Unread', category: 0),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    child: const Text('Open Menu'),
                    onPressed: () {
                      PopupMenuActionGroupWidget(
                        actions: actions,
                        onActionSelected: (_) {},
                      ).show(
                        context,
                        const RelativeRect.fromLTRB(50, 50, 0, 0),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Open Menu'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Mark Read'), findsOneWidget);
      expect(find.text('Mark Unread'), findsOneWidget);
      expect(find.byType(PopupMenuDivider), findsNothing);
    });
  });
}
