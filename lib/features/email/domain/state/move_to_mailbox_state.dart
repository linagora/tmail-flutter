import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';

class LoadingMoveToMailbox extends UIState {}

class MoveToMailboxSuccess extends UIState {
  final EmailId emailId;
  final MailboxId currentMailboxId;
  final MailboxId destinationMailboxId;
  final MoveAction moveAction;
  final EmailActionType emailActionType;
  final String? destinationPath;
  final Map<MailboxId,List<EmailId>> originalMailboxIdsWithEmailIds;
  final Map<EmailId, bool> emailIdsWithReadStatus;

  MoveToMailboxSuccess(
    this.emailId,
    this.currentMailboxId,
    this.destinationMailboxId,
    this.moveAction,
    this.emailActionType,
    {
      this.destinationPath,
      required this.originalMailboxIdsWithEmailIds,
      required this.emailIdsWithReadStatus,
    }
  );

  @override
  List<Object?> get props => [
    emailId,
    currentMailboxId,
    destinationMailboxId,
    moveAction,
    emailActionType,
    destinationPath,
    originalMailboxIdsWithEmailIds,
    emailIdsWithReadStatus,
  ];
}

class MoveToMailboxFailure extends FeatureFailure {
  final EmailActionType emailActionType;

  MoveToMailboxFailure(this.emailActionType, {dynamic exception}) : super(exception: exception);

  @override
  List<Object?> get props => [emailActionType, ...super.props];
}