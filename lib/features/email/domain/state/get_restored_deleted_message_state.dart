import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:email_recovery/email_recovery/email_recovery_action.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

class GetRestoredDeletedMessageLoading extends LoadingState {}

class GetRestoredDeletedMessageSuccess extends UIActionState {
  final EmailRecoveryAction emailRecoveryAction;
  
  
  GetRestoredDeletedMessageSuccess(
    this.emailRecoveryAction,
    {
      jmap.State? currentMailboxState,
    }
  ) : super(null, currentMailboxState);

  @override
  List<Object?> get props => [emailRecoveryAction, ...super.props];
}

class GetRestoredDeletedMessageCompleted extends GetRestoredDeletedMessageSuccess {
  final Mailbox? recoveredMailbox;

  GetRestoredDeletedMessageCompleted(
    EmailRecoveryAction emailRecoveryAction,
    {this.recoveredMailbox}
  ) : super(emailRecoveryAction);

  @override
  List<Object?> get props => [emailRecoveryAction, recoveredMailbox];
}

class GetRestoredDeletedMessageWaiting extends GetRestoredDeletedMessageSuccess {
  GetRestoredDeletedMessageWaiting(
    EmailRecoveryAction emailRecoveryAction,
  ) : super(emailRecoveryAction);
}

class GetRestoredDeletedMessageInProgress extends GetRestoredDeletedMessageSuccess {
  GetRestoredDeletedMessageInProgress(
    EmailRecoveryAction emailRecoveryAction,
  ) : super(emailRecoveryAction);
}

class GetRestoredDeletedMessageCanceled extends GetRestoredDeletedMessageSuccess {
  GetRestoredDeletedMessageCanceled(
    EmailRecoveryAction emailRecoveryAction,
  ) : super(emailRecoveryAction);
}

class GetRestoredDeletedMessageFailure extends FeatureFailure {
  GetRestoredDeletedMessageFailure(dynamic exception) : super(exception: exception);
}