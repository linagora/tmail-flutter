import 'package:equatable/equatable.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_action_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_state.dart';

class SubscribeMailboxRequest with EquatableMixin {

  final PresentationMailbox mailbox;
  final MailboxSubscribeState newState;
  final MailboxSubscribeStateAction mailboxSubscribeStateAction;

  SubscribeMailboxRequest(
    this.mailbox, 
    this.newState, 
    this.mailboxSubscribeStateAction);
  
  @override
  List<Object?> get props => [mailbox, newState, mailboxSubscribeStateAction];
}
