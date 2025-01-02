import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';

class MarkAsMultipleEmailReadInteractor {
  final EmailRepository _emailRepository;

  MarkAsMultipleEmailReadInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    ReadActions readAction
  ) async* {
    try {
      yield Right(LoadingMarkAsMultipleEmailReadAll());

      final result = await _emailRepository.markAsRead(
        session,
        accountId,
        emailIds,
        readAction,
      );

      if (emailIds.length == result.emailIdsSuccess.length) {
        yield Right(MarkAsMultipleEmailReadAllSuccess(
            result.emailIdsSuccess.length,
            readAction,
        ));
      } else if (result.emailIdsSuccess.isEmpty) {
        yield Left(MarkAsMultipleEmailReadAllFailure(readAction));
      } else {
        yield Right(MarkAsMultipleEmailReadHasSomeEmailFailure(
            result.emailIdsSuccess.length,
            readAction,
        ));
      }
    } catch (e) {
      yield Left(MarkAsMultipleEmailReadFailure(readAction, e));
    }
  }
}