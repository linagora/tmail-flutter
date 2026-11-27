import '../../base/base_test_scenario.dart';
import '../../mixin/delegation_standalone_scenario_mixin.dart';
import '../../robots/web/web_sign_in_email_link_robot.dart';

/// Bob has alice's mailbox delegated (reset-server seed). Stand-alone web only.
class OpenEmailLinkAfterSignInScenario extends BaseTestScenario
    with DelegationStandaloneScenarioMixin {
  const OpenEmailLinkAfterSignInScenario(super.$, super.robots);

  static const _settingsDelegationLink = '/settings?type=delegation';

  @override
  Future<void> runTestLogic() async {
    final switcher = accountSwitcher;

    await enableDelegationAndReturnToMailbox();
    final ownerMailboxLink = await _copyOwnerMailboxLink();

    await _signOutThenSignInFrom(ownerMailboxLink);
    await switcher.assertion.expectViewing(DelegationStandaloneScenarioMixin.ownerAddress);
    await switcher.assertion.expectUrlNamesShownAccount();

    await switcher.leaveDelegatedMailbox();
    await _signOutThenSignInFrom(_settingsDelegationLink);
    await robots.settingsRobot().delegationRobot.assertion.expectNoOneHasAccessToMyMailbox();
  }

  Future<String> _copyOwnerMailboxLink() async {
    final switcher = accountSwitcher;
    await switcher.selectByAddress(DelegationStandaloneScenarioMixin.ownerAddress);
    await switcher.assertion.expectUrlNamesShownAccount();
    final link = WebSignInEmailLinkRobot($).copyLocationLink();
    await switcher.leaveDelegatedMailbox();
    await switcher.assertion.expectSwitcherOnMine();
    return link;
  }

  Future<void> _signOutThenSignInFrom(String link) async {
    final mailboxMenu = robots.mailboxMenuRobot();
    await mailboxMenu.tapSignOut();
    await mailboxMenu.confirmSignOut();
    await WebSignInEmailLinkRobot($).openPastedLinkWhileSignedOut(link);
    await robots.loginRobot().loginWithBasicAuth(
          username: const String.fromEnvironment('USERNAME'),
          hostUrl: '',
          email: const String.fromEnvironment('BASIC_AUTH_EMAIL'),
          password: const String.fromEnvironment('PASSWORD'),
        );
  }
}
