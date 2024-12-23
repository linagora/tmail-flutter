import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_action_type.dart';

class SendEmailLoading extends LoadingState {}

class SendEmailSuccess extends UIState {

  final EmailRequest emailRequest;

  SendEmailSuccess({
    required this.emailRequest,
  });

  @override
  List<Object?> get props => [
    emailRequest,
  ];
}

class SendEmailFailure extends FeatureFailure {

  final Session? session;
  final AccountId? accountId;
  final EmailRequest? emailRequest;
  final CreateNewMailboxRequest? mailboxRequest;
  final SendingEmailActionType? sendingEmailActionType;

  SendEmailFailure({
    dynamic exception,
    this.session,
    this.accountId,
    this.emailRequest,
    this.mailboxRequest,
    this.sendingEmailActionType
  }) : super(exception: exception);

  @override
  List<Object?> get props => [
    ...super.props,
    session,
    accountId,
    emailRequest,
    mailboxRequest,
    sendingEmailActionType,
  ];
}

class CancelSendingEmail extends LoadingState {}