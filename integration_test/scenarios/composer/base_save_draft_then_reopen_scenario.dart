import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../robots/abstract/abstract_composer_robot.dart';
import '../../utils/wait_for_view_state.dart';
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

    final saved = _waitForDraftSaved();
    await composerRobot.tapSaveButtonOnSaveDraftConfirmDialog(l10n);
    await saved;
    await $.pumpAndTrySettle();
  }

  @override
  Future<void> performSubsequentSave(
    AbstractComposerRobot composerRobot,
    AppLocalizations l10n,
  ) async {
    final saved = _waitForDraftSaved();
    await composerRobot.tapSaveAsDraftButton();
    await saved;
  }

  Future<void> _waitForDraftSaved() => waitForViewState(
    Get.find<MailboxDashBoardController>(),
    ViewStateExpectation(
      matcher: (state) =>
          state is SaveEmailAsDraftsSuccess || state is UpdateEmailDraftsSuccess,
      failureMatcher: (state) =>
          state is SaveEmailAsDraftsFailure || state is UpdateEmailDraftsFailure,
      description: 'SaveEmailAsDraftsSuccess/UpdateEmailDraftsSuccess',
    ),
  );
}
