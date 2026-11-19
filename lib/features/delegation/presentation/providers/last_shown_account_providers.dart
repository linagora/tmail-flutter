import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/last_shown_account_store.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';

part 'last_shown_account_providers.g.dart';

@riverpod
LastShownAccountStore lastShownAccountStore(Ref ref) => Get.find<LastShownAccountStore>();

/// Keeps the store in step with the shown account once the start has read it:
/// each shown account is written, `mine` and a sign-out remove the entry.
@Riverpod(keepAlive: true)
void lastShownAccountRecorder(Ref ref) {
  ref.listen<ActiveAccount?>(activeAccountProvider, (previous, next) {
    // A null previous is the session read of a start or sign-in, which shows mine without choosing it.
    if (previous == null || previous.accountId == next?.accountId) return;
    Future.sync(() => _record(ref.read(lastShownAccountStoreProvider), previous, next)).catchError((Object error, StackTrace stackTrace) {
      logError(
        'lastShownAccountRecorder: could not store the shown account',
        exception: error,
        stackTrace: stackTrace,
      );
    });
  });
}

Future<void> _record(
  LastShownAccountStore store,
  ActiveAccount previous,
  ActiveAccount? next,
) {
  if (next == null) return store.remove(previous.session.username);
  return next.accountId == next.personalAccountId
      ? store.remove(next.session.username)
      : store.save(next.session.username, next.accountId);
}
