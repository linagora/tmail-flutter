import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/shown_account_capabilities.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/account_switch_failure_toast.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/account_switch_view_factory_provider.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart';

/// Shows `mine` before a share or `mailto` intent opens the composer (ADR-0114).
/// Returns false, after an error toast, when the switch to `mine` does not complete.
Future<bool> showMineBeforeIntent(BuildContext context) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final shown = container.read(activeAccountProvider);
  if (shown == null || !ShownAccountCapabilities.of(shown).switchesToMineBeforeIntent) return true;

  final result = await container
      .read(accountSwitchProvider.notifier)
      .switchTo(shown.personalAccountId, container.read(accountSwitchViewFactoryProvider)(context));
  if (result is AccountSwitched) return true;
  if (!context.mounted) return false;

  final appToast = container.read(appToastProvider);
  if (_isSwitchInProgress(result)) {
    // The switcher stays silent on this refusal, but a dropped intent must not be.
    appToast.showToastErrorMessage(context, AppLocalizations.of(context).couldNotReturnToYourMailbox);
  } else {
    showAccountSwitchFailureToast(
      context: context,
      appToast: appToast,
      args: AccountSwitchFailureToastArgs(result: result, ownerDisplayName: '', returningToMine: true),
    );
  }
  return false;
}

bool _isSwitchInProgress(AccountSwitchResult result) =>
    result is AccountSwitchRefused && result.reason == AccountSwitchRefusal.switchInProgress;
