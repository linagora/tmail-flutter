import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/shown_account_load.dart';

typedef OnShownAccount = void Function(AccountId shownAccountId);
typedef CancelShownAccountWatch = void Function();

/// The only API GetX readers may use for the shown account. Removed once they move to Riverpod.
/// See ADR-0114 and ADR-0092.
abstract interface class ActiveAccountSource {
  AccountId? get accountId;

  ActiveAccount? get activeAccount;

  int get currentSwitchAttemptId;

  /// Calls [onShown] with the shown account at once, then each time another account is shown, never
  /// on a session re-read of the same account.
  CancelShownAccountWatch watchShown(OnShownAccount onShown);

  /// For a switch ending on the account already shown, which watchShown never reports.
  CancelShownAccountWatch watchShownReload(OnShownAccount onReload);
}

/// Sets the shown account from GetX code: the dashboard and the logout only.
abstract interface class ActiveAccountWriter {
  void applySession(Session session);

  void clear();
}

abstract interface class ShownAccountLoadReporter {
  void reportLoad(ShownAccountLoadKind kind, ShownAccountLoad load);
}
