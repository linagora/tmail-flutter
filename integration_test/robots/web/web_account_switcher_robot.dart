import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';

import '../../base/core_robot.dart';
import '../../utils/wait_for_condition.dart';
import '../abstract/abstract_account_switcher_assertion_robot.dart';
import '../abstract/abstract_account_switcher_robot.dart';
import 'account_switch_robot_mixin.dart';
import 'web_account_switcher_assertion_robot.dart';

/// Web stand-alone avatar menu.
class WebAccountSwitcherRobot extends CoreRobot
    with AccountSwitchRobotMixin
    implements AbstractAccountSwitcherRobot {
  @override
  final AbstractAccountSwitcherAssertionRobot assertion;

  WebAccountSwitcherRobot(super.$)
      : assertion = WebAccountSwitcherAssertionRobot($);

  bool get _isMenuOpen =>
      $(const ValueKey(UiKeys.accountSwitcherMenu)).evaluate().isNotEmpty;

  Future<void> _tapMenuItem(
    String emailAddress, {
    SettlePolicy? settlePolicy,
  }) async {
    final itemKey = LinagoraAccountMenu.itemKey(accountIdForAddress(emailAddress));
    final row = $(const ValueKey(UiKeys.accountSwitcherMenu)).$(itemKey);
    if (settlePolicy == null) {
      await row.tap();
    } else {
      await row.tap(settlePolicy: settlePolicy);
    }
  }

  @override
  Future<void> openMenu() async {
    if (_isMenuOpen) return;
    await $(const ValueKey(UiKeys.userAvatar)).tap();
    await $.pumpAndTrySettle();
  }

  @override
  Future<void> selectByAddress(String emailAddress) async {
    await openMenu();
    await selectAddressWhenMenuOpen(emailAddress);
  }

  @override
  Future<void> selectAddressWhenMenuOpen(String emailAddress) async {
    await _tapMenuItem(emailAddress);
    await $.pumpAndTrySettle();
  }

  @override
  Future<void> selectByAddressAwaitingLoading(String emailAddress) async {
    await openMenu();
    // Keep the switch in flight: trySettle would wait out showDelay + load and
    // hide the loading dialog before the assertion runs.
    await _tapMenuItem(emailAddress, settlePolicy: SettlePolicy.noSettle);
    await assertion.expectLoadingDialogVisible(emailAddress);
  }

  @override
  Future<void> tapCancelOnLoadingDialog() async {
    await $(
      const ValueKey(UiKeys.accountSwitchLoadingCancel),
    ).tap(settlePolicy: SettlePolicy.noSettle);
    await assertion.expectLoadingDialogGone();
  }

  @override
  Future<void> cancelInFlightSwitch() async {
    await waitForCondition(
      () => appContainer().read(accountSwitchProvider).isSwitching,
      reason: 'account switch in flight',
    );

    final cancelButton = $(
      const ValueKey(UiKeys.accountSwitchLoadingCancel),
    );
    if (cancelButton.evaluate().isNotEmpty) {
      await cancelButton.tap(settlePolicy: SettlePolicy.noSettle);
    } else {
      // Still inside SwitchLoadingDialogTiming.showDelay — same cancel as the
      // dialog Cancel / Android back interceptor.
      appContainer().read(accountSwitchProvider.notifier).cancel();
      await $.pump();
    }
    await assertion.expectLoadingDialogGone();
  }

  @override
  Future<void> dismissViewingBanner() async {
    await $(const ValueKey(UiKeys.viewingOwnerBannerDismiss)).tap();
    await $.pumpAndTrySettle();
  }
}
