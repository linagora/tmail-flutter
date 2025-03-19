import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/thread_robot.dart';

class MarkSingleSelectedEmailAsStarScenario extends BaseTestScenario {
  const MarkSingleSelectedEmailAsStarScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const starSubject = 'single selected star';

    final threadRobot = ThreadRobot($);

    await provisionEmail([
      ProvisioningEmail(toEmail: email, subject: starSubject, content: ''),
    ]);
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    await threadRobot.longPressEmailWithSubject(starSubject);
    await threadRobot.tapMarkAsStarAction();
    await _expectEmailWithSubjectIsStarred(starSubject);
  }

  Future<void> _expectEmailWithSubjectIsStarred(String subject) async {
    await expectViewVisible($(EmailTileBuilder).which<EmailTileBuilder>(
      (widget) => widget.presentationEmail.subject == subject
        && widget.presentationEmail.hasStarred
    ));
  }
}