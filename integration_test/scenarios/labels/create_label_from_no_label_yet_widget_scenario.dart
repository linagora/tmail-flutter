import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/labels/presentation/models/label_action_type.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/no_label_yet_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/labels/choose_label_modal_robot.dart';
import '../../robots/labels/create_label_modal_robot.dart';
import '../../robots/thread_robot.dart';

class CreateLabelFromNoLabelYetWidgetScenario extends BaseTestScenario {
  const CreateLabelFromNoLabelYetWidgetScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');
    expect(emailUser, isNotEmpty, reason: 'BASIC_AUTH_EMAIL must be set');

    final threadRobot = ThreadRobot($);
    final chooseLabelModalRobot = ChooseLabelModalRobot($);
    final createLabelModalRobot = CreateLabelModalRobot($);

    await provisionEmail(
      [
        ProvisioningEmail(
          toEmail: emailUser,
          subject: 'Test email for create label from no-label widget',
          content: 'Content',
        ),
      ],
      requestReadReceipt: false,
    );
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    await threadRobot.longPressEmailWithSubject(
      'Test email for create label from no-label widget',
    );
    await $.pumpAndTrySettle();

    await threadRobot.tapLabelAsButton();
    await $.pumpAndTrySettle();

    await expectViewVisible($(NoLabelYetWidget));

    await chooseLabelModalRobot.tapCreateALabelButton();
    await $.pumpAndTrySettle();

    await expectViewVisible($(#create_new_label_modal));

    final uniqueSuffix = DateTime.now().microsecondsSinceEpoch;
    final newLabelName = 'Label from no-label widget $uniqueSuffix';
    await createLabelModalRobot.enterNewLabelName(newLabelName);
    await createLabelModalRobot.tapPositiveActionButton(LabelActionType.create);
    await $.pumpAndTrySettle();

    await expectViewVisible(
      $(find.text(AppLocalizations().createLabelSuccessfullyMessage(newLabelName))),
    );
    expect(chooseLabelModalRobot.isLabelListVisible, isTrue);
    await expectViewVisible($(newLabelName));
    expect($(NoLabelYetWidget).visible, isFalse);
  }
}
