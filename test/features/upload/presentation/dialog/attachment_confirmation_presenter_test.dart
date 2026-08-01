import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_prompt.dart';
import 'package:tmail_ui_user/features/upload/presentation/dialog/attachment_confirmation_presenter.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

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

  group('AttachmentConfirmationPresenter.ask', () {
    testWidgets('should resolve true when the user confirms', (tester) async {
      await tester.pumpWidget(WidgetFixtures.makeTestableWidget(child: const SizedBox.shrink()));
      await tester.pump();

      final context = tester.element(find.byType(SizedBox));
      final appLocalizations = AppLocalizations.of(context);

      final future = AttachmentConfirmationPresenter.ask(
        context,
        const LargeRegularAttachmentWarning());
      await tester.pump();

      expect(
        find.text(appLocalizations.warningMessageWhenExceedGenerallySizeInComposer),
        findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(await future, isTrue);
    });

    testWidgets('should resolve false exactly once when the user taps the close button', (tester) async {
      await tester.pumpWidget(WidgetFixtures.makeTestableWidget(child: const SizedBox.shrink()));
      await tester.pump();

      final context = tester.element(find.byType(SizedBox));
      final appLocalizations = AppLocalizations.of(context);

      final future = AttachmentConfirmationPresenter.ask(
        context,
        const LargeRegularAttachmentWarning());
      await tester.pump();

      expect(
        find.text(appLocalizations.warningMessageWhenExceedGenerallySizeInComposer),
        findsOneWidget);

      final closeButton = find.byWidgetPredicate((widget) =>
        widget is TMailButtonWidget && widget.icon == ImagePaths().icCloseDialog);
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      // Regression: the dialog's barrier must be non-dismissible and the close
      // button must pop the route, or this future would never resolve.
      expect(await future, isFalse);
    });

    testWidgets('should resolve false when the dialog route is popped programmatically', (tester) async {
      await tester.pumpWidget(WidgetFixtures.makeTestableWidget(child: const SizedBox.shrink()));
      await tester.pump();

      final context = tester.element(find.byType(SizedBox));
      final appLocalizations = AppLocalizations.of(context);

      final future = AttachmentConfirmationPresenter.ask(
        context,
        const LargeRegularAttachmentWarning());
      await tester.pump();

      expect(
        find.text(appLocalizations.warningMessageWhenExceedGenerallySizeInComposer),
        findsOneWidget);

      // Regression: a Navigator pop that bypasses confirm/cancel/close (e.g. a
      // back gesture) must still resolve the future, since it relies on
      // Get.dialog's own future rather than a manually-completed Completer.
      Navigator.of(context, rootNavigator: true).pop();
      await tester.pumpAndSettle();

      expect(await future, isFalse);
    });
  });
}
