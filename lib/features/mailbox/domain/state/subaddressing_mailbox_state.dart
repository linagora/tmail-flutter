import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subaddressing_action.dart';

class LoadingSubaddressingMailbox extends LoadingState {}

class SubaddressingSuccess extends UIActionState {
  final MailboxId mailboxId;
  final MailboxSubaddressingAction subaddressingAction;

  SubaddressingSuccess(
    this.mailboxId, 
    this.subaddressingAction,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [
    mailboxId,
    subaddressingAction,
    ...super.props
  ];
}

class SubaddressingFailure extends FeatureFailure {

  SubaddressingFailure(dynamic exception) : super(exception: exception);

  SubaddressingFailure.withException(Exception exception)
      : super(exception: exception);
}