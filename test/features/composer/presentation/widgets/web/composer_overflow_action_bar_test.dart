import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/composer_overflow_action_bar.dart';

void main() {
  group('ComposerOverflowActionBar.visibleCount', () {
    test('Should fit what the width allows after the reserved space', () {
      expect(
        ComposerOverflowActionBar.visibleCount(
          maxWidth: 256,
          actionCount: 5,
          slotWidth: 44,
          reservedWidth: 80,
        ),
        4,
      );
    });

    test('Should cap at the action count on wide screens', () {
      expect(
        ComposerOverflowActionBar.visibleCount(
          maxWidth: 1000,
          actionCount: 5,
          slotWidth: 44,
          reservedWidth: 80,
        ),
        5,
      );
    });

    test('Should return 0 when even the reserved space does not fit', () {
      expect(
        ComposerOverflowActionBar.visibleCount(
          maxWidth: 60,
          actionCount: 5,
          slotWidth: 44,
          reservedWidth: 80,
        ),
        0,
      );
    });

    test('Should keep a partial slot out of the bar', () {
      expect(
        ComposerOverflowActionBar.visibleCount(
          maxWidth: 80 + 44 + 43,
          actionCount: 5,
          slotWidth: 44,
          reservedWidth: 80,
        ),
        1,
      );
    });

    test('Should show every action when the width is unbounded', () {
      expect(
        ComposerOverflowActionBar.visibleCount(
          maxWidth: double.infinity,
          actionCount: 5,
          slotWidth: 44,
          reservedWidth: 80,
        ),
        5,
      );
    });
  });

  group('ComposerOverflowActionBar', () {
    testWidgets(
      'Should hand the trailing actions that do not fit to trailingBuilder',
      (tester) async {
        List<Widget>? overflow;

        await tester.pumpWidget(
          MaterialApp(
            home: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 80 + 44 * 2,
                child: ComposerOverflowActionBar(
                  slotWidth: 44,
                  reservedWidth: 80,
                  actions: [
                    for (var i = 0; i < 3; i++)
                      ComposerOverflowAction(
                        button: SizedBox(key: ValueKey('b$i'), width: 44),
                        menuItem: Text('m$i'),
                      ),
                  ],
                  trailingBuilder: (items) {
                    overflow = items;
                    return const SizedBox(key: ValueKey('trailing'), width: 80);
                  },
                ),
              ),
            ),
          ),
        );

        expect(find.byKey(const ValueKey('b0')), findsOneWidget);
        expect(find.byKey(const ValueKey('b1')), findsOneWidget);
        expect(find.byKey(const ValueKey('b2')), findsNothing);
        expect(find.byKey(const ValueKey('trailing')), findsOneWidget);
        expect(overflow, hasLength(1));
        expect((overflow!.single as Text).data, 'm2');
        expect(tester.takeException(), isNull);
      },
    );
  });
}
