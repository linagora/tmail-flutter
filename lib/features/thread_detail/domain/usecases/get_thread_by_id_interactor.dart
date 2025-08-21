import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/extensions/list_email_in_thread_detail_info_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/repository/thread_detail_repository.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';

class GetThreadByIdInteractor {
  const GetThreadByIdInteractor(this._threadDetailRepository);

  final ThreadDetailRepository _threadDetailRepository;

  Stream<Either<Failure, Success>> execute(
    ThreadId threadId,
    Session session,
    AccountId accountId,
    MailboxId sentMailboxId,
    String ownEmailAddress, {
    required bool isSentMailbox,
    bool updateCurrentThreadDetail = false,
  }) async* {
    try {
      yield Right(GettingThreadById(
        updateCurrentThreadDetail: updateCurrentThreadDetail,
      ));
      final result = await _threadDetailRepository.getThreadById(
        threadId,
        session,
        accountId,
        sentMailboxId,
        ownEmailAddress,
      );

      yield Right(GetThreadByIdSuccess(
        result.emailIdsToDisplay(isSentMailbox),
        threadId: threadId,
        updateCurrentThreadDetail: updateCurrentThreadDetail,
        emailsInThreadDetailInfo: result,
      ));
    } catch (e) {
      logError('GetEmailIdsByThreadIdInteractor::execute(): Exception: $e');
      yield Left(GetThreadByIdFailure(
        exception: e,
        onRetry: execute(
          threadId,
          session,
          accountId,
          sentMailboxId,
          ownEmailAddress,
          isSentMailbox: isSentMailbox,
          updateCurrentThreadDetail: updateCurrentThreadDetail,
        ),
        updateCurrentThreadDetail: updateCurrentThreadDetail,
      ));
    }
  }
}