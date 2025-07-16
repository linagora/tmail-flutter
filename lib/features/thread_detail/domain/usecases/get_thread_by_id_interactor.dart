import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
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
    required EmailId? selectedEmailId,
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
        selectedEmailId: selectedEmailId,
      );

      yield Right(GetThreadByIdSuccess(
        result,
        threadId: threadId,
        updateCurrentThreadDetail: updateCurrentThreadDetail,
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
          selectedEmailId: selectedEmailId,
        ),
        updateCurrentThreadDetail: updateCurrentThreadDetail,
      ));
    }
  }
}