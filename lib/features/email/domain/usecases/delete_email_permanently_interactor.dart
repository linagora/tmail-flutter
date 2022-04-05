import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_email_permanently_state.dart';

class DeleteEmailPermanentlyInteractor {
  final EmailRepository emailRepository;

  DeleteEmailPermanentlyInteractor(this.emailRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, EmailId emailId) async* {
    try {
      final result = await emailRepository.deleteEmailPermanently(accountId, emailId);
      if (result) {
        yield Right<Failure, Success>(DeleteEmailPermanentlySuccess());
      } else {
        yield Left<Failure, Success>(DeleteEmailPermanentlyFailure(null));
      }
    } catch (e) {
      yield Left<Failure, Success>(DeleteEmailPermanentlyFailure(e));
    }
  }
}