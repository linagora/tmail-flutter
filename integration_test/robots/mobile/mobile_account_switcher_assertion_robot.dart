import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';

import '../account_switcher_assertion_robot.dart';

/// Compact switcher of the thread app bar, which has no Viewing banner.
class MobileAccountSwitcherAssertionRobot
    extends AccountSwitcherAssertionRobot {
  MobileAccountSwitcherAssertionRobot(super.$);

  @override
  Future<void> expectSwitcherInactive() async {
    await $.pumpAndTrySettle();
    // Thread app bar must be up so findsNothing is not vacuously true.
    await $(const ValueKey(UiKeys.mobileMailboxMenuButton)).waitUntilVisible();
    expect(find.byKey(LinagoraAccountSwitcher.chipKey), findsNothing);
  }

  @override
  Future<void> expectViewing(String ownerAddress) async {
    await waitSwitchIdleOn(ownerAddress);
    await $(LinagoraAccountSwitcher.chipKey).waitUntilVisible();
  }
}
