import 'package:flutter/foundation.dart';

import '../../robots/abstract/abstract_composer_robot.dart';
import '../../utils/wait_for_condition.dart';
import 'base_save_and_reopen_scenario.dart';

mixin WithAttachmentContentMixin on BaseSaveAndReopenScenario {
  @override
  Future<void> attachContent(AbstractComposerRobot composerRobot, Uint8List bytes) =>
      composerRobot.addAttachmentFromBytes(bytes, 'test-attachment.png');

  @override
  Future<void> waitForContentUploaded(AbstractComposerRobot composerRobot) =>
      waitForCondition(() {
        final controller = composerRobot.findComposerController();
        return controller?.uploadController.allAttachmentsUploaded.isNotEmpty ?? false;
      });
}

mixin WithInlineImageContentMixin on BaseSaveAndReopenScenario {
  @override
  Future<void> attachContent(AbstractComposerRobot composerRobot, Uint8List bytes) =>
      composerRobot.addInlineFromBytes(bytes, 'test-inline.png');

  @override
  Future<void> waitForContentUploaded(AbstractComposerRobot composerRobot) =>
      waitForCondition(() {
        final controller = composerRobot.findComposerController();
        return controller?.uploadController.inlineAttachmentsUploaded.isNotEmpty ?? false;
      });
}
