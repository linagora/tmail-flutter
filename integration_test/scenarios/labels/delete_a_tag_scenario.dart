import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/labels/label_list_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/provisioning_label_scenario_mixin.dart';
import '../../robots/confirm_dialog_robot.dart';
import '../../robots/labels/label_action_type_context_menu_robot.dart';
import '../../robots/labels/label_robot.dart';
import '../../robots/thread_robot.dart';

class DeleteATagScenario extends BaseTestScenario
    with ProvisioningLabelScenarioMixin {
  const DeleteATagScenario(super.$);

  @override
  Future<void> setupPreLogin() async {
    PlatformInfo.isIntegrationTesting = true;
  }

  @override
  Future<void> runTestLogic() async {
    final threadRobot = ThreadRobot($);
    final labelRobot = LabelRobot($);
    final labelActionTypeContextMenuRobot = LabelActionTypeContextMenuRobot($);
    final confirmDialogRobot = ConfirmDialogRobot($);
    final appLocalizations = AppLocalizations();

    await provisionLabelsByDisplayNames(['Delete Tag 1', 'Delete Tag 2']);
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    await threadRobot.openMailbox();
    await labelRobot.longPressLabelWithName('Delete Tag 1');
    await _expectLabelActionTypeContextMenuVisible();

    await labelActionTypeContextMenuRobot.selectActionByName(
      appLocalizations.delete,
    );
    await _expectDeleteLabelConfirmDialogVisible();

    await confirmDialogRobot.selectActionByName(appLocalizations.delete);
    await $.pumpAndSettle(duration: const Duration(seconds: 1));
    await _expectLabelDeletedByName('Delete Tag 1');
  }

  Future<void> _expectLabelActionTypeContextMenuVisible() async {
    await expectViewVisible($(#label_action_type_context_menu));
  }

  Future<void> _expectDeleteLabelConfirmDialogVisible() async {
    await expectViewVisible($(#confirm_dialog_delete_label));
  }

  Future<void> _expectLabelDeletedByName(String name) async {
    await expectViewInvisible($(LabelListView).$(name));
  }

  @override
  Future<void> disposeAfterTest() async {
    PlatformInfo.isIntegrationTesting = false;
  }
}
