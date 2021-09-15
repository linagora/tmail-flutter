import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';

class MarkAsEmailReadInteractor {
  final EmailRepository emailRepository;

  MarkAsEmailReadInteractor(this.emailRepository);

  Future<Either<Failure, Success>> execute(AccountId accountId, EmailId emailId, bool unread) async {
    try {
      final result = await emailRepository.markAsRead(accountId, emailId, unread);
      return result ? Right(MarkAsEmailReadSuccess(emailId)) : Left(MarkAsEmailReadFailure(null));
    } catch (e) {
      return Left(MarkAsEmailReadFailure(e));
    }
  }
}