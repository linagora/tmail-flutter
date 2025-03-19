import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/thread_robot.dart';

class MarkSingleSelectedEmailAsReadScenario extends BaseTestScenario {
  const MarkSingleSelectedEmailAsReadScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const readSubject = 'single selected read';

    final threadRobot = ThreadRobot($);

    await provisionEmail([
      ProvisioningEmail(toEmail: email, subject: readSubject, content: ''),
    ]);
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    await threadRobot.longPressEmailWithSubject(readSubject);
    await threadRobot.tapMarkAsReadButton();
    await _expectEmailWithSubjectIsRead(readSubject);
  }

  Future<void> _expectEmailWithSubjectIsRead(String subject) async {
    await expectViewVisible($(EmailTileBuilder).which<EmailTileBuilder>(
      (widget) => widget.presentationEmail.subject == subject
        && widget.presentationEmail.hasRead
    ));
  }
}