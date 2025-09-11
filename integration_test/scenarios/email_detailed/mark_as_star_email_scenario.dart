import 'package:flutter_test/flutter_test.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/email_robot.dart';
import '../../robots/thread_robot.dart';

class MarkAsStarEmailScenario extends BaseTestScenario {

  const MarkAsStarEmailScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const subject = 'Mark as star/unStar email';
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');
    final threadRobot = ThreadRobot($);
    final emailRobot = EmailRobot($);

    await provisionEmail(
      [
        ProvisioningEmail(
          toEmail: emailUser,
          subject: subject,
          content: subject,
        ),
      ],
      requestReadReceipt: false,
    );
    await $.pumpAndSettle();

    await threadRobot.openEmailWithSubject(subject);
    await $.pumpAndSettle();
    await emailRobot.tapEmailDetailedMoreButton();
    await _expectEmailDetailedStarButtonVisible();

    await emailRobot.tapEmailDetailedStarButton();
    await $.pumpAndSettle(duration: const Duration(seconds: 1));
    await emailRobot.tapEmailDetailedMoreButton();
    await _expectDisplayedUnStarIcon();

    await emailRobot.tapEmailDetailedUnstarButton();
    await $.pumpAndSettle(duration: const Duration(seconds: 1));
    await emailRobot.tapEmailDetailedMoreButton();
    await _expectDisplayedStarIcon();
  }

  Future<void> _expectEmailDetailedStarButtonVisible() async {
    await expectViewVisible($(#markAsStarred_action));
  }

  Future<void> _expectDisplayedStarIcon() async {
    await expectViewVisible($(#markAsStarred_action));
  }

  Future<void> _expectDisplayedUnStarIcon() async {
    await expectViewVisible($(#unMarkAsStarred_action));
  }
}