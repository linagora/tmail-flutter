import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/delegation_standalone_scenario_mixin.dart';
import '../../utils/jmap/jmap_delegate_provisioner.dart';

/// Bob has given brian access to his mailbox and takes it back from Settings › Delegation.
class RemoveDelegateScenario extends BaseTestScenario
    with DelegationStandaloneScenarioMixin {
  const RemoveDelegateScenario(super.$, super.robots);

  static const delegateAddress = 'brian@example.com';

  @override
  Future<void> runTestLogic() async {
    final provisioner = JmapDelegateProvisioner();
    addTearDown(provisioner.removeAll);
    await provisioner.add({delegateAddress});
    final settingsRobot = robots.settingsRobot();
    final delegationRobot = settingsRobot.delegationRobot;

    await enableDelegationAndReturnToMailbox();

    await robots.mailboxMenuRobot().openSetting();
    await settingsRobot.openSettingsDetail(AccountMenuItem.delegation);
    await delegationRobot.assertion.expectMyDelegatesListed([delegateAddress]);

    await delegationRobot.tapRemoveAccess(delegateAddress);
    await delegationRobot.confirmRemoveDelegate();

    await delegationRobot.assertion.expectNoOneHasAccessToMyMailbox();
  }
}
