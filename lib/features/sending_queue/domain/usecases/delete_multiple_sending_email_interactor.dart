import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/state/delete_multiple_sending_email_state.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/delete_single_sending_email_interactor.dart';

class DeleteMultipleSendingEmailInteractor {
  final DeleteSingleSendingEmailInteractor _deleteSingleSendingEmailInteractor;

  DeleteMultipleSendingEmailInteractor(this._deleteSingleSendingEmailInteractor);

  Stream<Either<Failure, Success>> execute(AccountId accountId, UserName userName, List<String> sendingIds) async* {
    try {
      yield Right<Failure, Success>(DeleteMultipleSendingEmailLoading());
      final listResult = await Future.wait(
        sendingIds.map((sendingId) => _deleteSingleSendingEmailInteractor.execute(accountId, userName, sendingId)),
        eagerError: true
      );

      bool isAllSuccess = listResult.every((either) => either.isRight());
      bool isAllFailure = listResult.every((either) => either.isLeft());

      if (isAllSuccess) {
        yield Right<Failure, Success>(DeleteMultipleSendingEmailAllSuccess());
      } else if (isAllFailure) {
        yield Left<Failure, Success>(DeleteMultipleSendingEmailAllFailure(null));
      } else {
        yield Right<Failure, Success>(DeleteMultipleSendingEmailHasSomeSuccess());
      }
    } catch (e) {
      yield Left<Failure, Success>(DeleteMultipleSendingEmailFailure(e));
    }
  }
}