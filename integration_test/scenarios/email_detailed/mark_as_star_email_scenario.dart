
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
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
    final imagePaths = ImagePaths();

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
    _expectEmailDetailedStarButtonVisible();

    await emailRobot.tapEmailDetailedStarButton();
    await $.pumpAndSettle(duration: const Duration(seconds: 2));
    await _expectDisplayedStarIcon(imagePaths);

    await emailRobot.tapEmailDetailedStarButton();
    await $.pumpAndSettle(duration: const Duration(seconds: 2));
    await _expectDisplayedUnStarIcon(imagePaths);
  }

  void _expectEmailDetailedStarButtonVisible() {
    expect($(#email_detailed_star_button), findsOneWidget);
  }

  Future<void> _expectDisplayedStarIcon(ImagePaths imagePaths) async {
    await expectViewVisible(
      $(#email_detailed_star_button).which<TMailButtonWidget>(
          (widget) => widget.icon == imagePaths.icStar),
    );
  }

  Future<void> _expectDisplayedUnStarIcon(ImagePaths imagePaths) async {
    await expectViewVisible(
      $(#email_detailed_star_button).which<TMailButtonWidget>(
          (widget) => widget.icon == imagePaths.icUnStar),
    );
  }
}