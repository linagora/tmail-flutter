import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:email_recovery/email_recovery/email_recovery_action.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';

class GetRestoredDeletedMessageLoading extends LoadingState {}

class GetRestoredDeletedMessageSuccess extends UIActionState {
  final EmailRecoveryAction emailRecoveryAction;
  final AccountId accountId;

  GetRestoredDeletedMessageSuccess(
    this.emailRecoveryAction,
    this.accountId,
    {
      jmap.State? currentMailboxState,
    }
  ) : super(null, currentMailboxState);

  @override
  List<Object?> get props => [emailRecoveryAction, accountId, ...super.props];
}

class GetRestoredDeletedMessageCompleted extends GetRestoredDeletedMessageSuccess {
  final Mailbox? recoveredMailbox;

  GetRestoredDeletedMessageCompleted(
    EmailRecoveryAction emailRecoveryAction,
    AccountId accountId,
    {this.recoveredMailbox}
  ) : super(emailRecoveryAction, accountId);

  @override
  List<Object?> get props => [emailRecoveryAction, accountId, recoveredMailbox];
}

class GetRestoredDeletedMessageWaiting extends GetRestoredDeletedMessageSuccess {
  GetRestoredDeletedMessageWaiting(
    EmailRecoveryAction emailRecoveryAction,
    AccountId accountId,
  ) : super(emailRecoveryAction, accountId);
}

class GetRestoredDeletedMessageInProgress extends GetRestoredDeletedMessageSuccess {
  GetRestoredDeletedMessageInProgress(
    EmailRecoveryAction emailRecoveryAction,
    AccountId accountId,
  ) : super(emailRecoveryAction, accountId);
}

class GetRestoredDeletedMessageCanceled extends GetRestoredDeletedMessageSuccess {
  GetRestoredDeletedMessageCanceled(
    EmailRecoveryAction emailRecoveryAction,
    AccountId accountId,
  ) : super(emailRecoveryAction, accountId);
}

class GetRestoredDeletedMessageFailure extends FeatureFailure {
  GetRestoredDeletedMessageFailure(dynamic exception) : super(exception: exception);
}