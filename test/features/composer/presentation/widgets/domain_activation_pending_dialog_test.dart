import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/domain_activation_pending_dialog.dart';

import '../../../../fixtures/widget_fixtures.dart';

const _title = 'Your email domain is pending activation';
const _message =
    'You cannot send emails at this time. '
    'Contact your administrator if the problem persists.';

void main() {
  group('DomainActivationPendingDialog', _dialogTests);
  group('showDomainActivationPendingDialog', _showDialogTests);
}

void _dialogTests() {
  testWidgets(
    'Should show the Figma title, message, Got it and a Close tooltip',
    (tester) async {
      await tester.pumpWidget(
        WidgetFixtures.makeTestableWidget(
          child: DomainActivationPendingDialog(onDismiss: () {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(_title), findsOneWidget);
      expect(find.text(_message), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(find.byKey(LinagoraDialog.closeButtonKey))
            .tooltip,
        'Close',
      );
      expect(find.byKey(LinagoraDialog.secondaryActionKey), findsNothing);
      expect(
        find.ancestor(
          of: find.byType(LinagoraDialog),
          matching: find.byType(PointerInterceptor),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('Should dismiss When Got it or the close button is tapped', (
    tester,
  ) async {
    var dismissed = 0;
    await tester.pumpWidget(
      WidgetFixtures.makeTestableWidget(
        child: DomainActivationPendingDialog(onDismiss: () => dismissed++),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(LinagoraDialog.primaryActionKey));
    await tester.tap(find.byKey(LinagoraDialog.closeButtonKey));

    expect(dismissed, 2);
  });
}

void _showDialogTests() {
  /// Opens the dialog and returns whether its future has completed.
  Future<bool Function()> open(WidgetTester tester) async {
    await tester.pumpWidget(
      WidgetFixtures.makeTestableWidget(child: const SizedBox.shrink()),
    );
    await tester.pump();
    var completed = false;
    showDomainActivationPendingDialog().then((_) => completed = true);
    await tester.pumpAndSettle();
    return () => completed;
  }

  testWidgets('Should open over the backdrop scrim', (tester) async {
    await open(tester);

    expect(find.byType(DomainActivationPendingDialog), findsOneWidget);
    final barrier = tester
        .widgetList<ModalBarrier>(find.byType(ModalBarrier))
        .last;
    expect(barrier.color, LinagoraDialogStyle.barrierColor);

    await tester.tap(find.byKey(LinagoraDialog.closeButtonKey));
    await tester.pumpAndSettle();
  });

  testWidgets('Should close and complete When Got it is tapped', (
    tester,
  ) async {
    final isCompleted = await open(tester);
    expect(isCompleted(), isFalse);

    await tester.tap(find.byKey(LinagoraDialog.primaryActionKey));
    await tester.pumpAndSettle();

    expect(find.byType(DomainActivationPendingDialog), findsNothing);
    expect(isCompleted(), isTrue);
    expect(Get.isDialogOpen, isFalse);
  });

  testWidgets('Should close When the close button is tapped', (tester) async {
    await open(tester);

    await tester.tap(find.byKey(LinagoraDialog.closeButtonKey));
    await tester.pumpAndSettle();

    expect(find.byType(DomainActivationPendingDialog), findsNothing);
  });
}
