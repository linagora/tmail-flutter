import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:email_recovery/email_recovery/email_recovery_action.dart';

class GetRestoredDeletedMessageLoading extends LoadingState {}

class GetRestoredDeletedMessageSuccess extends UIState {
  final EmailRecoveryAction emailRecoveryAction;

  GetRestoredDeletedMessageSuccess(this.emailRecoveryAction);

  @override
  List<Object> get props => [emailRecoveryAction];
}

class GetRestoredDeletedMessageFailure extends FeatureFailure {
  GetRestoredDeletedMessageFailure(dynamic exception) : super(exception: exception);
}