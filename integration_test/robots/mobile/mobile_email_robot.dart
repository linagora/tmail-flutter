import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/email_action_type.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';

import '../../utils/test_timeouts.dart';
import '../abstract/abstract_email_pdf_preview_robot.dart';
import '../abstract/abstract_email_robot.dart';
import '../email_pdf_preview_robot.dart';
import '../email_robot.dart';

class MobileEmailRobot extends EmailRobot implements AbstractEmailRobot {
  MobileEmailRobot(
    super.$, {
    super.assertionRobot,
    super.labelRobot,
    AbstractEmailPdfPreviewRobot? pdfPreview,
  }) : pdfPreview = pdfPreview ?? EmailPdfPreviewRobot($);

  @override
  final AbstractEmailPdfPreviewRobot pdfPreview;

  @override
  Future<void> editAsNewEmail() async {
    await $(const ValueKey(UiKeys.emailDetailedMoreButton)).tap();
    await $(ValueKey('${EmailActionType.editAsNewEmail.name}_action')).tap();
  }

  @override
  Future<void> expectDownloadSaveDialogVisible() async {
    await $.platformAutomator.mobile.waitUntilVisible(
      MobileSelector(android: AndroidSelector(text: 'SAVE')),
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
