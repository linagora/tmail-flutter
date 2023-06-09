import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/email/domain/state/store_sending_email_state.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/repository/sending_queue_repository.dart';

class StoreSendingEmailInteractor {
  final SendingQueueRepository _sendingQueueRepository;

  StoreSendingEmailInteractor(this._sendingQueueRepository);

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    UserName userName,
    SendingEmail sendingEmail,
  ) async* {
    try {
      yield Right<Failure, Success>(StoreSendingEmailLoading());
      final storedSendingEmail = await _sendingQueueRepository.storeSendingEmail(accountId, userName, sendingEmail);
      yield Right<Failure, Success>(StoreSendingEmailSuccess(storedSendingEmail));
    } catch (e) {
      yield Left<Failure, Success>(StoreSendingEmailFailure(e));
    }
  }
}