import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../account_switcher_assertion_robot.dart';

/// Web stand-alone avatar menu and its Viewing banner.
class WebAccountSwitcherAssertionRobot extends AccountSwitcherAssertionRobot {
  WebAccountSwitcherAssertionRobot(super.$);

  @override
  Future<void> expectSwitcherInactive() async {
    await $.pumpAndTrySettle();
    // Mailbox chrome must be up so findsNothing is not vacuously true.
    await $(const ValueKey(UiKeys.userAvatar)).waitUntilVisible();
    expect(
      find.byKey(const ValueKey(UiKeys.viewingOwnerBanner)),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey(UiKeys.accountSwitcherMenu)),
      findsNothing,
    );
  }

  @override
  Future<void> expectViewing(String ownerAddress) async {
    final label = AppLocalizations().viewingOwnerMailbox(ownerAddress);
    await $(const ValueKey(UiKeys.viewingOwnerBanner)).waitUntilVisible();
    await $(label).waitUntilVisible();
  }
}
