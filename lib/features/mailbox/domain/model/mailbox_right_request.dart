import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subaddressing_action.dart';

class MailboxRightRequest with EquatableMixin {

  final MailboxSubaddressingAction subaddressingAction;
  final MailboxId mailboxId;
  final Map<String, List<String>?>? currentRights;

  MailboxRightRequest(
      this.mailboxId,
      this.currentRights,
      this.subaddressingAction
  );

  @override
  List<Object?> get props => [
    mailboxId,
    currentRights,
    subaddressingAction,
  ];
}
