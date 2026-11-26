import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/delegation_standalone_scenario_mixin.dart';
import '../../utils/jmap/jmap_delegate_provisioner.dart';

/// Bob has given no one access yet and adds brian from Settings › Delegation.
class AddDelegateScenario extends BaseTestScenario
    with DelegationStandaloneScenarioMixin {
  const AddDelegateScenario(super.$, super.robots);

  static const delegateAddress = 'brian@example.com';

  @override
  Future<void> runTestLogic() async {
    addTearDown(JmapDelegateProvisioner().removeAll);
    final settingsRobot = robots.settingsRobot();
    final delegationRobot = settingsRobot.delegationRobot;

    await enableDelegationAndReturnToMailbox();

    await robots.mailboxMenuRobot().openSetting();
    await settingsRobot.openSettingsDetail(AccountMenuItem.delegation);
    await delegationRobot.assertion.expectNoOneHasAccessToMyMailbox();

    await delegationRobot.addDelegates.openFromEmptyCard();
    await delegationRobot.addDelegates.enterDelegateAddress(delegateAddress);
    await delegationRobot.addDelegates.tapSubmit();

    await delegationRobot.assertion.expectMyDelegatesListed([delegateAddress]);
  }
}
