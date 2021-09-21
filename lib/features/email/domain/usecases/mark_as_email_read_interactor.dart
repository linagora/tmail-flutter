import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';

class MarkAsEmailReadInteractor {
  final EmailRepository _emailRepository;

  MarkAsEmailReadInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, Email email, ReadActions readAction) async* {
    try {
      final result = await _emailRepository.markAsRead(accountId, [email], readAction);
      if (result.isNotEmpty) {
        final updatedEmail = email.updatedEmail(newKeywords: result.first.keywords);
        yield Right(MarkAsEmailReadSuccess(updatedEmail, readAction));
      } else {
        yield Left(MarkAsEmailReadFailure(null, readAction));
      }
    } catch (e) {
      yield Left(MarkAsEmailReadFailure(e, readAction));
    }
  }
}