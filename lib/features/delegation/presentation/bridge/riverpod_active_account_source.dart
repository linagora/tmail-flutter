import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_source.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';

/// Forwards [ActiveAccountSource] and [ActiveAccountWriter] to [activeAccountProvider], the single
/// source of truth. It keeps no state of its own.
class RiverpodActiveAccountSource implements ActiveAccountSource, ActiveAccountWriter {
  final ProviderContainer _container;

  RiverpodActiveAccountSource(this._container);

  @override
  AccountId? get accountId => activeAccount?.accountId;

  @override
  ActiveAccount? get activeAccount => _container.read(activeAccountProvider);

  @override
  void applySession(Session session) {
    _container.read(activeAccountProvider.notifier).applySession(session);
  }

  @override
  void clear() => _container.read(activeAccountProvider.notifier).clear();

  @override
  CancelShownAccountWatch watchShown(OnShownAccount onShown) {
    final subscription = _container.listen<AccountId?>(
      activeAccountProvider.select((activeAccount) => activeAccount?.accountId),
      (_, shownAccountId) {
        if (shownAccountId != null) onShown(shownAccountId);
      },
      fireImmediately: true,
    );
    return subscription.close;
  }
}
