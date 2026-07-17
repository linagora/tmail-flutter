import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../robots/abstract/abstract_composer_robot.dart';
import '../../utils/test_timeouts.dart';
import '../../utils/wait_for_condition.dart';
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

    await _saveDraftAndWaitForOutcome(() async {
      await composerRobot.tapSaveButtonOnSaveDraftConfirmDialog(l10n);
      // The close→save-draft confirm dialog reuses #confirm_dialog_action; settle so
      // it is gone before the race treats a visible dialog as the failure signal.
      await $.pumpAndTrySettle();
    });
    await $.pumpAndTrySettle();
  }

  @override
  Future<void> performSubsequentSave(
    AbstractComposerRobot composerRobot,
    AppLocalizations l10n,
  ) async {
    await _saveDraftAndWaitForOutcome(composerRobot.tapSaveAsDraftButton);
    await $.pumpAndTrySettle();
  }

  /// Runs [saveAction], then returns once the save has actually resolved: either the
  /// success state lands on the dashboard bus, or the failure confirm dialog appears.
  ///
  /// A draft-save failure never reaches this bus — it is surfaced as a confirm dialog
  /// — so that dialog is the failure signal. The subscription is set up *before*
  /// [saveAction] runs because the success state is momentary and is usually emitted
  /// before the tree settles, so sampling it afterwards would race and miss it.
  /// Racing success against the dialog means a failed save reports in seconds instead
  /// of burning the full timeout.
  Future<void> _saveDraftAndWaitForOutcome(
    Future<void> Function() saveAction,
  ) async {
    final dashboardController = Get.find<MailboxDashBoardController>();
    var saveSucceeded = false;
    final subscription = dashboardController.viewState.stream.listen((state) {
      state.fold((_) {}, (success) {
        if (success is SaveEmailAsDraftsSuccess ||
            success is UpdateEmailDraftsSuccess) {
          saveSucceeded = true;
        }
      });
    });

    try {
      await saveAction();
      await waitForCondition(
        () => saveSucceeded || $(#confirm_dialog_action).visible,
        timeout: TestTimeouts.long,
      );
    } finally {
      await subscription.cancel();
    }

    expect(
      $(#confirm_dialog_action).visible,
      isFalse,
      reason:
          'Draft failed to save: a confirm dialog is shown instead of being persisted.',
    );
  }
}
