import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';

import '../account_switcher_robot.dart';
import 'mobile_account_switcher_assertion_robot.dart';

/// Compact switcher of the thread app bar.
class MobileAccountSwitcherRobot extends AccountSwitcherRobot {
  MobileAccountSwitcherRobot(PatrolIntegrationTester $)
      : super($, MobileAccountSwitcherAssertionRobot($));

  @override
  PatrolFinder get menu => $(LinagoraAccountSwitcher.menuKey);

  @override
  Future<void> openMenu() async {
    if (isMenuOpen) return;
    await $(LinagoraAccountSwitcher.chipKey).tap();
    await $.pumpAndTrySettle();
  }

  /// No Viewing banner on the compact switcher: picks `mine` in its menu.
  @override
  Future<void> leaveDelegatedMailbox() async {
    final session = appContainer().read(activeAccountProvider)?.session;
    if (session == null) throw StateError('no active session to leave');
    await selectByAddress(session.getOwnEmailAddressOrEmpty());
  }
}
