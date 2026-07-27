import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/upload/presentation/dialog/upload_size_warning_dialog_presenter.dart';

import '../../../../fixtures/widget_fixtures.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put<ImagePaths>(ImagePaths());
    Get.put<ResponsiveUtils>(ResponsiveUtils());
  });

  tearDown(() {
    Get.reset();
  });

  group('UploadSizeWarningDialogPresenter.showExceededWarningSize', () {
    testWidgets(
      'Should dismiss the dialog and invoke cancelAction exactly once\n'
      'When user taps the close button',
    (tester) async {
      await tester.pumpWidget(WidgetFixtures.makeTestableWidget(
        child: const SizedBox.shrink()));
      await tester.pump();

      var confirmCallCount = 0;
      var cancelCallCount = 0;

      UploadSizeWarningDialogPresenter.showExceededWarningSize(
        context: tester.element(find.byType(SizedBox)),
        confirmAction: () => confirmCallCount++,
        cancelAction: () => cancelCallCount++,
      );
      await tester.pump();

      final closeButton = find.byWidgetPredicate((widget) =>
        widget is TMailButtonWidget && widget.icon == ImagePaths().icCloseDialog);
      expect(closeButton, findsOneWidget);

      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      // Dialog must be fully gone, so a stray Confirm/Cancel tap can no
      // longer reach the caller's callback and invoke it twice.
      expect(find.byKey(const Key('confirm_dialog_action')), findsNothing);
      expect(closeButton, findsNothing);
      expect(cancelCallCount, equals(1));
      expect(confirmCallCount, equals(0));
    });
  });
}
