import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_action_type.dart';

class SendEmailInteractor {
  final EmailRepository _emailRepository;
  final MailboxRepository _mailboxRepository;

  SendEmailInteractor(this._emailRepository, this._mailboxRepository);

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

      final result = await _emailRepository.sendEmail(
        session,
        accountId,
        emailRequest,
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
}