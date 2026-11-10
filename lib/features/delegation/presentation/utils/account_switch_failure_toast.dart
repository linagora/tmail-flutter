import 'package:core/presentation/utils/app_toast.dart';
import 'package:flutter/widgets.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_result.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

/// Inputs for [showAccountSwitchFailureToast] (keeps the helper arity low).
class AccountSwitchFailureToastArgs {
  final AccountSwitchResult result;
  final String ownerDisplayName;
  final bool returningToMine;

  const AccountSwitchFailureToastArgs({
    required this.result,
    required this.ownerDisplayName,
    this.returningToMine = false,
  });
}

/// Error toast after a refused, failed, cancelled, or timed-out switch.
void showAccountSwitchFailureToast({
  required BuildContext context,
  required AppToast appToast,
  required AccountSwitchFailureToastArgs args,
}) {
  final l10n = AppLocalizations.of(context);
  final result = args.result;

  if (result is AccountSwitchRefused &&
      result.reason == AccountSwitchRefusal.composerOpen) {
    appToast.showToastErrorMessage(
      context,
      l10n.closeComposerBeforeSwitchingAccounts,
    );
    return;
  }

  final shouldToast = result is AccountSwitchFailed ||
      result is AccountSwitchCancelled ||
      result is AccountSwitchTimedOut;
  if (!shouldToast) return;

  final message = args.returningToMine
      ? l10n.couldNotReturnToYourMailbox
      : l10n.couldNotOpenOwnerMailbox(args.ownerDisplayName);
  appToast.showToastErrorMessage(context, message);
}
