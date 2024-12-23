import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_action_type.dart';

class SendEmailInteractor {
  final EmailRepository _emailRepository;

  SendEmailInteractor(this._emailRepository);

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

      await _emailRepository.sendEmail(
        session,
        accountId,
        emailRequest,
        mailboxRequest: mailboxRequest
      );

      if (emailRequest.emailIdDestroyed != null) {
        await _emailRepository.deleteEmailPermanently(session, accountId, emailRequest.emailIdDestroyed!);
      }

      yield Right<Failure, Success>(
        SendEmailSuccess(emailRequest: emailRequest)
      );
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