import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/email_address_dialog_robot.dart';
import '../../robots/email_robot.dart';
import '../../robots/setting_robot.dart';

class CreateEditRuleWithRejectScenario extends BaseTestScenario {
  const CreateEditRuleWithRejectScenario(super.$, super.robots);

  static const _subject = 'Create edit rule with reject action';
  static const _ruleName = 'Reject rule';

  @override
  Future<void> runTestLogic() async {
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');
    final appLocalizations = AppLocalizations();

    final threadRobot = robots.threadRobot();
    final emailRobot = EmailRobot($);
    final emailAddressDialogRobot = EmailAddressDialogRobot($);
    final mailboxMenuRobot = robots.mailboxMenuRobot();
    final settingRobot = SettingRobot($);
    final rulesFilterCreatorRobot = robots.rulesFilterCreatorRobot();
    final emailRulesSettingRobot = robots.emailRulesSettingRobot();

    await provisionEmail(
      [
        ProvisioningEmail(
          toEmail: emailUser,
          subject: _subject,
          content: _subject,
        ),
      ],
      requestReadReceipt: false,
    );

    await threadRobot.openEmailWithSubject(_subject);

    await emailRobot.tapSenderEmailAddress(emailUser);

    await emailAddressDialogRobot
        .tapCreateRuleWithThisEmailAddressButton(appLocalizations);

    await rulesFilterCreatorRobot.expectCreatorViewVisible();

    await rulesFilterCreatorRobot.enterRuleName(_ruleName);

    await rulesFilterCreatorRobot.selectEmptyActionSlot(
      appLocalizations.rejectIt,
      appLocalizations.selectAction,
    );

    await rulesFilterCreatorRobot.tapCreateRuleButton();

    await rulesFilterCreatorRobot.expectWarningTextVisible(
      appLocalizations.messageConfirmationRuleWithRejectAction,
    );

    await rulesFilterCreatorRobot.confirmWarningDialog(
      appLocalizations.confirm,
    );

    await emailRobot.onTapBackButton();

    await mailboxMenuRobot.openSetting();

    await settingRobot.openEmailRulesMenuItem();

    await emailRulesSettingRobot.expectRuleVisible(_ruleName);

    await emailRulesSettingRobot.tapEditRule(
      _ruleName,
      appLocalizations.editRule,
    );

    await rulesFilterCreatorRobot.expectCreatorViewVisible();

    await rulesFilterCreatorRobot.tapAddActionButton();

    await rulesFilterCreatorRobot.selectEmptyActionSlot(
      appLocalizations.maskAsSeen,
      appLocalizations.selectAction,
    );

    await rulesFilterCreatorRobot.tapAddActionButton();

    await rulesFilterCreatorRobot.selectEmptyActionSlot(
      appLocalizations.starIt,
      appLocalizations.selectAction,
    );

    await rulesFilterCreatorRobot.tapCreateRuleButton();

    await rulesFilterCreatorRobot.expectWarningTextVisible(
      appLocalizations.messageConfirmationRuleWithRejectAction,
    );

    await rulesFilterCreatorRobot
        .confirmWarningDialog(appLocalizations.confirm);

    await rulesFilterCreatorRobot.expectCreatorViewClosed();

    await emailRulesSettingRobot.expectRuleVisible(_ruleName);
  }
}
