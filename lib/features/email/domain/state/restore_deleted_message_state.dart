import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:email_recovery/email_recovery/email_recovery_action.dart';

class RestoreDeletedMessageLoading extends LoadingState {}

class RestoreDeletedMessageSuccess extends UIState {
  final EmailRecoveryAction emailRecoveryAction;
  final AccountId accountId;

  RestoreDeletedMessageSuccess(this.emailRecoveryAction, this.accountId);

  @override
  List<Object?> get props => [emailRecoveryAction, accountId];
}

class RestoreDeletedMessageFailure extends FeatureFailure {
  RestoreDeletedMessageFailure(dynamic exception) : super(exception: exception);
}