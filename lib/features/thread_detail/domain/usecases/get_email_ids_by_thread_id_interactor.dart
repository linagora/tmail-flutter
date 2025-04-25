import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/repository/thread_detail_repository.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_email_ids_by_thread_id_state.dart';

class GetEmailIdsByThreadIdInteractor {
  const GetEmailIdsByThreadIdInteractor(this._threadDetailRepository);

  final ThreadDetailRepository _threadDetailRepository;

  Stream<Either<Failure, Success>> execute(
    ThreadId threadId,
    Session session,
    AccountId accountId,
    MailboxId sentMailboxId,
    String ownEmailAddress,
  ) async* {
    try {
      yield Right(GettingEmailIdsByThreadId());
      final result = await _threadDetailRepository.getEmailIdsByThreadId(
        threadId,
        session,
        accountId,
        sentMailboxId,
        ownEmailAddress,
      );
      yield Right(GetEmailIdsByThreadIdSuccess(result));
    } catch (e) {
      logError('GetEmailIdsByThreadIdInteractor::execute(): Exception: $e');
      yield Left(GetEmailIdsByThreadIdFailure(exception: e));
    }
  }
}