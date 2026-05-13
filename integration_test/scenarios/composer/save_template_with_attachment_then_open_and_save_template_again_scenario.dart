import 'package:flutter/foundation.dart';

import '../../robots/abstract/abstract_composer_robot.dart';
import '../../utils/wait_for_condition.dart';
import 'base_save_template_then_reopen_scenario.dart';

class SaveTemplateWithAttachmentThenOpenAndSaveTemplateAgainScenario
    extends BaseSaveTemplateThenReopenScenario {
  const SaveTemplateWithAttachmentThenOpenAndSaveTemplateAgainScenario(super.$, super.robots);

  @override
  String get subject => 'Template with attachment - second save';

  @override
  Future<void> attachContent(AbstractComposerRobot composerRobot, Uint8List bytes) =>
      composerRobot.addAttachmentFromBytes(bytes, 'template-attachment.png');

  @override
  Future<void> waitForContentUploaded(AbstractComposerRobot composerRobot) =>
      waitForCondition(() {
        final controller = composerRobot.findComposerController();
        return controller?.uploadController.allAttachmentsUploaded.isNotEmpty ?? false;
      });
}
