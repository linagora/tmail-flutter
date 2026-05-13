import 'package:flutter/foundation.dart';

import '../../robots/abstract/abstract_composer_robot.dart';
import '../../utils/wait_for_condition.dart';
import 'base_save_draft_then_reopen_scenario.dart';

class SaveDraftWithInlineImageThenOpenAndSaveDraftAgainScenario
    extends BaseSaveDraftThenReopenScenario {
  const SaveDraftWithInlineImageThenOpenAndSaveDraftAgainScenario(super.$, super.robots);

  @override
  String get subject => 'Draft with inline image - second save';

  @override
  Future<void> attachContent(AbstractComposerRobot composerRobot, Uint8List bytes) =>
      composerRobot.addInlineFromBytes(bytes, 'draft-inline.png');

  @override
  Future<void> waitForContentUploaded(AbstractComposerRobot composerRobot) =>
      waitForCondition(() {
        final controller = composerRobot.findComposerController();
        return controller?.uploadController.inlineAttachmentsUploaded.isNotEmpty ?? false;
      });
}
