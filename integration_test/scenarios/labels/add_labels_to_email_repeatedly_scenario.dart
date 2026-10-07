import 'package:flutter_test/flutter_test.dart';
import 'package:labels/labels.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/provisioning_label_scenario_mixin.dart';
import '../../models/provisioning_email.dart';
import '../../robots/abstract/abstract_email_robot.dart';

class AddLabelsToEmailRepeatedlyScenario extends BaseTestScenario
    with ProvisioningLabelScenarioMixin {
  const AddLabelsToEmailRepeatedlyScenario(super.$, super.robots);

  static const _subject = 'Add labels to email repeatedly';

  @override
  Future<void> runTestLogic() async {
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');
    expect(emailUser, isNotEmpty, reason: 'BASIC_AUTH_EMAIL must be set');

    final commonRobot = robots.commonRobot();
    final threadRobot = robots.threadRobot();
    final emailRobot = robots.emailRobot();

    // Labels are created through the dashboard controller, which needs the
    // account to be loaded first.
    await commonRobot.waitForMailboxReady();
    final labels = await provisionLabelsByDisplayNames(
      ['Repeat Tag 1', 'Repeat Tag 2', 'Repeat Tag 3'],
    );
    expect(labels.length, 3, reason: 'All labels must be provisioned');

    await commonRobot.provisionEmail(
      [
        ProvisioningEmail(
          toEmail: emailUser,
          subject: _subject,
          content: _subject,
        ),
      ],
      requestReadReceipt: false,
    );
    await $.pumpAndSettle();

    await threadRobot.openEmailWithSubject(_subject);

    for (final label in labels) {
      await _addLabelFromMoreMenu(emailRobot, label.safeDisplayName);
    }
  }

  Future<void> _addLabelFromMoreMenu(
    AbstractEmailRobot emailRobot,
    String labelDisplayName,
  ) async {
    await emailRobot.label.openLabelPicker();
    await emailRobot.assertion.expectLabelPickerVisible();

    await emailRobot.label.selectLabel(labelDisplayName);
    await emailRobot.assertion.expectLabelAddedToast(labelDisplayName);
  }
}
