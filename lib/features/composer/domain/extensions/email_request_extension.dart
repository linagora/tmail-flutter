
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/offline_mode/model/sending_state.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';

extension EmailRequestExtension on EmailRequest {
  SendingEmail toSendingEmail(
    String sendingId,
    {
      CreateNewMailboxRequest? mailboxRequest,
      SendingState newState = SendingState.waiting
    }
  ) {
    return SendingEmail(
      sendingId: sendingId,
      email: email,
      emailActionType: emailActionType,
      createTime: DateTime.now(),
      sentMailboxId: sentMailboxId,
      emailIdDestroyed: emailIdDestroyed,
      emailIdAnsweredOrForwarded: emailIdAnsweredOrForwarded,
      identityId: identityId,
      mailboxNameRequest: mailboxRequest?.newName,
      creationIdRequest: mailboxRequest?.creationId,
      sendingState: newState,
      previousEmailId: previousEmailId
    );
  }

  EmailRequest withUpdatedEmailHeaderMdn(
    Map<IndividualHeaderIdentifier, String?> value,
  ) {
    return EmailRequest(
      email: email.updateEmailHeaderMdn(value),
      sentMailboxId: sentMailboxId,
      emailIdDestroyed: emailIdDestroyed,
      emailIdAnsweredOrForwarded: emailIdAnsweredOrForwarded,
      identityId: identityId,
      emailActionType: emailActionType,
      storedSendingId: storedSendingId,
      previousEmailId: previousEmailId,
    );
  }
}