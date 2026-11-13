import 'package:core/presentation/utils/app_toast.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/account_switch_view_factory_provider.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart';

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

/// Shows [targetAccountId] in place of [shown] and toasts when the switch does not complete.
Future<void> switchShownAccountOrToastFailure({
  required BuildContext context,
  required WidgetRef ref,
  required ActiveAccount shown,
  required AccountId targetAccountId,
}) async {
  final returningToMine = targetAccountId == shown.personalAccountId;
  final ownerDisplayName = returningToMine
      ? shown.session.getOwnEmailAddressOrEmpty()
      : shown.session.accounts[targetAccountId]?.name.value ??
          targetAccountId.id.value;

  final view = ref.read(accountSwitchViewFactoryProvider)(context);
  final result = await ref
      .read(accountSwitchProvider.notifier)
      .switchTo(targetAccountId, view);

  if (!context.mounted) return;
  showAccountSwitchFailureToast(
    context: context,
    appToast: ref.read(appToastProvider),
    args: AccountSwitchFailureToastArgs(
      result: result,
      ownerDisplayName: ownerDisplayName,
      returningToMine: returningToMine,
    ),
  );
}
