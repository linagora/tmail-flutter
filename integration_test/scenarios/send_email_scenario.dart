import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';

import '../base/base_test_scenario.dart';
import '../utils/test_timeouts.dart';
import '../utils/wait_for_condition.dart';

class SendEmailScenario extends BaseTestScenario {
  const SendEmailScenario(super.$, super.robots, {this.customSubject});

  final String? customSubject;

  @override
  Future<void> runTestLogic() async {
    const additionalRecipient = String.fromEnvironment('ADDITIONAL_MAIL_RECIPIENT');
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const subject = 'Test subject';
    const content = 'Test content';

    await robots.threadRobot().openComposer();
    await robots.composerRobot().expectComposerViewVisible();

    await robots.composerRobot().grantContactPermission();

    await robots.composerRobot().addRecipient(PrefixEmailAddress.to, email);
    await robots.composerRobot().addRecipient(PrefixEmailAddress.to, additionalRecipient);
    await robots.composerRobot().addSubject(customSubject ?? subject);
    await robots.composerRobot().addContent(content);
    await robots.composerRobot().send();

    await waitForCondition(
      () => $(ThreadView).visible || $(#confirm_dialog_action).visible,
      timeout: TestTimeouts.long,
    );
    expect(
      $(#confirm_dialog_action).visible,
      isFalse,
      reason: 'Email failed to send: a confirm dialog is shown instead of returning to the thread list.',
    );
    await expectViewVisible($(ThreadView));
  }
}