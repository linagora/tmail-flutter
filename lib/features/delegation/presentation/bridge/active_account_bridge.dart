import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';

/// The only GetX access to [activeAccountProvider], registered for the app lifetime like the
/// provider itself. GetX readers of the shown mailbox go through `ActiveAccountReader`, never
/// `MailboxDashBoardController.accountId`, which stays my own account. Removed once those readers
/// move to Riverpod. See ADR-0114 and ADR-0092.
class ActiveAccountBridge extends GetxController {
  final ProviderContainer _container;

  /// The id of the shown account. It only notifies when the account changes, not on a session re-read.
  final accountId = Rxn<AccountId>();

  late final ProviderSubscription<ActiveAccount?> _subscription;

  ActiveAccountBridge(this._container) {
    _subscription = _container.listen<ActiveAccount?>(
      activeAccountProvider,
      (_, activeAccount) => accountId.value = activeAccount?.accountId,
      fireImmediately: true,
    );
  }

  ActiveAccount? get activeAccount => _container.read(activeAccountProvider);

  void applySession(Session session) {
    _container.read(activeAccountProvider.notifier).applySession(session);
  }

  void clear() => _container.read(activeAccountProvider.notifier).clear();

  @override
  void onClose() {
    _subscription.close();
    super.onClose();
  }
}
