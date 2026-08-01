import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/upload/presentation/dialog/max_size_attachments_dialog_presenter.dart';
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

  group('MaxSizeAttachmentsDialogPresenter.show', () {
    testWidgets(
      'Should display a confirm dialog\n'
      'When called with a max size value',
    (tester) async {
      await tester.pumpWidget(WidgetFixtures.makeTestableWidget(
        child: const SizedBox.shrink()));
      await tester.pump();

      final context = tester.element(find.byType(SizedBox));
      final appLocalizations = AppLocalizations.of(context);

      MaxSizeAttachmentsDialogPresenter.show(
        context: context,
        maxSizeAttachmentsPerEmail: 1000000);
      await tester.pump();

      expect(find.byKey(const Key('confirm_dialog_action')), findsOneWidget);
      expect(find.text(appLocalizations.maximum_files_size), findsOneWidget);
      expect(
        find.text(appLocalizations
            .message_dialog_upload_attachments_exceeds_maximum_size(
                filesize(1000000, 0))),
        findsOneWidget);
    });
  });
}
