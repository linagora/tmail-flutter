import '../../base/base_test_scenario.dart';
import '../../mixin/delegation_standalone_scenario_mixin.dart';

/// Bob has alice's mailbox delegated (reset-server seed). Stand-alone web and the Android and iOS app.
class SwitchDelegatedMailboxStandaloneScenario extends BaseTestScenario
    with DelegationStandaloneScenarioMixin {
  const SwitchDelegatedMailboxStandaloneScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    final switcher = accountSwitcher;

    await enableDelegationAndReturnToMailbox();

    await switcher.openMenu();
    await switcher.assertion.expectMenuShowsDelegated(
      DelegationStandaloneScenarioMixin.ownerAddress,
    );
    // Menu is already open. selectByAddress must not re-tap the avatar (the
    // dismiss barrier makes userAvatar not hit-testable while the menu is up).
    await switcher.selectAddressWhenMenuOpen(
      DelegationStandaloneScenarioMixin.ownerAddress,
    );
    await switcher.assertion.expectViewing(
      DelegationStandaloneScenarioMixin.ownerAddress,
    );
    await robots.commonRobot().waitForMailboxReady();
    await switcher.assertion.expectShownIdentitiesInclude(
      DelegationStandaloneScenarioMixin.ownerAddress,
    );

    final composer = robots.composerRobot();
    await robots.threadRobot().openComposer();
    await composer.recipient.openFromField();
    await composer.recipient.assertion.expectFromSelected(
      DelegationStandaloneScenarioMixin.ownerAddress,
    );
    await composer.tapCloseComposer();
    await composer.expectComposerClosedDiscardingChanges();

    await switcher.leaveDelegatedMailbox();
    await switcher.assertion.expectSwitcherOnMine();
  }
}
