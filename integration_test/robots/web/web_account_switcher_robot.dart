import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';

import '../account_switcher_robot.dart';
import 'web_account_switcher_assertion_robot.dart';

/// Web stand-alone avatar menu.
class WebAccountSwitcherRobot extends AccountSwitcherRobot {
  WebAccountSwitcherRobot(PatrolIntegrationTester $)
      : super($, WebAccountSwitcherAssertionRobot($));

  @override
  PatrolFinder get menu => $(const ValueKey(UiKeys.accountSwitcherMenu));

  @override
  Future<void> openMenu() async {
    if (isMenuOpen) return;
    await $(const ValueKey(UiKeys.userAvatar)).tap();
    await $.pumpAndTrySettle();
  }

  /// Taps ✕ on the Viewing banner.
  @override
  Future<void> leaveDelegatedMailbox() async {
    await $(const ValueKey(UiKeys.viewingOwnerBannerDismiss)).tap();
    await $.pumpAndTrySettle();
  }
}
