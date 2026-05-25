import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../robots/abstract/abstract_composer_robot.dart';
import 'base_save_and_reopen_scenario.dart';

abstract class BaseSaveDraftThenReopenScenario extends BaseSaveAndReopenScenario {
  const BaseSaveDraftThenReopenScenario(super.$, super.robots);

  @override
  String folderDisplayName(AppLocalizations l10n) => l10n.draftsMailboxDisplayName;

  @override
  Future<void> performFirstSave(
    AbstractComposerRobot composerRobot,
    AppLocalizations l10n,
  ) async {
    await composerRobot.tapCloseComposer();
    await $.pumpAndTrySettle();
    await expectViewVisible($(#confirm_dialog_action));
    await composerRobot.tapSaveButtonOnSaveDraftConfirmDialog(l10n);
    await $.pumpAndTrySettle();
    await _expectSaveDraftSuccessToast(l10n);
    await $.pumpAndTrySettle();
  }

  @override
  Future<void> performSubsequentSave(
    AbstractComposerRobot composerRobot,
    AppLocalizations l10n,
  ) async {
    await composerRobot.tapSaveAsDraftButton();
    await $.pumpAndTrySettle();
    await _expectSaveDraftSuccessToast(l10n);
  }

  Future<void> _expectSaveDraftSuccessToast(AppLocalizations l10n) async {
    await expectViewVisible($(l10n.drafts_saved));
  }
}
