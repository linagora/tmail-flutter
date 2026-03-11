import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/generate_email_scenario_mixin.dart';
import '../../mixin/setting_scenario_mixin.dart';
import '../../robots/email_robot.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/setting_robot.dart';
import '../../robots/thread_robot.dart';

class DeleteThreadToTrashScenario extends BaseTestScenario
    with GenerateEmailScenarioMixin, SettingScenarioMixin {
  const DeleteThreadToTrashScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const subject = 'Delete thread to trash';
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');

    final threadRobot = ThreadRobot($);
    final settingRobot = SettingRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
    final emailRobot = EmailRobot($);
    final appLocalizations = AppLocalizations();

    await goToSettingToEnableThread(
      threadRobot: threadRobot,
      settingRobot: settingRobot,
      mailboxMenuRobot: mailboxMenuRobot,
    );

    await generateEmailWithSubject(emailUser: emailUser, subject: subject);

    await threadRobot.openEmailWithSubject(subject);
    await $.pumpAndSettle();

    await emailRobot.tapDeleteThreadButton();
    await $.pumpAndSettle();

    await _expectDeleteThreadSuccessToast(appLocalizations);
  }

  Future<void> _expectDeleteThreadSuccessToast(
    AppLocalizations appLocalizations,
  ) async {
    await expectViewVisible(
      $(find.text(appLocalizations.moved_to_trash)),
    );
  }
}
