import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_action_state.dart';

class LoadingSubscribeMailbox extends UIState {}

class SubscribeMailboxSuccess extends UIActionState {
  final MailboxId mailboxId;
  final MailboxSubscribeAction subscribeAction;

  SubscribeMailboxSuccess(
    this.mailboxId, 
    this.subscribeAction,
    {
      jmap.State? currentEmailState,
      jmap.State? currentMailboxState,
    }
  ) : super(currentEmailState, currentMailboxState);

  @override
  List<Object?> get props => [
    mailboxId,
    subscribeAction,
    super.props
  ];
}

class SubscribeMailboxFailure extends FeatureFailure {
  final dynamic exception;

  SubscribeMailboxFailure(this.exception);

  @override
  List<Object> get props => [exception];
}