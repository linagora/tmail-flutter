import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/base_test_scenario.dart';
import '../utils/send_and_wait_for_completion.dart';
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

    await sendAndWaitForCompletion($, composerRobot);

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
}
