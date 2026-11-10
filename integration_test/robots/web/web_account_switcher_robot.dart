import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/delegation/domain/extensions/session_delegation_extension.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';

import '../../base/core_robot.dart';
import '../../utils/wait_for_condition.dart';
import '../abstract/abstract_account_switcher_assertion_robot.dart';
import '../abstract/abstract_account_switcher_robot.dart';
import 'web_account_switcher_assertion_robot.dart';

/// Web stand-alone avatar menu.
class WebAccountSwitcherRobot extends CoreRobot
    implements AbstractAccountSwitcherRobot {
  @override
  final AbstractAccountSwitcherAssertionRobot assertion;

  WebAccountSwitcherRobot(super.$)
      : assertion = WebAccountSwitcherAssertionRobot($);

  bool get _isMenuOpen =>
      $(const ValueKey(UiKeys.accountSwitcherMenu)).evaluate().isNotEmpty;

  ProviderContainer _appContainer() {
    final element = $.tester.element(find.byType(MaterialApp));
    return ProviderScope.containerOf(element, listen: false);
  }

  AccountId _accountIdForAddress(String emailAddress) {
    final session = _appContainer().read(activeAccountProvider)?.session;
    if (session == null) {
      throw StateError('no active session for account switcher select');
    }
    if (session.getOwnEmailAddressOrEmpty() == emailAddress) {
      return session.accountId;
    }
    for (final entry in session.delegatedAccounts) {
      if (entry.value.name.value == emailAddress) return entry.key;
    }
    throw StateError('no account listed for $emailAddress');
  }

  Future<void> _tapMenuItem(
    String emailAddress, {
    SettlePolicy? settlePolicy,
  }) async {
    final itemKey = LinagoraAccountMenu.itemKey(_accountIdForAddress(emailAddress));
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
      () => _appContainer().read(accountSwitchProvider).isSwitching,
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
      _appContainer().read(accountSwitchProvider.notifier).cancel();
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
