import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../robots/composer_robot.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class TeamMailboxReceiveEmailScenario extends BaseTestScenario {
  const TeamMailboxReceiveEmailScenario(super.$);
  
  @override
  Future<void> runTestLogic() async {
    const teamMailboxName = 'bob-guests';
    const teamMailboxEmail = '$teamMailboxName@example.com';
    const subject = 'email to team mailbox';

    final threadRobot = ThreadRobot($);
    final composerRobot = ComposerRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
    final imagePaths = ImagePaths();
    final appLocalizations = AppLocalizations();

    await threadRobot.openMailbox();
    await _expectMailboxViewVisible();
    await _expectTeamMailboxVisible(teamMailboxName);

    await mailboxMenuRobot.closeMenu();
    await threadRobot.openComposer();
    await _expectComposerViewVisible();
    await composerRobot.grantContactPermission();
    await composerRobot.addRecipientIntoField(
      prefixEmailAddress: PrefixEmailAddress.to,
      email: teamMailboxEmail,
    );
    await composerRobot.addSubject(subject);
    await composerRobot.sendEmail(imagePaths);
    await _expectSendEmailSuccessToast(appLocalizations);
    await $.pump(const Duration(seconds: 2));

    await threadRobot.openMailbox();
    await mailboxMenuRobot.expandMailboxWithName(teamMailboxName);
    await mailboxMenuRobot.openFolderByName(appLocalizations.inboxMailboxDisplayName.toUpperCase());
    await _expectEmailWithSubjectVisible(subject);
  }

  Future<void> _expectMailboxViewVisible() async {
    await expectViewVisible($(MailboxView));
  }

  Future<void> _expectTeamMailboxVisible(String name) async {
    await $.scrollUntilVisible(finder: $(name));
    await expectViewVisible($(name));
  }

  Future<void> _expectComposerViewVisible() async {
    await expectViewVisible($(ComposerView));
  }

  Future<void> _expectSendEmailSuccessToast(AppLocalizations appLocalizations) async {
    await expectViewVisible(
      $(find.text(appLocalizations.message_has_been_sent_successfully)),
    );
  }

  Future<void> _expectEmailWithSubjectVisible(String subject) async {
    await expectViewVisible($(subject));
  }
}