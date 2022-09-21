import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';

class SendEmailInteractor {
  final EmailRepository _emailRepository;
  final MailboxRepository _mailboxRepository;

  SendEmailInteractor(this._emailRepository, this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, EmailRequest emailRequest) async* {
    try {
      yield Right<Failure, Success>(SendingEmailState());

      final listState = await Future.wait([
        _mailboxRepository.getMailboxState(),
        _emailRepository.getEmailState(),
      ], eagerError: true);

      final currentMailboxState = listState.first;
      final currentEmailState = listState.last;

      final result = await _emailRepository.sendEmail(accountId, emailRequest);
      log('SendEmailInteractor::execute(): result = $result');
      if (result) {
        yield Right<Failure, Success>(SendEmailSuccess(
            currentEmailState: currentEmailState,
            currentMailboxState: currentMailboxState));
      } else {
        yield Left<Failure, Success>(SendEmailFailure(result));
      }
    } catch (e) {
      log('SendEmailInteractor::execute(): $e');
      yield Left<Failure, Success>(SendEmailFailure(e));
    }
  }
}