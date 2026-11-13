import 'package:equatable/equatable.dart';

enum AccountSwitchRefusal {
  switchInProgress,
  composerOpen,
  accountAlreadyShown,
  accountNotListed,
}

sealed class AccountSwitchResult with EquatableMixin {
  const AccountSwitchResult();

  @override
  List<Object?> get props => [];
}

class AccountSwitched extends AccountSwitchResult {
  const AccountSwitched();
}

class AccountSwitchRefused extends AccountSwitchResult {
  final AccountSwitchRefusal reason;

  const AccountSwitchRefused(this.reason);

  @override
  List<Object?> get props => [reason];
}

class AccountSwitchCancelled extends AccountSwitchResult {
  const AccountSwitchCancelled();
}

class AccountSwitchTimedOut extends AccountSwitchResult {
  const AccountSwitchTimedOut();
}

class AccountSwitchFailed extends AccountSwitchResult {
  final Object error;
  final StackTrace stackTrace;

  const AccountSwitchFailed(this.error, this.stackTrace);

  @override
  List<Object?> get props => [error, stackTrace];
}
