import 'package:delegation/model/delegated_account.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/base/interactor_consumer.dart';
import 'package:tmail_ui_user/features/delegation/domain/state/get_delegated_accounts_state.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegated_account_providers.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';

part 'delegated_to_me_notifier.g.dart';

typedef OnSessionReloaded = void Function(Session session);

/// The mailboxes delegated to me, listed in Settings › Delegation. See ADR-0114.
@riverpod
class DelegatedToMeNotifier extends _$DelegatedToMeNotifier with InteractorConsumer {
  GetSessionInteractor get _getSessionInteractor => Get.find<GetSessionInteractor>();

  int _latestLoadId = 0;
  int _latestReloadId = 0;
  final _pendingRemovalIds = <Id>{};

  @override
  AsyncValue<List<DelegatedAccount>> build() => const AsyncLoading();

  Future<void> load(Session session) async {
    final loadId = ++_latestLoadId;
    state = const AsyncLoading();
    final interactor = ref.read(getDelegatedAccountsInteractorProvider);
    await consumeInteractor(InteractorConsumeRequest(
      run: () => interactor.execute(session).last,
      isStale: () => !ref.mounted || loadId != _latestLoadId,
      onSuccess: (success) {
        if (success is GetDelegatedAccountsSuccess) {
          state = AsyncData(success.delegatedAccounts);
        }
      },
      onFailure: (error, stackTrace) => state = AsyncError(error, stackTrace),
    ));
  }

  /// Removes my access, then re-reads the session so the switcher drops that mailbox.
  Future<bool> remove(
    Session session,
    DelegatedAccount delegatedAccount, {
    OnSessionReloaded? onSessionReloaded,
  }) async {
    // A second tap while the first removal runs would fail on the server and show a false error.
    if (!_pendingRemovalIds.add(delegatedAccount.id)) return true;
    try {
      return await _removeAndReloadSession(session, delegatedAccount, onSessionReloaded);
    } finally {
      _pendingRemovalIds.remove(delegatedAccount.id);
    }
  }

  Future<bool> _removeAndReloadSession(
    Session session,
    DelegatedAccount delegatedAccount,
    OnSessionReloaded? onSessionReloaded,
  ) async {
    final interactor = ref.read(removeDelegatedAccountInteractorProvider);
    // Read before the await: the session must still reach the switcher if Settings closes meanwhile.
    final activeAccount = ref.read(activeAccountProvider.notifier);
    final removed = await consumeInteractor(InteractorConsumeRequest(
      run: () => interactor.execute(session, delegatedAccount).last,
      isStale: () => false,
      onSuccess: (_) => _dropFromList(delegatedAccount),
      onFailure: (_, __) {},
    ));
    if (removed) {
      await _reloadSession(activeAccount, onSessionReloaded);
    }
    return removed;
  }

  void _dropFromList(DelegatedAccount delegatedAccount) {
    if (!ref.mounted) return;
    final accounts = state.value;
    if (accounts == null) return;
    state = AsyncData(accounts.where((account) => account != delegatedAccount).toList());
  }

  Future<void> _reloadSession(ActiveAccountNotifier activeAccount, OnSessionReloaded? onSessionReloaded) {
    final reloadId = ++_latestReloadId;
    return consumeInteractor(InteractorConsumeRequest(
      run: () => _getSessionInteractor.execute().last,
      // Only the latest re-read applies: it started after every removal that completed before it.
      isStale: () => reloadId != _latestReloadId,
      onSuccess: (success) {
        // A cached session still lists the removed mailbox.
        if (success is GetSessionSuccess &&
            !success.fromCache &&
            activeAccount.applyReloadedSession(success.session)) {
          onSessionReloaded?.call(success.session);
        }
      },
      onFailure: (_, __) {},
    ));
  }
}
