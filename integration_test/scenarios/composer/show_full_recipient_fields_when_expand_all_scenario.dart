import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';

import '../../base/base_test_scenario.dart';
import '../../robots/composer_robot.dart';
import '../../robots/thread_robot.dart';

class ShowFullRecipientFieldsWhenExpandAllScenario extends BaseTestScenario {
  const ShowFullRecipientFieldsWhenExpandAllScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const subject = 'Show full recipient fields';

    final threadRobot = ThreadRobot($);
    final composerRobot = ComposerRobot($);

    await threadRobot.openComposer();
    await _expectComposerViewVisible();

    await composerRobot.grantContactPermission();
    await $.pumpAndTrySettle();
    await composerRobot.tapToRecipientExpandButton();
    await _expectAllRecipientFieldsVisible();

    await composerRobot.addRecipientIntoField(
      prefixEmailAddress: PrefixEmailAddress.cc,
      email: email,
    );
    await composerRobot.addSubject(subject);
    await _expectAllRecipientFieldsInvisible();
    await $.pumpAndTrySettle();

    await composerRobot.expandRecipientsFields();
    await composerRobot.tapCcRecipientExpandButton();
    await _expectAllRecipientFieldsVisible();
  }

  Future<void> _expectComposerViewVisible() =>
      expectViewVisible($(ComposerView));

  Future<void> _expectAllRecipientFieldsVisible() async {
    await expectViewVisible(
      $(#prefix_to_recipient_composer_widget),
    );
    await expectViewVisible(
      $(#prefix_cc_recipient_composer_widget),
    );
    await expectViewVisible(
      $(#prefix_bcc_recipient_composer_widget),
    );
    await expectViewVisible(
      $(#prefix_replyTo_recipient_composer_widget),
    );
  }

  Future<void> _expectAllRecipientFieldsInvisible() async {
    await expectViewInvisible(
      $(#prefix_to_recipient_composer_widget),
    );
    await expectViewInvisible(
      $(#prefix_cc_recipient_composer_widget),
    );
    await expectViewInvisible(
      $(#prefix_bcc_recipient_composer_widget),
    );
    await expectViewInvisible(
      $(#prefix_replyTo_recipient_composer_widget),
    );
  }
}
