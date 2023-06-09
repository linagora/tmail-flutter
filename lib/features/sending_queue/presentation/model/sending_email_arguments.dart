import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_action_type.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';

class SendingEmailArguments extends RouterArguments {
  final Session session;
  final AccountId accountId;
  final EmailRequest emailRequest;
  final CreateNewMailboxRequest? mailboxRequest;
  final SendingEmailActionType sendingEmailActionType;

  SendingEmailArguments(
    this.session,
    this.accountId,
    this.emailRequest,
    this.mailboxRequest,
    {
      this.sendingEmailActionType = SendingEmailActionType.create
    }
  );

  @override
  List<Object?> get props => [
    session,
    accountId,
    emailRequest,
    mailboxRequest,
    sendingEmailActionType
  ];
}
