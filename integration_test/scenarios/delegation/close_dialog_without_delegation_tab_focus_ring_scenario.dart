import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/delegation_standalone_scenario_mixin.dart';

/// Bob has alice's mailbox delegated (reset-server seed).
class CloseDialogWithoutDelegationTabFocusRingScenario extends BaseTestScenario
    with DelegationStandaloneScenarioMixin {
  const CloseDialogWithoutDelegationTabFocusRingScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    const ownerAddress = DelegationStandaloneScenarioMixin.ownerAddress;
    final settingsRobot = robots.settingsRobot();
    final delegationRobot = settingsRobot.delegationRobot;

    await enableDelegationAndReturnToMailbox();

    await robots.mailboxMenuRobot().openSetting();
    await settingsRobot.openSettingsDetail(AccountMenuItem.delegation);
    await delegationRobot.openDelegatedToMeTab();
    await delegationRobot.assertion.expectDelegatedToMeListed(ownerAddress);

    await delegationRobot.tapRemoveAccess(ownerAddress);
    await delegationRobot.cancelRemoveAccessWithMouse();

    await delegationRobot.assertion.expectDelegatedToMeListed(ownerAddress);
    delegationRobot.assertion.expectNoTabFocusRing();
  }
}
