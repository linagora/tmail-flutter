import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/base_test_scenario.dart';
import '../robots/composer_robot.dart';
import '../robots/thread_robot.dart';

class SendEmailScenario extends BaseTestScenario {
  const SendEmailScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const additionalRecipient = String.fromEnvironment('ADDITIONAL_MAIL_RECIPIENT');
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const subject = 'Test subject';
    const content = 'Test content';

    final threadRobot = ThreadRobot($);
    final composerRobot = ComposerRobot($);
    final imagePaths = ImagePaths();

    await threadRobot.openComposer();
    await _expectComposerViewVisible();

    await composerRobot.grantContactPermission();

    await composerRobot.addRecipientIntoField(
      prefixEmailAddress: PrefixEmailAddress.to,
      email: email,
    );
    await composerRobot.addRecipientIntoField(
      prefixEmailAddress: PrefixEmailAddress.to,
      email: additionalRecipient,
    );
    await composerRobot.addSubject(subject);
    await composerRobot.addContent(content);
    await composerRobot.sendEmail(imagePaths);

    await _expectSendEmailSuccessToast();
  }
  
  Future<void> _expectComposerViewVisible() => expectViewVisible($(ComposerView));

  Future<void> _expectSendEmailSuccessToast() async {
    await expectViewVisible(
      $(find.text(AppLocalizations().message_has_been_sent_successfully)),
    );
  }
}