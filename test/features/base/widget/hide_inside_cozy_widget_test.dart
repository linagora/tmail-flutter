import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/widget/hide_inside_cozy_widget.dart';
import 'package:tmail_ui_user/main/providers/cozy/inside_cozy_provider.dart';

void main() {
  const childKey = Key('hidden_inside_cozy_child');

  Future<void> pumpWidget(
    WidgetTester tester,
    FutureOr<bool> Function(Ref ref) insideCozy,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [insideCozyProvider.overrideWith(insideCozy)],
        child: const MaterialApp(
          home: HideInsideCozyWidget(child: SizedBox(key: childKey)),
        ),
      ),
    );
    await tester.pump();
  }

  group('HideInsideCozyWidget', () {
    testWidgets('should show the child outside Cozy', (tester) async {
      await pumpWidget(tester, (ref) => false);

      expect(find.byKey(childKey), findsOneWidget);
    });

    testWidgets('should not show the child inside Cozy', (tester) async {
      await pumpWidget(tester, (ref) => true);

      expect(find.byKey(childKey), findsNothing);
    });

    testWidgets(
      'should not show the child until the Cozy check resolves',
      (tester) async {
        final insideCozy = Completer<bool>();
        await pumpWidget(tester, (ref) => insideCozy.future);

        expect(find.byKey(childKey), findsNothing);

        insideCozy.complete(false);
        await tester.pumpAndSettle();

        expect(find.byKey(childKey), findsOneWidget);
      },
    );
  });
}
