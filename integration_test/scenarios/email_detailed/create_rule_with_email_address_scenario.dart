
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/widget/default_field/default_input_field_widget.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/rules_filter_creator_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/email_address_dialog_robot.dart';
import '../../robots/email_robot.dart';
import '../../robots/thread_robot.dart';

class CreateRuleWithEmailAddressScenario extends BaseTestScenario {

  const CreateRuleWithEmailAddressScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const subject = 'Create rule with email address';
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');
    final threadRobot = ThreadRobot($);
    final emailRobot = EmailRobot($);
    final emailAddressDialogRobot = EmailAddressDialogRobot($);
    final appLocalizations = AppLocalizations();

    await provisionEmail(
      [
        ProvisioningEmail(
          toEmail: emailUser,
          subject: subject,
          content: subject,
        ),
      ],
      requestReadReceipt: false,
    );
    await $.pumpAndSettle();

    await threadRobot.openEmailWithSubject(subject);
    await $.pumpAndSettle();

    await emailRobot.tapSenderEmailAddress(emailUser);
    await $.pumpAndSettle();

    await emailAddressDialogRobot.tapCreateRuleWithThisEmailAddressButton(appLocalizations);
    await $.pumpAndTrySettle();
    await _expectRuleFilterCreatorViewVisible();
    await _expectConditionFieldContainEmailAddressCorrectly(emailUser);
  }

  Future<void> _expectRuleFilterCreatorViewVisible() async {
    await expectViewVisible($(RuleFilterCreatorView));
  }

  Future<void> _expectConditionFieldContainEmailAddressCorrectly(String emailAddress) async {
    expect(
      $(DefaultInputFieldWidget).which<DefaultInputFieldWidget>((widget) =>
        widget.textEditingController.text.contains(emailAddress) == true
      ),
      findsOneWidget,
    );
  }
}