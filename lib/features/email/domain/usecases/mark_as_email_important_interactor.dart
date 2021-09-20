import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_important_state.dart';

class MarkAsEmailImportantInteractor {
  final EmailRepository emailRepository;

  MarkAsEmailImportantInteractor(this.emailRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, EmailId emailId, ImportantAction importantAction) async* {
    try {
      final result = await emailRepository.markAsImportant(accountId, emailId, importantAction);
      yield result ? Right(MarkAsEmailImportantSuccess(emailId, importantAction)) : Left(MarkAsEmailImportantFailure(null, importantAction));
    } catch (e) {
      yield Left(MarkAsEmailImportantFailure(e, importantAction));
    }
  }
}