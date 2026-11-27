import '../../base/base_test_scenario.dart';
import '../../mixin/delegation_workplace_scenario_mixin.dart';
import '../../robots/mobile/mobile_account_switcher_robot.dart';

/// Bob has alice's mailbox delegated (reset-server seed). Workplace web only.
class SwitchDelegatedMailboxCompactWorkplaceScenario extends BaseTestScenario
    with DelegationWorkplaceScenarioMixin {
  const SwitchDelegatedMailboxCompactWorkplaceScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    final viewport = robots.threadRobot().viewport;
    if (viewport == null) {
      throw StateError('Window resizing is not wired on this platform');
    }
    // Below the desktop breakpoint the thread app bar carries the chip.
    final compactSwitcher = MobileAccountSwitcherRobot($);

    await enableDelegationAndReturnToMailbox();

    await viewport.withCompactViewport(() async {
      await compactSwitcher.selectByAddress(
        DelegationWorkplaceScenarioMixin.ownerAddress,
      );
      await compactSwitcher.assertion.expectSwitchSettled(
        DelegationWorkplaceScenarioMixin.ownerAddress,
      );
      await compactSwitcher.assertion.expectViewing(
        DelegationWorkplaceScenarioMixin.ownerAddress,
      );
      await robots.commonRobot().waitForMailboxReady();

      await compactSwitcher.leaveDelegatedMailbox();
      await compactSwitcher.assertion.expectSwitcherOnMine();
    });
  }
}
