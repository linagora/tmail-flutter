import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/composer/domain/extensions/email_request_extension.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_action_type.dart';
import 'package:tmail_ui_user/features/server_settings/domain/repository/server_settings_repository.dart';

class SendEmailInteractor {
  final EmailRepository _emailRepository;
  final MailboxRepository _mailboxRepository;
  final ServerSettingsRepository _serverSettingsRepository;

  SendEmailInteractor(
    this._emailRepository,
    this._mailboxRepository,
    this._serverSettingsRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    EmailRequest emailRequest,
    {
      CreateNewMailboxRequest? mailboxRequest,
      SendingEmailActionType? sendingEmailActionType
    }
  ) async* {
    try {
      yield Right<Failure, Success>(SendEmailLoading());

      final listState = await Future.wait([
        _mailboxRepository.getMailboxState(session, accountId),
        _emailRepository.getEmailState(session, accountId),
      ], eagerError: true);

      final currentMailboxState = listState.first;
      final currentEmailState = listState.last;

      EmailRequest? updatedEmailRequest = await _getUpdatedEmailRequestIfAvailable(
        accountId,
        emailRequest);

      final result = await _emailRepository.sendEmail(
        session,
        accountId,
        updatedEmailRequest ?? emailRequest,
        mailboxRequest: mailboxRequest
      );

      if (result) {
        if (emailRequest.emailIdDestroyed != null) {
          await _emailRepository.deleteEmailPermanently(session, accountId, emailRequest.emailIdDestroyed!);
        }

        yield Right<Failure, Success>(
          SendEmailSuccess(
            currentEmailState: currentEmailState,
            currentMailboxState: currentMailboxState,
            emailRequest: emailRequest
          )
        );
      } else {
        yield Left<Failure, Success>(SendEmailFailure(
          session: session,
          accountId: accountId,
          emailRequest: emailRequest,
          mailboxRequest: mailboxRequest,
          sendingEmailActionType: sendingEmailActionType,
        ));
      }
    } catch (e) {
      yield Left<Failure, Success>(SendEmailFailure(
        exception: e,
        session: session,
        accountId: accountId,
        emailRequest: emailRequest,
        mailboxRequest: mailboxRequest,
        sendingEmailActionType: sendingEmailActionType,
      ));
    }
  }

  Future<EmailRequest?> _getUpdatedEmailRequestIfAvailable(
    AccountId accountId, 
    EmailRequest emailRequest
  ) async {
    bool alwaysReadReceipt = true;
    EmailRequest? updatedEmailRequest;
    try {
      final serverSettings = await _serverSettingsRepository.getServerSettings(accountId);
      alwaysReadReceipt = serverSettings.settings?.alwaysReadReceipts ?? true;
    } catch (_) {
      alwaysReadReceipt = true;
    }
    if (!alwaysReadReceipt) {
      updatedEmailRequest = emailRequest.withUpdatedEmailHeaderMdn({});
    }
    return updatedEmailRequest;
  }
}