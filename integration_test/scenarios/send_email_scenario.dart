import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
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

    await timedStep('open_composer', robots.threadRobot().openComposer);
    await timedStep('expect_composer', robots.composerRobot().expectComposerViewVisible);
    await timedStep('grant_contact_permission', robots.composerRobot().grantContactPermission);
    await timedStep('add_recipient_self', () => robots.composerRobot().addRecipient(PrefixEmailAddress.to, email));
    await timedStep('add_recipient_extra', () => robots.composerRobot().addRecipient(PrefixEmailAddress.to, additionalRecipient));
    await timedStep('add_subject', () => robots.composerRobot().addSubject(customSubject ?? subject));
    await timedStep('add_content', () => robots.composerRobot().addContent(content));
    await timedStep('send', robots.composerRobot().send);
    await timedStep('expect_success_toast', _expectSendEmailSuccessToast);
  }

  Future<void> _expectSendEmailSuccessToast() async {
    await expectViewVisible(
      $(find.text(AppLocalizations().message_has_been_sent_successfully)),
    );
  }
}