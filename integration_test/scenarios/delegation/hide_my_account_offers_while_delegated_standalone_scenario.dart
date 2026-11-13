import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/delegation_standalone_scenario_mixin.dart';
import '../../robots/web/web_shown_account_offers_assertion_robot.dart';
import '../../utils/vacation_provisioner.dart';

/// Bob has alice's mailbox delegated (reset-server seed). Stand-alone web only.
class HideMyAccountOffersWhileDelegatedStandaloneScenario extends BaseTestScenario
    with DelegationStandaloneScenarioMixin {
  const HideMyAccountOffersWhileDelegatedStandaloneScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    final offers = WebShownAccountOffersAssertionRobot($);
    final mailboxMenuRobot = robots.mailboxMenuRobot();
    final trash = mailboxMenuRobot.mailboxItemByName(
      AppLocalizations().trashMailboxDisplayName,
    );

    await robots.commonRobot().waitForMailboxReady();
    await VacationProvisioner().provision(VacationResponse(
      isEnabled: true,
      fromDate: UTCDate(DateTime.now().subtract(const Duration(days: 1))),
    ));
    // Settings reads my vacation and hands it back to the mailbox on close.
    await enableDelegationAndReturnToMailbox();
    await offers.expectMyVacationBannerShown();
    await mailboxMenuRobot.navigation.openFolder(trash);
    await offers.expectRecoverDeletedMessagesOffered();

    await accountSwitcher.selectByAddress(DelegationStandaloneScenarioMixin.ownerAddress);
    await accountSwitcher.assertion.expectViewing(DelegationStandaloneScenarioMixin.ownerAddress);
    await robots.commonRobot().waitForMailboxReady();
    await offers.expectMyVacationBannerHidden();
    await mailboxMenuRobot.navigation.openFolder(trash);
    await offers.expectRecoverDeletedMessagesNotOffered();

    await robots.threadRobot().openComposer();
    final recipient = robots.composerRobot().recipient;
    await recipient.enterRecipient(PrefixEmailAddress.to, DelegationStandaloneScenarioMixin.ownAddress);
    await recipient.openFirstRecipientMenu(PrefixEmailAddress.to);
    await offers.expectRecipientMenuWithoutCreateRule();
  }
}
