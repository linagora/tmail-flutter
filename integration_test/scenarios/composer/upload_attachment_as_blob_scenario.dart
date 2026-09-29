import 'dart:convert';

import '../../base/base_test_scenario.dart';
import '../../resources/test_images.dart';

/// Blob path only: the upload body must reach XHR as the picked Blob, never Dart bytes.
class UploadAttachmentAsBlobScenario extends BaseTestScenario {
  const UploadAttachmentAsBlobScenario(super.$, super.robots);

  static const _fileName = 'blob-attachment.png';

  @override
  Future<void> runTestLogic() async {
    final threadRobot = robots.threadRobot();
    final composerRobot = robots.composerRobot();
    final bytes = base64Decode(TestImages.base64);

    await robots.commonRobot().waitForMailboxReady();
    await threadRobot.openComposer();
    await composerRobot.expectComposerViewVisible();
    await composerRobot.grantContactPermission();

    await composerRobot.addAttachmentFromBlob(bytes, _fileName, 'image/png');
    await composerRobot.waitForAttachmentsUploaded();
    await composerRobot.expectSingleUploadedAttachment(
      fileName: _fileName,
      size: bytes.length,
    );
    await composerRobot.expectUploadSentAsBlob(bytes.length);
  }
}
