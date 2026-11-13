import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

import '../../base/core_robot.dart';
import '../../utils/wait_for_condition.dart';
import '../abstract/abstract_account_switcher_assertion_robot.dart';
import 'account_switch_robot_mixin.dart';

class WebAccountSwitcherAssertionRobot extends CoreRobot
    with AccountSwitchRobotMixin
    implements AbstractAccountSwitcherAssertionRobot {
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

  @override
  Future<void> expectMenuShowsDelegated(String ownerAddress) async {
    await $(AppLocalizations().delegatedToYou).waitUntilVisible();
    await $(ownerAddress).waitUntilVisible();
  }

  @override
  Future<void> expectSwitcherOnMine() async {
    await waitSwitchIdleOnMine();
  }

  @override
  Future<void> expectSwitchSettled(String ownerAddress) async {
    await waitSwitchIdleOn(ownerAddress);
    await expectLoadingDialogGone();
    FocusManager.instance.primaryFocus?.unfocus();
    await $.pumpAndTrySettle();
  }

  @override
  Future<void> expectShownIdentitiesInclude(String email) async {
    await waitForCondition(
      () => Get.find<MailboxDashBoardController>()
          .listIdentities
          .any((identity) => identity.email == email),
      reason: 'dashboard identities include $email',
    );
  }

  @override
  Future<void> expectUrlNamesShownAccount() async {
    await waitForCondition(
      () {
        final active = appContainer().read(activeAccountProvider);
        return active != null &&
            active.isDelegated &&
            _urlAccount() == active.accountId.id.value;
      },
      reason: 'the location bar names the shown delegated account',
    );
  }

  @override
  Future<void> expectUrlNamesNoAccount() async {
    await waitForCondition(
      () => _urlAccount() == null,
      reason: 'the location bar names no account',
    );
  }

  @override
  Future<void> expectUrlNamesOpenedFolder() async {
    await waitForCondition(
      () => Uri.base.queryParameters[RouteUtils.paramContext] != null,
      reason: 'the location bar names the opened folder',
    );
  }

  String? _urlAccount() => Uri.base.queryParameters[RouteUtils.paramAccount];

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
  Future<void> expectLoadingDialogGone() => waitLoadingDialogGone();

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
