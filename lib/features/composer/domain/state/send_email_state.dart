import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/base/state/ui_action_state.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_action_type.dart';

class SendEmailLoading extends UIState {}

class SendEmailSuccess extends UIActionState {

  SendEmailSuccess({
    jmap.State? currentEmailState,
    jmap.State? currentMailboxState,
  }) : super(currentEmailState, currentMailboxState);
}

class SendEmailFailure extends FeatureFailure {

  final Session session;
  final AccountId accountId;
  final EmailRequest emailRequest;
  final CreateNewMailboxRequest? mailboxRequest;
  final SendingEmailActionType? sendingEmailActionType;

  SendEmailFailure({
    dynamic exception,
    required this.session,
    required this.accountId,
    required this.emailRequest,
    this.mailboxRequest,
    this.sendingEmailActionType
  }) : super(exception: exception);
}