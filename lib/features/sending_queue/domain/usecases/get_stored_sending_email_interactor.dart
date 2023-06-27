import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/offline_mode/model/sending_state.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/repository/sending_queue_repository.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/state/get_stored_sending_email_state.dart';

class GetStoredSendingEmailInteractor {
  final SendingQueueRepository _sendingQueueRepository;

  GetStoredSendingEmailInteractor(this._sendingQueueRepository);

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    UserName userName,
    String sendingId,
    SendingState sendingState
  ) async* {
    try {
      yield Right<Failure, Success>(GetStoredSendingEmailLoading());
      final sendingEmail = await _sendingQueueRepository.getStoredSendingEmail(accountId, userName, sendingId);
      yield Right<Failure, Success>(
        GetStoredSendingEmailSuccess(
          sendingEmail,
          accountId,
          userName,
          sendingState
        )
      );
    } catch (e) {
      yield Left<Failure, Success>(GetStoredSendingEmailFailure(e));
    }
  }
}