import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/core_robot.dart';
import '../abstract/abstract_workplace_account_switcher_assertion_robot.dart';
import 'account_switch_robot_mixin.dart';

class WebWorkplaceAccountSwitcherAssertionRobot extends CoreRobot
    with AccountSwitchRobotMixin
    implements AbstractWorkplaceAccountSwitcherAssertionRobot {
  WebWorkplaceAccountSwitcherAssertionRobot(super.$);

  @override
  Future<void> expectChipHidden() async {
    await $.pumpAndTrySettle();
    // Workplace settings stay reachable while the chip is hidden.
    await $(const ValueKey(UiKeys.workplaceSettingsButton)).waitUntilVisible();
    expect(find.byKey(LinagoraAccountSwitcher.chipKey), findsNothing);
  }

  @override
  Future<void> expectViewing(String ownerAddress) async {
    final label = AppLocalizations().viewingOwnerMailbox(ownerAddress);
    await $(LinagoraAccountSwitcher.chipKey).waitUntilVisible();
    await $(label).waitUntilVisible();
  }

  @override
  Future<void> expectMenuShowsDelegated(String ownerAddress) async {
    await $(AppLocalizations().delegatedToYou).waitUntilVisible();
    await $(ownerAddress).waitUntilVisible();
  }

  @override
  Future<void> expectSwitchSettled(String ownerAddress) async {
    await waitSwitchIdleOn(ownerAddress);
    await waitLoadingDialogGone();
    await expectViewing(ownerAddress);
  }

  @override
  Future<void> expectSwitcherOnMine() async {
    await waitSwitchIdleOnMine();
  }
}
