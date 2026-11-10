import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/from_composer_drop_down_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/delegation_standalone_scenario_mixin.dart';
import '../../utils/wait_for_condition.dart';

/// Bob has alice's mailbox delegated (reset-server seed). Stand-alone web only.
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
    await _waitForIdentityEmail(
      DelegationStandaloneScenarioMixin.ownerAddress,
    );

    await robots.threadRobot().openComposer();
    await $(const ValueKey('prefix_to_recipient_from_button')).tap();
    await $(FromComposerDropDownWidget).waitUntilVisible();
    await waitForCondition(
      () => $(FromComposerDropDownWidget)
          .which<FromComposerDropDownWidget>(
            (widget) =>
                widget.itemSelected?.email ==
                DelegationStandaloneScenarioMixin.ownerAddress,
          )
          .evaluate()
          .isNotEmpty,
      reason:
          'composer From selection is ${DelegationStandaloneScenarioMixin.ownerAddress}',
    );
    await $(const ValueKey(UiKeys.closeComposerButton)).tap();
    await $.pumpAndTrySettle();

    await switcher.dismissViewingBanner();
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
