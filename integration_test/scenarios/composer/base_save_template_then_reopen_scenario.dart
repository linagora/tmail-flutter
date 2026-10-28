import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../robots/abstract/abstract_composer_robot.dart';
import '../../utils/test_timeouts.dart';
import '../../utils/wait_for_condition.dart';
import 'base_save_and_reopen_scenario.dart';

abstract class BaseSaveTemplateThenReopenScenario extends BaseSaveAndReopenScenario {
  const BaseSaveTemplateThenReopenScenario(super.$, super.robots);

  @override
  String folderDisplayName(AppLocalizations l10n) => l10n.templatesMailboxDisplayName;

  @override
  Future<void> onPreComposerSetup() async {
    if (PlatformInfo.isMobile) {
      await robots.threadRobot().openMailbox();
      await $.pumpAndTrySettle();
      await robots.mailboxMenuRobot().pullToRefresh();
      await mobileBack($);
    }
  }

  @override
  Future<void> performFirstSave(
    AbstractComposerRobot composerRobot,
    AppLocalizations l10n,
  ) async {
    await _saveTemplateAndWaitForNewId(composerRobot);
    await $.pumpAndTrySettle();
    await composerRobot.tapCloseComposer();
    await $.pumpAndTrySettle();
    await composerRobot.tapDiscardChanges();
    await $.pumpAndTrySettle();
  }

  @override
  Future<void> onAfterComposerReopened() async {
    await $.pumpAndTrySettle(duration: const Duration(seconds: 2));
  }

  @override
  Future<void> performSubsequentSave(
    AbstractComposerRobot composerRobot,
    AppLocalizations l10n,
  ) async {
    await _saveTemplateAndWaitForNewId(composerRobot);
  }

  // The 3 s success toast can expire while the save action settles
  Future<void> _saveTemplateAndWaitForNewId(
    AbstractComposerRobot composerRobot,
  ) async {
    final composer = composerRobot.findComposerController();
    if (composer == null) fail('No open composer to save as a template');
    final previousTemplateId = composer.currentTemplateEmailId;
    await composerRobot.tapSaveAsTemplateButton();
    await waitForCondition(
      () async {
        await $.pump();
        final templateId = composer.currentTemplateEmailId;
        return templateId != null && templateId != previousTemplateId;
      },
      timeout: TestTimeouts.long,
      reason: 'Template was not saved',
    );
  }
}
