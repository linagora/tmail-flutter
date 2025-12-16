import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_count_emails_in_folder_state.dart';

class GetCountUnreadEmailsInFolderInteractor {
  final ThreadRepository _threadRepository;

  GetCountUnreadEmailsInFolderInteractor(this._threadRepository);

  Stream<Either<Failure, Success>> execute({
    required Session session,
    required AccountId accountId,
  }) async* {
    try {
      yield Right(GettingCountUnreadEmailsInFolder());
      final count = await _threadRepository.getCountUnreadEmailsInFolder(
        session: session,
        accountId: accountId,
      );
      yield Right(GetCountUnreadEmailsInFolderSuccess(count: count));
    } catch (e) {
      yield Left(GetCountUnreadEmailsInFolderFailure(e));
    }
  }
}
