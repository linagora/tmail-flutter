import 'package:flutter_test/flutter_test.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';

import '../../base/core_robot.dart';
import '../abstract/abstract_workplace_account_switcher_assertion_robot.dart';
import '../abstract/abstract_workplace_account_switcher_robot.dart';
import 'account_switch_robot_mixin.dart';
import 'web_workplace_account_switcher_assertion_robot.dart';

/// Web Workplace account-switcher chip (#4977 §8).
class WebWorkplaceAccountSwitcherRobot extends CoreRobot
    with AccountSwitchRobotMixin
    implements AbstractWorkplaceAccountSwitcherRobot {
  @override
  final AbstractWorkplaceAccountSwitcherAssertionRobot assertion;

  WebWorkplaceAccountSwitcherRobot(super.$)
      : assertion = WebWorkplaceAccountSwitcherAssertionRobot($);

  bool get _isMenuOpen =>
      $(LinagoraAccountSwitcher.menuKey).evaluate().isNotEmpty;

  @override
  Future<void> openMenu() async {
    if (_isMenuOpen) return;
    await $(LinagoraAccountSwitcher.chipKey).tap();
    await $.pumpAndTrySettle();
  }

  @override
  Future<void> selectByAddress(String emailAddress) async {
    await openMenu();
    await selectAddressWhenMenuOpen(emailAddress);
  }

  @override
  Future<void> selectAddressWhenMenuOpen(String emailAddress) async {
    final itemKey = LinagoraAccountMenu.itemKey(accountIdForAddress(emailAddress));
    await $(LinagoraAccountSwitcher.menuKey).$(itemKey).tap();
    await $.pumpAndTrySettle();
  }
}
