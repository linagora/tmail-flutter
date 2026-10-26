import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';

/// Ends the account-switch session using the provider container above [context].
///
/// Resolving the container from the widget tree keeps session cleanup on the
/// same Riverpod scope as the rest of the app without adding another use of the
/// frozen global provider container.
void endDelegationSession(BuildContext context) {
  ProviderScope.containerOf(
    context,
    listen: false,
  ).read(accountSwitchProvider.notifier).endSession();
}
