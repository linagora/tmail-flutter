import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';

class SendEmailInteractor {
  final EmailRepository emailRepository;

  SendEmailInteractor(this.emailRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, EmailRequest emailRequest) async* {
    try {
      yield Right<Failure, Success>(SendingEmailState());
      final result = await emailRepository.sendEmail(accountId, emailRequest);
      if (result) {
        yield Right<Failure, Success>(SendEmailSuccess());
      } else {
        yield Left<Failure, Success>(SendEmailFailure(result));
      }
    } catch (e) {
      yield Left<Failure, Success>(SendEmailFailure(e));
    }
  }
}