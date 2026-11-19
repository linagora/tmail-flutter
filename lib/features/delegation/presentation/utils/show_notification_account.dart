import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/account_switch_view_factory_provider.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/account_switch_failure_toast.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/start_on_url_account.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart';

/// Shows the account of a tapped notification before its email opens (ADR-0114 Sync).
/// [notificationAccountId] null means my own account. Returns false, after its toast, when the tap is dropped.
Future<bool> showNotificationAccount({
  required BuildContext context,
  required AccountId? notificationAccountId,
}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final shown = container.read(activeAccountProvider);
  if (shown == null) return notificationAccountId == null;
  final targetAccountId = notificationAccountId ?? shown.personalAccountId;
  if (targetAccountId == shown.accountId) return true;

  final result = await container
      .read(accountSwitchProvider.notifier)
      .switchTo(targetAccountId, container.read(accountSwitchViewFactoryProvider)(context));
  if (result is AccountSwitched) return true;
  if (!context.mounted) return false;

  final returningToMine = targetAccountId == shown.personalAccountId;
  showUrlAccountStartToast(
    context: context,
    appToast: container.read(appToastProvider),
    args: AccountSwitchFailureToastArgs(
      result: result,
      ownerDisplayName: shown.session.accounts[targetAccountId]?.name.value ?? targetAccountId.id.value,
      returningToMine: returningToMine,
    ),
  );
  return false;
}
