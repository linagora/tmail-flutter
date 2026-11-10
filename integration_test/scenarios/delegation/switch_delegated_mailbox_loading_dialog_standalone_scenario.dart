import '../../base/base_test_scenario.dart';
import '../../mixin/delegation_standalone_scenario_mixin.dart';

/// Asserts the switch loading dialog (and Cancel) appear while switching.
class SwitchDelegatedMailboxLoadingDialogStandaloneScenario
    extends BaseTestScenario with DelegationStandaloneScenarioMixin {
  const SwitchDelegatedMailboxLoadingDialogStandaloneScenario(
    super.$,
    super.robots,
  );

  @override
  Future<void> runTestLogic() async {
    final switcher = accountSwitcher;
    const owner = DelegationStandaloneScenarioMixin.ownerAddress;

    await enableDelegationAndReturnToMailbox();

    await switcher.selectByAddressAwaitingLoading(owner);
    await switcher.assertion.expectLoadingDialogVisible(owner);
    // Let the switch finish. Dialog must dismiss once idle.
    await switcher.assertion.expectSwitchSettled(owner);
  }
}
