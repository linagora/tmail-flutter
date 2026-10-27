import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';

class CloseThreadDetailWithEscapeScenario extends BaseTestScenario {
  const CloseThreadDetailWithEscapeScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    const subject = 'close thread detail with escape';
    final threadRobot = robots.threadRobot();
    final keyboardRobot = robots.hardwareKeyboardRobot()!;

    await robots.commonRobot().provisionEmail([
      ProvisioningEmail(
        toEmail: const String.fromEnvironment('BASIC_AUTH_EMAIL'),
        subject: subject,
        content: 'body',
      ),
    ], requestReadReceipt: false);

    await threadRobot.openEmailWithSubject(subject);
    await threadRobot.assertion.expectThreadDetailOpened();

    await keyboardRobot.pressKey('Escape');

    await threadRobot.assertion.expectThreadDetailClosed();
  }
}
