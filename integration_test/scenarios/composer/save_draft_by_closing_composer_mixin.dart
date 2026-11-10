import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../robots/web/web_composer_robot.dart';
import '../../utils/test_timeouts.dart';
import '../../utils/wait_for_condition.dart';

mixin SaveDraftByClosingComposerMixin on BaseTestScenario {
  /// Mirrors [BaseSaveDraftThenReopenScenario.performFirstSave]: subscribe
  /// before tapping Save so a momentary success state is not missed.
  Future<void> saveDraftByClosingComposer(
    WebComposerRobot composerRobot,
    AppLocalizations l10n,
  ) async {
    await composerRobot.tapCloseComposer();
    await $.pumpAndTrySettle();
    await expectViewVisible($(#confirm_dialog_action));

    final dashboardController = Get.find<MailboxDashBoardController>();
    var saveSucceeded = false;
    final subscription = dashboardController.viewState.stream.listen((state) {
      state.fold((_) {}, (success) {
        if (success is SaveEmailAsDraftsSuccess) {
          saveSucceeded = true;
        }
      });
    });

    try {
      await composerRobot.tapSaveButtonOnSaveDraftConfirmDialog(l10n);
      // Confirm dialog reuses #confirm_dialog_action. Settle so a still-visible
      // confirm dialog is not treated as the failure signal.
      await $.pumpAndTrySettle();
      await waitForCondition(
        () => saveSucceeded || $(#confirm_dialog_action).visible,
        timeout: TestTimeouts.long,
        reason: 'draft save to succeed or show a failure dialog',
      );
    } finally {
      await subscription.cancel();
    }

    expect(
      saveSucceeded,
      isTrue,
      reason: 'draft save did not emit SaveEmailAsDraftsSuccess',
    );
    expect(
      $(#confirm_dialog_action).visible,
      isFalse,
      reason: 'draft save failed (confirm dialog still visible)',
    );
  }
}
