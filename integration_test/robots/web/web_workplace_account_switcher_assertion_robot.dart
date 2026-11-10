import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/core_robot.dart';
import '../../utils/wait_for_condition.dart';
import '../abstract/abstract_workplace_account_switcher_assertion_robot.dart';

class WebWorkplaceAccountSwitcherAssertionRobot extends CoreRobot
    implements AbstractWorkplaceAccountSwitcherAssertionRobot {
  WebWorkplaceAccountSwitcherAssertionRobot(super.$);

  ProviderContainer _appContainer() {
    final element = $.tester.element(find.byType(MaterialApp));
    return ProviderScope.containerOf(element, listen: false);
  }

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
    await waitForCondition(
      () {
        final container = _appContainer();
        if (container.read(accountSwitchProvider).isSwitching) return false;
        final active = container.read(activeAccountProvider);
        return active != null && active.ownerEmailAddress == ownerAddress;
      },
      reason: 'switched to $ownerAddress and idle',
    );
    await waitForCondition(
      () => $(const ValueKey(UiKeys.accountSwitchLoadingDialog))
          .evaluate()
          .isEmpty,
      reason: 'account switch loading dialog closed',
    );
    await expectViewing(ownerAddress);
    FocusManager.instance.primaryFocus?.unfocus();
    await $.pumpAndTrySettle();
  }

  @override
  Future<void> expectSwitcherOnMine() async {
    await waitForCondition(
      () {
        final container = _appContainer();
        final active = container.read(activeAccountProvider);
        return active != null &&
            !active.isDelegated &&
            !container.read(accountSwitchProvider).isSwitching;
      },
      reason: 'showing mine and switch idle',
    );
  }
}
