import '../../base/base_test_scenario.dart';
import '../../mixin/delegation_standalone_scenario_mixin.dart';

/// Switch to owner, then return to mine via the avatar menu (not Viewing ✕).
class SwitchBackToMineViaAvatarMenuStandaloneScenario extends BaseTestScenario
    with DelegationStandaloneScenarioMixin {
  const SwitchBackToMineViaAvatarMenuStandaloneScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    final switcher = accountSwitcher;
    const owner = DelegationStandaloneScenarioMixin.ownerAddress;
    const mine = DelegationStandaloneScenarioMixin.ownAddress;

    await enableDelegationAndReturnToMailbox();

    await switcher.selectByAddress(owner);
    await switcher.assertion.expectSwitchSettled(owner);

    await switcher.openMenu();
    await switcher.assertion.expectMenuShowsDelegated(owner);
    await switcher.selectAddressWhenMenuOpen(mine);
    await switcher.assertion.expectSwitcherOnMine();
  }
}
