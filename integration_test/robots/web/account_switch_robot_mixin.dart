import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/delegation/domain/extensions/session_delegation_extension.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';

import '../../base/core_robot.dart';
import '../../utils/wait_for_condition.dart';

/// Account lookup and switch-state waits shared by the web account switchers.
mixin AccountSwitchRobotMixin on CoreRobot {
  ProviderContainer appContainer() {
    final element = $.tester.element(find.byType(MaterialApp));
    return ProviderScope.containerOf(element, listen: false);
  }

  AccountId accountIdForAddress(String emailAddress) {
    final session = appContainer().read(activeAccountProvider)?.session;
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

  Future<void> waitSwitchIdleOn(String ownerAddress) {
    return waitForCondition(
      () {
        final container = appContainer();
        if (container.read(accountSwitchProvider).isSwitching) return false;
        final active = container.read(activeAccountProvider);
        return active != null && active.ownerEmailAddress == ownerAddress;
      },
      reason: 'switched to $ownerAddress and idle',
    );
  }

  Future<void> waitSwitchIdleOnMine() {
    return waitForCondition(
      () {
        final container = appContainer();
        final active = container.read(activeAccountProvider);
        return active != null &&
            !active.isDelegated &&
            !container.read(accountSwitchProvider).isSwitching;
      },
      reason: 'showing mine and switch idle',
    );
  }

  Future<void> waitLoadingDialogGone() {
    return waitForCondition(
      () => $(const ValueKey(UiKeys.accountSwitchLoadingDialog))
          .evaluate()
          .isEmpty,
      reason: 'account switch loading dialog closed',
    );
  }
}
