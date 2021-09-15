import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/read_actions.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';

class MarkAsEmailReadInteractor {
  final EmailRepository emailRepository;

  MarkAsEmailReadInteractor(this.emailRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, EmailId emailId, ReadActions readAction) async* {
    try {
      final result = await emailRepository.markAsRead(accountId, emailId, readAction);
      yield result ? Right(MarkAsEmailReadSuccess(emailId, readAction)) : Left(MarkAsEmailReadFailure(null, readAction));
    } catch (e) {
      yield Left(MarkAsEmailReadFailure(e, readAction));
    }
  }
}