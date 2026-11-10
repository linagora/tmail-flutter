import '../../base/base_test_scenario.dart';
import '../../mixin/delegation_standalone_scenario_mixin.dart';

/// Cancel mid-switch → "Couldn't open [Owner]'s mailbox" toast.
///
/// Server-side failure is hard to force in Patrol web. Cancelling an in-flight
/// switch yields [AccountSwitchCancelled], which uses the same toast copy as
/// failed / timed-out opens (unit-tested in account_switch_failure_toast_test).
///
/// Patrol web scripts set `ACCOUNT_SWITCH_LOADING_SHOW_DELAY_MS=0` so the
/// dialog appears even when local James finishes the load quickly.
class SwitchDelegatedMailboxFailureToastStandaloneScenario
    extends BaseTestScenario with DelegationStandaloneScenarioMixin {
  const SwitchDelegatedMailboxFailureToastStandaloneScenario(
    super.$,
    super.robots,
  );

  @override
  Future<void> runTestLogic() async {
    final switcher = accountSwitcher;
    const owner = DelegationStandaloneScenarioMixin.ownerAddress;

    await enableDelegationAndReturnToMailbox();

    await switcher.selectByAddressAwaitingLoading(owner);
    // cancelInFlightSwitch taps Cancel when painted, else cancels the notifier
    // while still inside showDelay (zero-delay builds show sync, so Cancel wins).
    await switcher.cancelInFlightSwitch();
    await switcher.assertion.expectCouldNotOpenToast(owner);
    await switcher.assertion.expectSwitcherOnMine();
  }
}
