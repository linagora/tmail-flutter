import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_action_state.dart';

class LoadingSubscribeMultipleMailbox extends UIState {}

class SubscribeMultipleMailboxAllSuccess extends UIActionState {

  final MailboxId parentMailboxId;
  final List<MailboxId> mailboxIdsSubscribe;
  final MailboxSubscribeAction subscribeAction;

  SubscribeMultipleMailboxAllSuccess(
    this.parentMailboxId,
    this.mailboxIdsSubscribe,
    this.subscribeAction,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [
    parentMailboxId,
    mailboxIdsSubscribe,
    subscribeAction,
    ...super.props
  ];
}

class SubscribeMultipleMailboxHasSomeSuccess extends UIActionState {

  final MailboxId parentMailboxId;
  final List<MailboxId> mailboxIdsSubscribe;
  final MailboxSubscribeAction subscribeAction;

  SubscribeMultipleMailboxHasSomeSuccess(
    this.parentMailboxId,
    this.mailboxIdsSubscribe,
    this.subscribeAction,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [
    parentMailboxId,
    mailboxIdsSubscribe,
    subscribeAction,
    ...super.props
  ];
}

class SubscribeMultipleMailboxAllFailure extends FeatureFailure {}

class SubscribeMultipleMailboxFailure extends FeatureFailure {

  SubscribeMultipleMailboxFailure(dynamic exception) : super(exception: exception);
}