import 'package:flutter/foundation.dart';

import '../../robots/abstract/abstract_composer_robot.dart';
import '../../utils/wait_for_condition.dart';
import 'base_save_template_then_reopen_scenario.dart';

class SaveTemplateWithInlineImageThenOpenAndSaveTemplateAgainScenario
    extends BaseSaveTemplateThenReopenScenario {
  const SaveTemplateWithInlineImageThenOpenAndSaveTemplateAgainScenario(super.$, super.robots);

  @override
  String get subject => 'Template with inline image - second save';

  @override
  Future<void> attachContent(AbstractComposerRobot composerRobot, Uint8List bytes) =>
      composerRobot.addInlineFromBytes(bytes, 'template-inline.png');

  @override
  Future<void> waitForContentUploaded(AbstractComposerRobot composerRobot) =>
      waitForCondition(() {
        final controller = composerRobot.findComposerController();
        return controller?.uploadController.inlineAttachmentsUploaded.isNotEmpty ?? false;
      });
}
