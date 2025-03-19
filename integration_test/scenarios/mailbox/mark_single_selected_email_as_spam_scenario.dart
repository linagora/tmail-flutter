import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class MarkSingleSelectedEmailAsSpamScenario extends BaseTestScenario {
  const MarkSingleSelectedEmailAsSpamScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const spamSubject = 'single selected spam';

    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);

    await provisionEmail([
      ProvisioningEmail(toEmail: email, subject: spamSubject, content: ''),
    ]);
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    await threadRobot.longPressEmailWithSubject(spamSubject);
    await threadRobot.tapMarkAsSpamAction();
    await threadRobot.openMailbox();
    await mailboxMenuRobot.openFolderByName(
      AppLocalizations().spamMailboxDisplayName,
    );
    await _expectEmailWithSubjectExist(spamSubject);
  }

  Future<void> _expectEmailWithSubjectExist(String subject) async {
    await expectViewVisible($(EmailTileBuilder).which<EmailTileBuilder>(
      (widget) => widget.presentationEmail.subject == subject
    ));
  }
}
