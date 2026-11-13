import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/from_composer_drop_down_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/delegation_workplace_scenario_mixin.dart';
import '../../utils/wait_for_condition.dart';

/// Bob has alice's mailbox delegated (reset-server seed). Workplace web only.
class SwitchDelegatedMailboxWorkplaceScenario extends BaseTestScenario
    with DelegationWorkplaceScenarioMixin {
  const SwitchDelegatedMailboxWorkplaceScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    final switcher = workplaceSwitcher;

    await enableDelegationAndReturnToMailbox();

    await switcher.assertion.expectViewing(
      DelegationWorkplaceScenarioMixin.ownAddress,
    );
    await switcher.openMenu();
    await switcher.assertion.expectMenuShowsDelegated(
      DelegationWorkplaceScenarioMixin.ownerAddress,
    );
    await switcher.selectAddressWhenMenuOpen(
      DelegationWorkplaceScenarioMixin.ownerAddress,
    );
    await switcher.assertion.expectSwitchSettled(
      DelegationWorkplaceScenarioMixin.ownerAddress,
    );
    await robots.commonRobot().waitForMailboxReady();
    await _waitForIdentityEmail(
      DelegationWorkplaceScenarioMixin.ownerAddress,
    );

    await robots.threadRobot().openComposer();
    await $(const ValueKey('prefix_to_recipient_from_button')).tap();
    await $(FromComposerDropDownWidget).waitUntilVisible();
    await waitForCondition(
      () => $(FromComposerDropDownWidget)
          .which<FromComposerDropDownWidget>(
            (widget) =>
                widget.itemSelected?.email ==
                DelegationWorkplaceScenarioMixin.ownerAddress,
          )
          .evaluate()
          .isNotEmpty,
      reason:
          'composer From selection is ${DelegationWorkplaceScenarioMixin.ownerAddress}',
    );
    await $(const ValueKey(UiKeys.closeComposerButton)).tap();
    await $.pumpAndTrySettle();

    await switcher.selectByAddress(
      DelegationWorkplaceScenarioMixin.ownAddress,
    );
    await switcher.assertion.expectSwitchSettled(
      DelegationWorkplaceScenarioMixin.ownAddress,
    );
    await switcher.assertion.expectSwitcherOnMine();
  }

  Future<void> _waitForIdentityEmail(String email) async {
    await waitForCondition(
      () {
        final dashboard = Get.find<MailboxDashBoardController>();
        return dashboard.listIdentities
            .any((identity) => identity.email == email);
      },
      reason: 'dashboard identities include $email',
    );
  }
}
