import 'package:core/presentation/utils/app_toast.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/account_switch_view_factory_provider.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/account_switch_failure_toast.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart';
import 'package:tmail_ui_user/main/providers/cozy/inside_cozy_provider.dart';

/// Shows the `account` of a web start URL through a switch (ADR-0114 Start on a delegated account).
/// Returns false when mine stays shown, after its toast.
Future<bool> startOnUrlAccount({
  required BuildContext context,
  required AccountId urlAccountId,
}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  // The switcher is hidden inside Cozy, so a switch there could not be undone.
  final hasEntryPoint = !await container.read(insideCozyProvider.future);
  if (!context.mounted) return false;

  final result = hasEntryPoint
      ? await container
          .read(accountSwitchProvider.notifier)
          .switchTo(urlAccountId, container.read(accountSwitchViewFactoryProvider)(context))
      : null;
  if (result is AccountSwitched) return true;
  if (!context.mounted) return false;

  showUrlAccountStartToast(
    context: context,
    appToast: container.read(appToastProvider),
    args: AccountSwitchFailureToastArgs(
      result: result ?? const AccountSwitchRefused(AccountSwitchRefusal.accountNotListed),
      ownerDisplayName: _ownerDisplayName(container, urlAccountId),
    ),
  );
  return false;
}

/// An account the start cannot show gets the info toast, a switch that ran gets the switch toasts.
void showUrlAccountStartToast({
  required BuildContext context,
  required AppToast appToast,
  required AccountSwitchFailureToastArgs args,
}) {
  final result = args.result;
  if (result is AccountSwitchRefused && result.reason != AccountSwitchRefusal.composerOpen) {
    appToast.showToastWarningMessage(
      context,
      AppLocalizations.of(context).delegatedMailboxUnavailable,
    );
    return;
  }
  showAccountSwitchFailureToast(context: context, appToast: appToast, args: args);
}

String _ownerDisplayName(ProviderContainer container, AccountId accountId) =>
    container.read(activeAccountProvider)?.session.accounts[accountId]?.name.value ??
    accountId.id.value;
