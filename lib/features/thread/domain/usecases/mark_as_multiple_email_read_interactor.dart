import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
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
    ReadActions readAction,
    MailboxId? mailboxId,
  ) async* {
    try {
      yield Right(LoadingMarkAsMultipleEmailReadAll());

      final result = await _emailRepository.markAsRead(
        session,
        accountId,
        emailIds,
        readAction,
      );

      if (emailIds.length == result.length) {
        yield Right(MarkAsMultipleEmailReadAllSuccess(
          result,
          readAction,
          mailboxId,
        ));
      } else if (result.isEmpty) {
        yield Left(MarkAsMultipleEmailReadAllFailure(readAction));
      } else {
        yield Right(MarkAsMultipleEmailReadHasSomeEmailFailure(
          result,
          readAction,
          mailboxId,
        ));
      }
    } catch (e) {
      yield Left(MarkAsMultipleEmailReadFailure(readAction, e));
    }
  }
}