import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/provisioning_label_scenario_mixin.dart';

class DeleteOpenLabelScenario extends BaseTestScenario
    with ProvisioningLabelScenarioMixin {
  const DeleteOpenLabelScenario(super.$, super.robots);

  static const _labelName = 'Delete open tag';

  @override
  Future<void> runTestLogic() async {
    final appLocalizations = AppLocalizations();
    final mailboxMenuRobot = robots.mailboxMenuRobot();
    final threadRobot = robots.threadRobot();
    final label = mailboxMenuRobot.labelItemByName(_labelName);

    await provisionLabelsByDisplayNames([_labelName]);

    await threadRobot.openMailbox();
    await mailboxMenuRobot.label.openLabel(label);
    await threadRobot.openMailbox();
    await mailboxMenuRobot.assertion.expectLabelSelected(label);

    await mailboxMenuRobot.label.openLabelContextMenu(label);
    await mailboxMenuRobot.label.tapLabelAction(appLocalizations.delete);
    await mailboxMenuRobot.label.confirmDeleteLabel();

    await mailboxMenuRobot.assertion.expectSubfolderNotExist(label);
    await mailboxMenuRobot.assertion.expectMailboxSelected(
      mailboxMenuRobot.mailboxItemByExactName(
        appLocalizations.inboxMailboxDisplayName,
      ),
    );
  }
}
