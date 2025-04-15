import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_composer_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../robots/email_robot.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';
import '../send_email_scenario.dart';

class ReplyToOwnSentEmailScenario extends BaseTestScenario {
  const ReplyToOwnSentEmailScenario(super.$);
  
  @override
  Future<void> runTestLogic() async {
    const subject = 'reply own sent email';

    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
    final emailRobot = EmailRobot($);
    final sendEmailScenario = SendEmailScenario($, customSubject: subject);
    final appLocalizations = AppLocalizations();

    await sendEmailScenario.runTestLogic();
    await threadRobot.openMailbox();
    await mailboxMenuRobot.openFolderByName(
      appLocalizations.sentMailboxDisplayName,
    );
    await threadRobot.openEmailWithSubject(subject);
    await emailRobot.onTapReplyEmail();
    _expectToFieldContainListEmailAddressCorrectly();
  }

  void _expectToFieldContainListEmailAddressCorrectly()  {
    expect(
      $(RecipientComposerWidget).which<RecipientComposerWidget>((widget) =>
        widget.prefix == PrefixEmailAddress.to &&
        isMatchingEmailList(
          widget.listEmailAddress,
          {'bob@example.com', 'alice@example.com'}
        )
      ).visible,
      isTrue,
    );
  }
}