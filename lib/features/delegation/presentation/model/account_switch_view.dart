import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';

abstract interface class AccountSwitchView {
  bool get hasOpenComposer;

  void blockInput();

  void unblockInput();

  void keepSelectionAndSearch();

  void restoreSelectionAndSearch();

  Future<void> loadAccount(ActiveAccount account, int switchAttemptId);

  void catchUpAccount(ActiveAccount account, int switchAttemptId);
}
