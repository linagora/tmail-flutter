import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_multiple_emails_permanently_state.dart';

class DeleteMultipleEmailsPermanentlyInteractor {
  final EmailRepository emailRepository;

  DeleteMultipleEmailsPermanentlyInteractor(this.emailRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, List<EmailId> emailIds) async* {
    try {
      final listResult = await emailRepository.deleteMultipleEmailsPermanently(accountId, emailIds);
      if (listResult.length == emailIds.length) {
        yield Right<Failure, Success>(DeleteMultipleEmailsPermanentlyAllSuccess(listResult));
      } else if (listResult.isNotEmpty) {
        yield Right<Failure, Success>(DeleteMultipleEmailsPermanentlyHasSomeEmailFailure(listResult));
      } else {
        yield Left<Failure, Success>(DeleteMultipleEmailsPermanentlyAllFailure());
      }
    } catch (e) {
      yield Left<Failure, Success>(DeleteMultipleEmailsPermanentlyFailure(e));
    }
  }
}