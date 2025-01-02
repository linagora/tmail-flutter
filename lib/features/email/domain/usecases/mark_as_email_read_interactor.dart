import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/read_actions.dart';
import 'package:tmail_ui_user/features/email/domain/model/mark_read_action.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';

class MarkAsEmailReadInteractor {
  final EmailRepository _emailRepository;

  MarkAsEmailReadInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    EmailId emailId,
    ReadActions readAction,
    MarkReadAction markReadAction,
  ) async* {
    try {
      final result = await _emailRepository.markAsRead(
        session,
        accountId,
        [emailId],
        readAction,
      );

      if (result.emailIdsSuccess.isEmpty) {
        yield Left(MarkAsEmailReadFailure(readAction));
      } else {
        yield Right(MarkAsEmailReadSuccess(
          result.emailIdsSuccess.first,
          readAction,
          markReadAction,
        ));
      }
    } catch (e) {
      yield Left(MarkAsEmailReadFailure(readAction, exception: e));
    }
  }
}