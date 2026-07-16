import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/base_test_scenario.dart';
import '../robots/abstract/abstract_composer_robot.dart';
import '../utils/test_timeouts.dart';
import '../utils/wait_for_condition.dart';

class SendEmailScenario extends BaseTestScenario {
  const SendEmailScenario(super.$, super.robots, {this.customSubject});

  final String? customSubject;

  @override
  Future<void> runTestLogic() async {
    const additionalRecipient = String.fromEnvironment('ADDITIONAL_MAIL_RECIPIENT');
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const content = 'Test content';
    final subject = customSubject ?? 'Test subject';
    final l10n = AppLocalizations();
    final composerRobot = robots.composerRobot();
    final threadRobot = robots.threadRobot();
    final mailboxMenuRobot = robots.mailboxMenuRobot();

    await threadRobot.openComposer();
    await composerRobot.expectComposerViewVisible();

    await composerRobot.grantContactPermission();

    await composerRobot.addRecipient(PrefixEmailAddress.to, email);
    await composerRobot.addRecipient(PrefixEmailAddress.to, additionalRecipient);
    await composerRobot.addSubject(subject);
    await composerRobot.addContent(content);

    await _sendAndWaitForCompletion(composerRobot);

    // A visible thread list is not proof the email was sent: on web the composer is
    // an overlay and the thread list stays mounted behind it, so it reads as visible
    // before the send even completes. Confirm delivery by finding the message in the
    // Sent mailbox instead.
    await $.pumpAndTrySettle();
    if (PlatformInfo.isMobile) {
      await threadRobot.openMailbox();
    }
    await mailboxMenuRobot.navigation.openFolder(
      mailboxMenuRobot.mailboxItemByName(l10n.sentMailboxDisplayName),
    );
    await waitForCondition(() => $(subject).exists);
  }

  /// Taps Send and returns once the send has actually resolved: either the success
  /// state lands on the dashboard bus, or the failure confirm dialog appears.
  ///
  /// The subscription is set up *before* the tap because [SendEmailSuccess] is
  /// momentary and is usually emitted before the tree settles, so reading it after
  /// the tap would race and miss it. A send failure never reaches this bus — it is
  /// surfaced as a confirm dialog — so that dialog is the failure signal. Racing the
  /// two means a failed send reports in seconds instead of burning the full timeout.
  Future<void> _sendAndWaitForCompletion(AbstractComposerRobot composerRobot) async {
    final dashboardController = Get.find<MailboxDashBoardController>();
    var sendSucceeded = false;
    final subscription = dashboardController.viewState.stream.listen((state) {
      state.fold((_) {}, (success) {
        if (success is SendEmailSuccess) sendSucceeded = true;
      });
    });

    try {
      await composerRobot.send();
      await waitForCondition(
        () => sendSucceeded || $(#confirm_dialog_action).visible,
        timeout: TestTimeouts.long,
      );
    } finally {
      await subscription.cancel();
    }

    expect(
      $(#confirm_dialog_action).visible,
      isFalse,
      reason: 'Email failed to send: a confirm dialog is shown instead of being filed to Sent.',
    );
  }
}
