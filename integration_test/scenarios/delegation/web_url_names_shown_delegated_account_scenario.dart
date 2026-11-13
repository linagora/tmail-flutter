import '../../base/base_test_scenario.dart';
import '../../mixin/delegation_standalone_scenario_mixin.dart';

/// Bob has alice's mailbox delegated (reset-server seed). Stand-alone web only.
class WebUrlNamesShownDelegatedAccountScenario extends BaseTestScenario
    with DelegationStandaloneScenarioMixin {
  const WebUrlNamesShownDelegatedAccountScenario(super.$, super.robots);

  static const _folderName = 'Sent';

  @override
  Future<void> runTestLogic() async {
    final switcher = accountSwitcher;

    await enableDelegationAndReturnToMailbox();
    await switcher.assertion.expectUrlNamesNoAccount();

    await switcher.selectByAddress(DelegationStandaloneScenarioMixin.ownerAddress);
    await switcher.assertion.expectViewing(DelegationStandaloneScenarioMixin.ownerAddress);
    await robots.commonRobot().waitForMailboxReady();
    await switcher.assertion.expectUrlNamesShownAccount();

    final mailboxMenu = robots.mailboxMenuRobot();
    await mailboxMenu.navigation.openFolder(mailboxMenu.mailboxItemByName(_folderName));
    await switcher.assertion.expectUrlNamesOpenedFolder();
    await switcher.assertion.expectUrlNamesShownAccount();

    await switcher.dismissViewingBanner();
    await switcher.assertion.expectSwitcherOnMine();
    await switcher.assertion.expectUrlNamesNoAccount();
  }
}
