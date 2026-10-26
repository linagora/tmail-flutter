import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';

abstract interface class AccountSwitchView {
  bool get hasOpenComposer;

  void blockInput();

  void unblockInput();

  void keepSelectionAndSearch();

  void restoreSelectionAndSearch();

  /// Loads [account] from cache, then runs `/changes` and completes only after
  /// that catch-up. Pushes for the target are skipped until Idle, so a change
  /// that arrived during the switch is applied here. A failure of `/changes`
  /// fails the switch.
  Future<void> loadAccount(ActiveAccount account, int switchAttemptId);

  /// Runs `/changes` on an account that is already on screen (rollback after
  /// failure, cancel or timeout).
  void catchUpAccount(ActiveAccount account, int switchAttemptId);
}
