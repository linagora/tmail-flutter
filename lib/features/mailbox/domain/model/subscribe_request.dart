import 'package:equatable/equatable.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_action_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_state.dart';

abstract class SubscribeRequest with EquatableMixin {

  final MailboxSubscribeState subscribeState;
  final MailboxSubscribeAction subscribeAction;

  SubscribeRequest(this.subscribeState, this.subscribeAction);
  
  @override
  List<Object?> get props => [subscribeState, subscribeAction];
}
