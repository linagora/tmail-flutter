import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/core_robot.dart';
import '../../utils/wait_for_condition.dart';
import '../abstract/abstract_account_switcher_assertion_robot.dart';

class WebAccountSwitcherAssertionRobot extends CoreRobot
    implements AbstractAccountSwitcherAssertionRobot {
  WebAccountSwitcherAssertionRobot(super.$);

  ProviderContainer _appContainer() {
    final element = $.tester.element(find.byType(MaterialApp));
    return ProviderScope.containerOf(element, listen: false);
  }

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

  @override
  Future<void> expectMenuShowsDelegated(String ownerAddress) async {
    await $(AppLocalizations().delegatedToYou).waitUntilVisible();
    await $(ownerAddress).waitUntilVisible();
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
    await expectLoadingDialogGone();
    FocusManager.instance.primaryFocus?.unfocus();
    await $.pumpAndTrySettle();
  }

  @override
  Future<void> expectLoadingDialogVisible(String ownerAddress) async {
    await waitForCondition(
      () async {
        // Zero show-delay opens the dialog on the next frame after switchStarted.
        await $.pump();
        return $(const ValueKey(UiKeys.accountSwitchLoadingDialog))
            .evaluate()
            .isNotEmpty;
      },
      reason: 'account switch loading dialog visible',
    );
    // Owner is inside Text.rich spans. find.text(owner) does not match that.
    await $(const ValueKey(UiKeys.accountSwitchLoadingCancel))
        .waitUntilVisible();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey(UiKeys.accountSwitchLoadingDialog)),
        matching: find.textContaining(ownerAddress, findRichText: true),
      ),
      findsOneWidget,
      reason: 'loading dialog copy names $ownerAddress',
    );
  }

  @override
  Future<void> expectLoadingDialogGone() async {
    await waitForCondition(
      () => $(const ValueKey(UiKeys.accountSwitchLoadingDialog))
          .evaluate()
          .isEmpty,
      reason: 'account switch loading dialog closed',
    );
  }

  @override
  Future<void> expectCouldNotOpenToast(String ownerAddress) async {
    final message =
        AppLocalizations().couldNotOpenOwnerMailbox(ownerAddress);
    await waitForCondition(
      () => $(message).evaluate().isNotEmpty,
      reason: 'could not open mailbox toast visible',
    );
  }
}
