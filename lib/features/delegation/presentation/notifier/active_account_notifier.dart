import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/delegation/domain/extensions/session_delegation_extension.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';

part 'active_account_notifier.g.dart';

/// The account whose mailbox is shown. See ADR-0114.
@Riverpod(keepAlive: true)
class ActiveAccountNotifier extends _$ActiveAccountNotifier {
  @override
  ActiveAccount? build() => null;

  void applySession(Session session) {
    final shownAccount = state;
    final keepsShownDelegatedAccount = shownAccount != null &&
        shownAccount.isDelegated &&
        shownAccount.session.username == session.username &&
        session.isDelegatedAccount(shownAccount.accountId);

    state = keepsShownDelegatedAccount
        ? ActiveAccount.delegated(session, shownAccount.accountId)
        : ActiveAccount.personal(session);
  }

  bool canSelect(AccountId accountId) {
    final session = state?.session;
    return session != null &&
        (accountId == session.accountId || session.isDelegatedAccount(accountId));
  }

  bool select(AccountId accountId) {
    if (!canSelect(accountId)) return false;

    final session = state!.session;
    state = accountId == session.accountId
        ? ActiveAccount.personal(session)
        : ActiveAccount.delegated(session, accountId);
    return true;
  }

  void selectPersonal() {
    final session = state?.session;
    if (session != null) state = ActiveAccount.personal(session);
  }

  /// Clears the in-memory selection when the signed-in session ends.
  void clear() => state = null;
}
