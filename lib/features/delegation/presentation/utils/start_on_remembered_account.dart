import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/account_switch_view_factory_provider.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/last_shown_account_providers.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/start_on_account.dart';

/// Starts the Android and iOS app on the last shown account of the signed-in user (ADR-0114 Start on a delegated account).
/// A start from a notification tap or an intent (open composer) stays on `mine`, a start whose first folder load failed (offline) keeps the entry for the next one.
/// An account the start cannot show is forgotten, so the next start opens `mine`. Returns true once the remembered account is shown.
Future<bool> startOnRememberedAccount(
  BuildContext context, {
  bool launchedByNotification = false,
  bool firstLoadFailed = false,
}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final shown = container.read(activeAccountProvider);
  if (shown == null) return false;

  final store = container.read(lastShownAccountStoreProvider);
  final username = shown.session.username;
  final rememberedAccountId = store.read(username);
  container.read(lastShownAccountRecorderProvider);
  // The user chose this delegated account before the first load ended, so it is the last shown one.
  if (shown.accountId != shown.personalAccountId) {
    await store.save(username, shown.accountId);
    return false;
  }
  if (firstLoadFailed || rememberedAccountId == null) return false;

  final accountShown = !_startsOnMine(context, container, launchedByNotification) &&
      await startOnAccount(context: context, accountId: rememberedAccountId);
  if (!accountShown) await store.remove(username);
  return accountShown;
}

bool _startsOnMine(BuildContext context, ProviderContainer container, bool launchedByNotification) =>
    launchedByNotification || container.read(accountSwitchViewFactoryProvider)(context).hasOpenComposer;
