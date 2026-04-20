import 'package:flutter_test/flutter_test.dart';
import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/labels/presentation/models/label_action_type.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/no_label_yet_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/labels/label_list_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/provisioning_label_scenario_mixin.dart';
import '../../robots/labels/choose_label_modal_robot.dart';
import '../../robots/labels/create_label_modal_robot.dart';
import '../../robots/thread_robot.dart';

class CreateLabelFromChooseLabelModalWithExistingLabelsScenario
    extends BaseTestScenario with ProvisioningLabelScenarioMixin {
  const CreateLabelFromChooseLabelModalWithExistingLabelsScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');
    expect(emailUser, isNotEmpty, reason: 'BASIC_AUTH_EMAIL must be set');

    final threadRobot = ThreadRobot($);
    final chooseLabelModalRobot = ChooseLabelModalRobot($);
    final createLabelModalRobot = CreateLabelModalRobot($);

    final labels = await provisionLabelsByDisplayNames(['Existing Label 1']);
    await $.pumpAndSettle();
    expect(labels, isNotEmpty, reason: 'Provisioning label failed');

    final existingLabel = labels.first;

    await provisionEmail(
      buildEmailsForLabel(
        label: existingLabel,
        toEmail: emailUser,
        count: 1,
      ),
      requestReadReceipt: false,
    );
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    await threadRobot.openMailbox();
    await expectViewVisible($(LabelListView));
    await mobileBack($);

    await threadRobot.longPressEmailWithSubject(
      'Email 1 subject ${existingLabel.safeDisplayName}',
    );
    await $.pumpAndTrySettle();

    await threadRobot.tapLabelAsButton();
    await $.pumpAndTrySettle();

    expect(chooseLabelModalRobot.isLabelListVisible, isTrue);
    expect($(NoLabelYetWidget).visible, isFalse);
    await expectViewVisible($(find.text(AppLocalizations().createALabel)));

    await chooseLabelModalRobot.tapCreateALabelButton();
    await $.pumpAndTrySettle();

    await expectViewVisible($(#create_new_label_modal));

    final uniqueSuffix = DateTime.now().microsecondsSinceEpoch;
    final newLabelName = 'New label from modal $uniqueSuffix';
    await createLabelModalRobot.enterNewLabelName(newLabelName);
    await createLabelModalRobot.tapPositiveActionButton(LabelActionType.create);
    await $.pumpAndTrySettle();

    await expectViewVisible(
      $(find.text(AppLocalizations().createLabelSuccessfullyMessage(newLabelName))),
    );
    await expectViewVisible($(newLabelName));
  }
}
