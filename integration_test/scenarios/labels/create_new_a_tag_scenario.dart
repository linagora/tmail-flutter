import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/labels/presentation/models/label_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../robots/labels/create_label_modal_robot.dart';
import '../../robots/labels/label_robot.dart';
import '../../robots/thread_robot.dart';

class CreateNewATagScenario extends BaseTestScenario {
  const CreateNewATagScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    final threadRobot = ThreadRobot($);
    final labelRobot = LabelRobot($);
    final createLabelModalRobot = CreateLabelModalRobot($);

    await threadRobot.openMailbox();
    await labelRobot.tapCreateNewLabelButton();
    await $.pumpAndTrySettle();
    await _expectCreateNewLabelModalVisible();

    const newLabelName = 'Create new tag 1';
    const newLabelDescription = 'Description tag 1';
    await createLabelModalRobot.enterNewLabelName(newLabelName);
    await createLabelModalRobot.enterNewLabelDescription(newLabelDescription);
    await createLabelModalRobot.tapPositiveActionButton(LabelActionType.create);
    await $.pumpAndTrySettle();
    await _expectToastMessageCreateNewLabelSuccessVisible(newLabelName);
  }

  Future<void> _expectCreateNewLabelModalVisible() async {
    await expectViewVisible($(#create_new_label_modal));
  }

  Future<void> _expectToastMessageCreateNewLabelSuccessVisible(
    String labelName,
  ) async {
    await expectViewVisible(
      $(find
          .text(AppLocalizations().createLabelSuccessfullyMessage(labelName))),
    );
  }
}
