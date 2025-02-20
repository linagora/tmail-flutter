import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';

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

    await threadRobot.openComposer();
    await _expectComposerViewVisible();

    await composerRobot.grantContactPermission();

    await composerRobot.addRecipient(email);
    await composerRobot.addRecipient(additionalRecipient);
    await composerRobot.addSubject(subject);
    await composerRobot.addContent(content);
    await composerRobot.sendEmail();

    await _expectSendEmailSuccessToast();
  }
  
  Future<void> _expectComposerViewVisible() => expectViewVisible($(ComposerView));

  Future<void> _expectSendEmailSuccessToast() async {
    expect($('Message has been sent successfully'), findsOneWidget);
  }
}