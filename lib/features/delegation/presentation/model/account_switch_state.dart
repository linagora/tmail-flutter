import 'package:equatable/equatable.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/switch_attempt.dart';

sealed class AccountSwitchState with EquatableMixin {
  const AccountSwitchState();

  /// The attempt a view result is stamped with when it is requested.
  int get currentAttemptId;

  bool get isSwitching => this is AccountSwitching;
}

class AccountSwitchIdle extends AccountSwitchState {
  final int lastAttemptId;

  const AccountSwitchIdle({this.lastAttemptId = 0});

  @override
  int get currentAttemptId => lastAttemptId;

  @override
  List<Object?> get props => [lastAttemptId];
}

class AccountSwitching extends AccountSwitchState {
  final SwitchAttempt attempt;

  const AccountSwitching(this.attempt);

  @override
  int get currentAttemptId => attempt.id;

  @override
  List<Object?> get props => [attempt];
}
