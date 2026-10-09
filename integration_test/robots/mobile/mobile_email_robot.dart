import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../abstract/abstract_email_pdf_preview_robot.dart';
import '../abstract/abstract_email_robot.dart';
import '../email_pdf_preview_robot.dart';
import '../email_robot.dart';
import '../../utils/test_timeouts.dart';

class MobileEmailRobot extends EmailRobot implements AbstractEmailRobot {
  MobileEmailRobot(super.$, {AbstractEmailPdfPreviewRobot? pdfPreview})
      : pdfPreview = pdfPreview ?? EmailPdfPreviewRobot($);

  @override
  final AbstractEmailPdfPreviewRobot pdfPreview;

  @override
  Future<void> expectDownloadSaveDialogVisible() async {
    await $.platformAutomator.mobile.waitUntilVisible(
      MobileSelector(
        android: AndroidSelector(text: 'SAVE'),
      ),
      timeout: TestTimeouts.medium,
    );
    await expectLater(
      $.platformAutomator.tap(
        Selector(text: 'SAVE'),
        timeout: TestTimeouts.medium,
      ),
      completes,
    );
  }
}
