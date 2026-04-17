import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/base_test_scenario.dart';

class SendEmailScenario extends BaseTestScenario {
  const SendEmailScenario(super.$, super.robots, {this.customSubject});

  final String? customSubject;

  @override
  Future<void> runTestLogic() async {
    const additionalRecipient = String.fromEnvironment('ADDITIONAL_MAIL_RECIPIENT');
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const subject = 'Test subject';
    const content = 'Test content';

    await robots.threadRobot().openComposer();
    await _expectComposerViewVisible();

    await robots.composerRobot().grantContactPermission();

    await robots.composerRobot().addRecipient(PrefixEmailAddress.to, email);
    await robots.composerRobot().addRecipient(PrefixEmailAddress.to, additionalRecipient);
    await robots.composerRobot().addSubject(customSubject ?? subject);
    await robots.composerRobot().addContent(content);
    await robots.composerRobot().send();

    await _expectSendEmailSuccessToast();
  }

  Future<void> _expectComposerViewVisible() => expectViewVisible($(ComposerView));

  Future<void> _expectSendEmailSuccessToast() async {
    await expectViewVisible(
      $(find.text(AppLocalizations().message_has_been_sent_successfully)),
    );
  }
}