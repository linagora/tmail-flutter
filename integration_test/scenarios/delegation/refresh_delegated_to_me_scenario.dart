import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/delegation_standalone_scenario_mixin.dart';
import '../../utils/jmap/jmap_delegate_provisioner.dart';

/// Bob has alice's mailbox delegated (reset-server seed). Alice changes her
/// delegates on the server while Bob's app runs. Stand-alone web and the
/// Android and iOS app.
class RefreshDelegatedToMeScenario extends BaseTestScenario
    with DelegationStandaloneScenarioMixin {
  const RefreshDelegatedToMeScenario(super.$, super.robots);

  static const _ownerPassword = 'alice';

  @override
  Future<void> runTestLogic() async {
    const ownerAddress = DelegationStandaloneScenarioMixin.ownerAddress;
    final owner = JmapDelegateProvisioner.signedInAs(
      ownerAddress,
      _ownerPassword,
    );
    final delegationRobot = robots.settingsRobot().delegationRobot;

    await enableDelegationAndReturnToMailbox();

    await owner.removeAll();
    await _openDelegatedToMe();
    await delegationRobot.assertion.expectNothingDelegatedToMe();
    await _closeSettings();
    await accountSwitcher.assertion.expectNoLongerOffers(ownerAddress);
    await accountSwitcher.assertion.expectSwitcherInactive();

    await owner.add({DelegationStandaloneScenarioMixin.ownAddress});
    await _openDelegatedToMe();
    await delegationRobot.assertion.expectDelegatedToMeListed(ownerAddress);
    await _closeSettings();
    await accountSwitcher.openMenu();
    await accountSwitcher.assertion.expectMenuShowsDelegated(ownerAddress);
    await accountSwitcher.selectAddressWhenMenuOpen(ownerAddress);
    await accountSwitcher.assertion.expectSwitchSettled(ownerAddress);
  }

  Future<void> _openDelegatedToMe() async {
    await robots.mailboxMenuRobot().openSetting();
    await robots
        .settingsRobot()
        .openSettingsDetail(AccountMenuItem.delegation);
    await robots.settingsRobot().delegationRobot.openDelegatedToMeTab();
  }

  Future<void> _closeSettings() async {
    await robots.settingsRobot().closeSettingsFromDetail();
    await robots.commonRobot().waitForMailboxReady();
  }
}
