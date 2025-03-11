import 'package:core/core.dart';
import 'package:duration/duration.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../robots/composer_robot.dart';
import '../../robots/thread_robot.dart';

class SendEmailWithReadReceiptEnabledScenario extends BaseTestScenario {
  const SendEmailWithReadReceiptEnabledScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const additionalRecipient = String.fromEnvironment('ADDITIONAL_MAIL_RECIPIENT');
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const subject = 'Test read receipt subject';
    const content = 'Test content';

    final threadRobot = ThreadRobot($);
    final composerRobot = ComposerRobot($);
    final imagePaths = ImagePaths();
    final appLocalizations = AppLocalizations();

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
    await composerRobot.tapMoreOptionOnAppBar();
    await composerRobot.toggleReadReceipt();
    await _expectReadReceiptToggleSuccessfullyToast(appLocalizations);

    await composerRobot.sendEmail(imagePaths);

    await _expectSendEmailSuccessToast(appLocalizations);

    await $.pumpAndSettle(duration: seconds(5));
    await threadRobot.openEmailWithSubject(subject);
    await _expectReadReceiptRequestDialog(appLocalizations);
  }

  Future<void> _expectReadReceiptRequestDialog(
    AppLocalizations appLocalizations
  ) async {
    await expectViewVisible(
      $(appLocalizations.titleReadReceiptRequestNotificationMessage)
    );
  }

  Future<void> _expectReadReceiptToggleSuccessfullyToast(
    AppLocalizations appLocalizations
  ) async {
    await expectViewVisible(
      $(appLocalizations.requestReadReceiptHasBeenEnabled)
    );
  }
  
  Future<void> _expectComposerViewVisible() => expectViewVisible($(ComposerView));

  Future<void> _expectSendEmailSuccessToast(AppLocalizations appLocalizations) async {
    await expectViewVisible(
      $(find.text(appLocalizations.message_has_been_sent_successfully)),
    );
  }
}
