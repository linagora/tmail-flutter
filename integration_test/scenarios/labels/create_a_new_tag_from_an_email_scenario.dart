import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/labels/presentation/models/label_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/provisioning_label_scenario_mixin.dart';
import '../../models/provisioning_email.dart';
import '../../robots/email_robot.dart';
import '../../robots/labels/add_label_modal_robot.dart';
import '../../robots/labels/create_label_modal_robot.dart';
import '../../robots/thread_robot.dart';

class CreateANewTagFromAnEmailScenario extends BaseTestScenario
    with ProvisioningLabelScenarioMixin {
  const CreateANewTagFromAnEmailScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');
    expect(emailUser, isNotEmpty, reason: 'BASIC_AUTH_EMAIL must be set');

    const subject = 'Create new label from email';

    final threadRobot = ThreadRobot($);
    final emailRobot = EmailRobot($);
    final addLabelModalRobot = AddLabelModalRobot($);
    final createLabelModalRobot = CreateLabelModalRobot($);

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
    await emailRobot.tapEmailDetailedMoreButton();
    await _expectEmailDetailedLabelAsOptionVisible();

    await emailRobot.tapEmailDetailedLabelAsOptionInContextMenu();
    await _expectAddLabelModalVisible();

    await addLabelModalRobot.tapCreateANewLabel();
    await _expectCreateNewLabelModalVisible();

    const newLabelName = 'New Label 1';
    await createLabelModalRobot.enterNewLabelName(newLabelName);
    await createLabelModalRobot.tapPositiveActionButton(LabelActionType.create);
    await _expectLabelAsToEmailToastMessageSuccessVisible(
      AppLocalizations().addLabelToEmailSuccessfullyMessage(newLabelName),
    );
  }

  Future<void> _expectEmailDetailedLabelAsOptionVisible() async {
    await expectViewVisible($(#labelAs_action));
  }

  Future<void> _expectAddLabelModalVisible() async {
    await expectViewVisible($(#add_label_to_email_modal));
  }

  Future<void> _expectCreateNewLabelModalVisible() async {
    await expectViewVisible($(#create_new_label_modal));
  }

  Future<void> _expectLabelAsToEmailToastMessageSuccessVisible(String name) async {
    await expectViewVisible($(find.text(name)));
  }
}
