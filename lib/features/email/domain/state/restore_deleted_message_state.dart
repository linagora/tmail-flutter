import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:email_recovery/email_recovery/email_recovery_action.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class RestoreDeletedMessageLoading extends LoadingState {}

class RestoreDeletedMessageSuccess extends UIActionState {
  final EmailRecoveryAction emailRecoveryAction;
  
  RestoreDeletedMessageSuccess(
    this.emailRecoveryAction,
    {
      jmap.State? currentMailboxState,
    }
  ) : super(null, currentMailboxState);

  @override
  List<Object?> get props => [emailRecoveryAction, ...super.props];
}

class RestoreDeletedMessageFailure extends FeatureFailure {
  RestoreDeletedMessageFailure(dynamic exception) : super(exception: exception);
}