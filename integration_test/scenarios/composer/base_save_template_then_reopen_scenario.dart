import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../robots/abstract/abstract_composer_robot.dart';
import 'base_save_and_reopen_scenario.dart';

abstract class BaseSaveTemplateThenReopenScenario extends BaseSaveAndReopenScenario {
  const BaseSaveTemplateThenReopenScenario(super.$, super.robots);

  @override
  String folderDisplayName(AppLocalizations l10n) => l10n.templatesMailboxDisplayName;

  @override
  Future<void> onPreComposerSetup() async {
    if (PlatformInfo.isMobile) {
      await robots.threadRobot().openMailbox();
      await robots.mailboxMenuRobot().pullToRefresh();
      await mobileBack($);
    }
  }

  @override
  Future<void> performFirstSave(
    AbstractComposerRobot composerRobot,
    AppLocalizations l10n,
  ) async {
    await composerRobot.tapSaveAsTemplateButton();
    await _expectSaveTemplateSuccessToast(l10n);
    await composerRobot.tapCloseComposer();
    await composerRobot.tapDiscardChanges();
  }

  @override
  Future<void> onAfterComposerReopened() async {}

  @override
  Future<void> performSubsequentSave(
    AbstractComposerRobot composerRobot,
    AppLocalizations l10n,
  ) async {
    await composerRobot.tapSaveAsTemplateButton();
    await _expectUpdateTemplateSuccessToast(l10n);
  }

  Future<void> _expectSaveTemplateSuccessToast(AppLocalizations l10n) async {
    await expectViewVisible($(l10n.saveMessageToTemplateSuccess));
  }

  Future<void> _expectUpdateTemplateSuccessToast(AppLocalizations l10n) async {
    await expectViewVisible($(l10n.updateMessageToTemplateSuccess));
  }
}
