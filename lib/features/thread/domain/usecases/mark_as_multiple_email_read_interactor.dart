import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/read_actions.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';

class MarkAsMultipleEmailReadInteractor {
  final MarkAsEmailReadInteractor markAsEmailReadInteractor;

  MarkAsMultipleEmailReadInteractor(this.markAsEmailReadInteractor);

  Stream<Either<Failure, Success>> execute(
      AccountId accountId,
      List<EmailId> listEmailId,
      ReadActions readAction
  ) async* {
    try {
      final listResult = await Future.wait(listEmailId.map((emailId) async {
        final result = await markAsEmailReadInteractor.execute(accountId, emailId, readAction).toList();
        return result.first;
      }));
      if (listResult.length == 1) {
        yield listResult.first;
      } else {
        var failedFileCount = 0;
        listResult.forEach((element) {
          if (element is Left) {
            failedFileCount++;
          }
        });
        if (failedFileCount == 0) {
          yield Right(MarkAsMultipleEmailReadAllSuccess(listResult, readAction));
        } else if (failedFileCount == listResult.length) {
          yield Left(MarkAsMultipleEmailReadAllFailure(listResult, readAction));
        }
        yield Right(MarkAsMultipleEmailReadHasSomeEmailFailure(listResult, readAction));
      }
    } catch (e) {
      yield Left(MarkAsMultipleEmailReadFailure(e, readAction));
    }
  }
}