import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/delegation_standalone_scenario_mixin.dart';
import '../../provisioning/delegation_revocation_provisioner.dart';

/// Bob has alice's mailbox delegated (reset-server seed). Stand-alone web and the Android and iOS app.
class LeaveRevokedDelegatedMailboxScenario extends BaseTestScenario
    with DelegationStandaloneScenarioMixin {
  const LeaveRevokedDelegatedMailboxScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    const ownerAddress = DelegationStandaloneScenarioMixin.ownerAddress;
    final switcher = accountSwitcher;

    await enableDelegationAndReturnToMailbox();
    await switcher.selectByAddress(ownerAddress);
    await switcher.assertion.expectViewing(ownerAddress);
    await robots.commonRobot().waitForMailboxReady();

    await const DelegationRevocationProvisioner().revoke(ownerAddress);
    await _openSentFolderOfShownMailbox();

    await switcher.assertion.expectAccessEndedToast(ownerAddress);
    await robots.commonRobot().waitForMailboxReady();
    await switcher.assertion.expectNoLongerOffers(ownerAddress);
    await switcher.assertion.expectSwitcherInactive();
  }

  /// The server answers accountNotFound for a folder of the revoked mailbox.
  Future<void> _openSentFolderOfShownMailbox() async {
    final mailboxMenuRobot = robots.mailboxMenuRobot();
    await robots.threadRobot().openMailbox();
    await mailboxMenuRobot.navigation.openFolder(
      mailboxMenuRobot.mailboxItemByName(AppLocalizations().sentMailboxDisplayName),
    );
  }
}
