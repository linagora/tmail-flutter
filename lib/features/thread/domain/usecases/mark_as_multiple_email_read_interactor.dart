import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';

class MarkAsMultipleEmailReadInteractor {
  final MarkAsEmailReadInteractor markAsEmailReadInteractor;

  MarkAsMultipleEmailReadInteractor(this.markAsEmailReadInteractor);

  Future<Either<Failure, Success>> execute(AccountId accountId, List<EmailId> listEmailId, bool unread) async {
    try {
      final listResult = await Future.wait(listEmailId.map((emailId) =>
          markAsEmailReadInteractor.execute(accountId, emailId, unread)));
      if (listResult.length == 1) {
        return listResult.first;
      } else {
        var failedFileCount = 0;
        listResult.forEach((element) {
          if (element is Left) {
            failedFileCount++;
          }
        });
        if (failedFileCount == 0) {
          return Right(MarkAsMultipleEmailReadAllSuccess(listResult));
        } else if (failedFileCount == listResult.length) {
          return Left(MarkAsMultipleEmailReadAllFailure(listResult));
        }
        return Right(MarkAsMultipleEmailReadHasSomeEmailFailure(listResult));
      }
    } catch (e) {
      return Left(MarkAsMultipleEmailReadFailure(e));
    }
  }
}