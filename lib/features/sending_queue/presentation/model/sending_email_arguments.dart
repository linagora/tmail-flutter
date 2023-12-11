import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/compose_action_mode.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';

class SendingEmailArguments extends RouterArguments {
  final Session session;
  final AccountId accountId;
  final EmailRequest emailRequest;
  final ComposeActionMode actionMode;

  SendingEmailArguments(
    this.session,
    this.accountId,
    this.emailRequest,
    {
      this.actionMode = ComposeActionMode.sent
    }
  );

  SendingEmailArguments copyWith({
    Session? session,
    AccountId? accountId,
    EmailRequest? emailRequest,
    CreateNewMailboxRequest? mailboxRequest,
    ComposeActionMode? actionMode,
  }) => SendingEmailArguments(
    session ?? this.session,
    accountId ?? this.accountId,
    emailRequest ?? this.emailRequest,
    actionMode: actionMode ?? this.actionMode
  );

  @override
  List<Object?> get props => [
    session,
    accountId,
    emailRequest,
    actionMode
  ];
}
