
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/attachment_item_composer_widget.dart';

import '../../base/base_test_scenario.dart';
import '../../resources/test_images.dart';
import '../../robots/composer_robot.dart';
import '../../robots/thread_robot.dart';

class ComposerUploadAttachmentAndInlineImageScenario extends BaseTestScenario {
  const ComposerUploadAttachmentAndInlineImageScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const pngName = 'composer-png';
    final threadRobot = ThreadRobot($);
    final composerRobot = ComposerRobot($);

    await threadRobot.openComposer();
    await _expectComposerViewVisible();

    await composerRobot.grantContactPermission();

    final png = await preparingPngWithName(pngName);

    await composerRobot.addAttachment(png);
    await composerRobot.addInline(png);
    await $.pumpAndSettle();

    _expectAttachment(pngName);
    await _expectInline();

    await composerRobot.addAttachment(png);
    await composerRobot.addAttachment(png);
    await $.pumpAndSettle();

    _expectMultipleAttachments(3);
  }

  Future<void> _expectInline() async {
    final currentHtmlContent = await Get
      .find<ComposerController>()
      .getContentInEditor();
    expect(
      currentHtmlContent.contains(TestImages.base64),
      true,
    );
  }

  void _expectAttachment(String pngName) {
    return expect(
      $(AttachmentItemComposerWidget)
        .which<AttachmentItemComposerWidget>(
         (widget) => widget.fileName.contains(pngName)
        ),
      findsOneWidget,
    );
  }

  void _expectMultipleAttachments(int numberOfAttachments) {
    return expect(
      $(AttachmentItemComposerWidget),
      findsNWidgets(numberOfAttachments),
    );
  }
  
  Future<void> _expectComposerViewVisible() => expectViewVisible($(ComposerView));
}
