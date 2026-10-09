import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/provisioning_label_scenario_mixin.dart';

class RenameOpenLabelScenario extends BaseTestScenario
    with ProvisioningLabelScenarioMixin {
  const RenameOpenLabelScenario(super.$, super.robots);

  static const _labelName = 'Rename open tag';
  static const _newLabelName = 'Renamed open tag';

  @override
  Future<void> runTestLogic() async {
    final appLocalizations = AppLocalizations();
    final mailboxMenuRobot = robots.mailboxMenuRobot();
    final threadRobot = robots.threadRobot();

    await provisionLabelsByDisplayNames([_labelName]);

    await threadRobot.openMailbox();
    await mailboxMenuRobot.label.openLabel(
      mailboxMenuRobot.labelItemByName(_labelName),
    );
    await threadRobot.openMailbox();
    await mailboxMenuRobot.label.openLabelContextMenu(
      mailboxMenuRobot.labelItemByName(_labelName),
    );
    await mailboxMenuRobot.label.tapLabelAction(appLocalizations.edit);
    await mailboxMenuRobot.label.enterLabelName(_newLabelName);
    await mailboxMenuRobot.label.tapSaveLabel();
    await threadRobot.openMailbox();

    await mailboxMenuRobot.assertion.expectLabelSelected(
      mailboxMenuRobot.labelItemByName(_newLabelName),
    );
  }
}
