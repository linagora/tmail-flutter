import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_sending_email_state.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/repository/sending_queue_repository.dart';

class DeleteSingleSendingEmailInteractor {
  final SendingQueueRepository _sendingQueueRepository;

  DeleteSingleSendingEmailInteractor(this._sendingQueueRepository);

  Future<Either<Failure, Success>> execute(AccountId accountId, UserName userName, String sendingId) async {
    try {
      await _sendingQueueRepository.deleteSendingEmail(accountId, userName, sendingId);
      return Right<Failure, Success>(DeleteSendingEmailSuccess());
    } catch (e) {
      return Left<Failure, Success>(DeleteSendingEmailFailure(e));
    }
  }
}