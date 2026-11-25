import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_state.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';

bool isAccountSwitchRunning(ProviderContainer container) =>
    container.read(accountSwitchProvider).isSwitching;

/// A composer opened during a switch, like a notification tap at start, would make it fall back.
Future<void> untilNoAccountSwitchRuns(ProviderContainer container) async {
  if (!isAccountSwitchRunning(container)) return;
  final switchEnded = Completer<void>();
  final subscription = container.listen<AccountSwitchState>(
    accountSwitchProvider,
    (_, next) {
      if (!next.isSwitching && !switchEnded.isCompleted) switchEnded.complete();
    },
  );
  try {
    await switchEnded.future;
  } finally {
    subscription.close();
  }
}
