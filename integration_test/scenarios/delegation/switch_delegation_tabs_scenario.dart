import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/delegation_standalone_scenario_mixin.dart';

/// Bob has alice's mailbox delegated and delegates his own to no one (reset-server seed).
class SwitchDelegationTabsScenario extends BaseTestScenario
    with DelegationStandaloneScenarioMixin {
  const SwitchDelegationTabsScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    final settingsRobot = robots.settingsRobot();
    final delegationRobot = settingsRobot.delegationRobot;

    await enableDelegationAndReturnToMailbox();

    await robots.mailboxMenuRobot().openSetting();
    await settingsRobot.openSettingsDetail(AccountMenuItem.delegation);
    await delegationRobot.assertion.expectNoOneHasAccessToMyMailbox();

    await delegationRobot.openDelegatedToMeTab();
    await delegationRobot.assertion.expectDelegatedToMeListed(
      DelegationStandaloneScenarioMixin.ownerAddress,
    );
  }
}
