import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/composer_overflow_action_bar.dart';

void main() {
  test('Should count only the slots that fit after the reserved space', () {
    const cases = <(double, int)>[
      (256, 4),
      (1000, 5),
      (60, 0),
      (80 + 44 + 43, 1),
      (double.infinity, 5),
    ];

    for (final (width, expected) in cases) {
      expect(
        ComposerOverflowActionBar.visibleCount(
          maxWidth: width,
          actionCount: 5,
          slotWidth: 44,
          reservedWidth: 80,
        ),
        expected,
        reason: 'width $width',
      );
    }
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
