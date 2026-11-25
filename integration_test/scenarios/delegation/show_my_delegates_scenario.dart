import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/delegation_standalone_scenario_mixin.dart';
import '../../utils/jmap/jmap_delegate_provisioner.dart';

/// Bob has already given brian and charlotte access to his mailbox.
class ShowMyDelegatesScenario extends BaseTestScenario
    with DelegationStandaloneScenarioMixin {
  const ShowMyDelegatesScenario(super.$, super.robots);

  static const delegateAddresses = ['brian@example.com', 'charlotte@example.com'];

  @override
  Future<void> runTestLogic() async {
    final provisioner = JmapDelegateProvisioner();
    addTearDown(provisioner.removeAll);
    await provisioner.add(delegateAddresses.toSet());
    final settingsRobot = robots.settingsRobot();

    await enableDelegationAndReturnToMailbox();

    await robots.mailboxMenuRobot().openSetting();
    await settingsRobot.openSettingsDetail(AccountMenuItem.delegation);
    await settingsRobot.delegationRobot.assertion.expectMyDelegatesListed(delegateAddresses);
  }
}
