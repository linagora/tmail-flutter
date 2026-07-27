import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/upload/domain/validator/attachment_upload_failure.dart';
import 'package:tmail_ui_user/features/upload/presentation/dialog/attachment_validation_failure_presenter.dart';
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

  group('AttachmentValidationFailurePresenter.present', () {
    testWidgets('should show the max-size dialog for MaxEmailAttachmentSizeExceeded', (tester) async {
      await tester.pumpWidget(WidgetFixtures.makeTestableWidget(child: const SizedBox.shrink()));
      await tester.pump();

      final context = tester.element(find.byType(SizedBox));
      final appLocalizations = AppLocalizations.of(context);

      AttachmentValidationFailurePresenter.present(
        context,
        const MaxEmailAttachmentSizeExceeded(1000000));
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
