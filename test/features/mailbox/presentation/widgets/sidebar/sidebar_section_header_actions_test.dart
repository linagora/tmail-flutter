import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/sidebar_section_header_action_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sidebar/sidebar_section_header_actions.dart';

void main() {
  group('SidebarSectionHeaderActions', () {
    testWidgets('keeps the design gap between two actions', (tester) async {
      await _pump(tester, const [
        SizedBox.square(key: Key('first'), dimension: 16),
        SizedBox.square(key: Key('second'), dimension: 16),
      ]);

      final first = tester.getRect(find.byKey(const Key('first')));
      final second = tester.getRect(find.byKey(const Key('second')));

      expect(
        second.left - first.right,
        SidebarSectionHeaderActionStyles.actionSpacing,
      );
    });

    testWidgets('adds no gap around a single action', (tester) async {
      await _pump(tester, const [
        SizedBox.square(key: Key('only'), dimension: 16),
      ]);

      expect(tester.getRect(_rowFinder).width, 16);
    });

    testWidgets('lays out nothing for an empty action list', (tester) async {
      await _pump(tester, const []);

      expect(tester.getRect(_rowFinder).width, 0);
    });

    testWidgets('falls back to the header gap on a pointer platform',
        (tester) async {
      final previousTargetPlatform = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      try {
        await _pump(tester, const [
          SizedBox.square(key: Key('first'), dimension: 16),
          SizedBox.square(key: Key('second'), dimension: 16),
        ]);

        final first = tester.getRect(find.byKey(const Key('first')));
        final second = tester.getRect(find.byKey(const Key('second')));

        expect(
          second.left - first.right,
          LinagoraSidebarSectionHeader.actionSpacing,
        );
      } finally {
        debugDefaultTargetPlatformOverride = previousTargetPlatform;
      }
    });
  });
}

final _rowFinder = find.descendant(
  of: find.byType(SidebarSectionHeaderActions),
  matching: find.byType(Row),
);

Future<void> _pump(WidgetTester tester, List<Widget> actions) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SidebarSectionHeaderActions(actions: actions),
      ),
    ),
  ));
}
