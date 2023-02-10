import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_action_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_request.dart';

class SubscribeMultipleMailboxRequest extends SubscribeRequest {

  final MailboxId parentMailboxId;
  final List<MailboxId> mailboxIdsSubscribe;

  SubscribeMultipleMailboxRequest(
    this.parentMailboxId,
    this.mailboxIdsSubscribe,
    MailboxSubscribeState subscribeState,
    MailboxSubscribeAction subscribeAction,
  ) : super(subscribeState, subscribeAction);
  
  @override
  List<Object?> get props => [
    parentMailboxId,
    mailboxIdsSubscribe,
    super.props
  ];
}
