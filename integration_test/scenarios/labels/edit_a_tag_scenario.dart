import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/provisioning_label_scenario_mixin.dart';
import '../../robots/labels/create_label_modal_robot.dart';
import '../../robots/labels/label_action_type_context_menu_robot.dart';
import '../../robots/labels/label_robot.dart';
import '../../robots/thread_robot.dart';

class EditATagScenario extends BaseTestScenario
    with ProvisioningLabelScenarioMixin {
  const EditATagScenario(super.$);

  @override
  Future<void> setupPreLogin() async {
    PlatformInfo.isIntegrationTesting = true;
  }

  @override
  Future<void> runTestLogic() async {
    final threadRobot = ThreadRobot($);
    final labelRobot = LabelRobot($);
    final labelActionTypeContextMenuRobot = LabelActionTypeContextMenuRobot($);
    final createLabelModalRobot = CreateLabelModalRobot($);
    final appLocalizations = AppLocalizations();

    await provisionLabelsByDisplayNames(['Edit Tag 1', 'Edit Tag 2']);
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    await threadRobot.openMailbox();
    await labelRobot.longPressLabelWithName('Edit Tag 1');
    await _expectLabelActionTypeContextMenuVisible();

    await labelActionTypeContextMenuRobot.selectActionByName(
      appLocalizations.edit,
    );
    await _expectEditLabelModalVisible();

    const newLabelName = 'New edit tag 1';
    await createLabelModalRobot.enterNewLabelName(newLabelName);
    await createLabelModalRobot.tapSaveButton();
    await _expectLabelWithNewNameUpdated(newLabelName);
  }

  Future<void> _expectLabelActionTypeContextMenuVisible() async {
    await expectViewVisible($(#label_action_type_context_menu));
  }

  Future<void> _expectEditLabelModalVisible() async {
    await expectViewVisible($(#edit_label_modal));
  }

  Future<void> _expectLabelWithNewNameUpdated(String name) async {
    await expectViewVisible($(name));
  }

  @override
  Future<void> disposeAfterTest() async {
    PlatformInfo.isIntegrationTesting = false;
  }
}
