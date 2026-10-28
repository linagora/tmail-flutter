import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';

abstract interface class AccountSwitchView {
  bool get hasOpenComposer;

  /// Also closes every open dialog, sheet and menu, so an entry point never pops its own route after it.
  void blockInput();

  void unblockInput();

  /// So the target opens on its Inbox.
  void clearSelectionAndSearch();

  /// Loads [account] from cache, then runs `/changes` and completes only after
  /// that catch-up. Pushes for the target are skipped until Idle, so a change
  /// that arrived during the switch is applied here. A failure of `/changes`
  /// fails the switch.
  Future<void> loadAccount(ActiveAccount account, int switchAttemptId);

  /// After a failure, cancel or timeout: clears what the target opened and loads the account shown
  /// again with `/changes`, also when no account change does it.
  void catchUpAccount(ActiveAccount account, int switchAttemptId);
}
