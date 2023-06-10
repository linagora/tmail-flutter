import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/sending_queue/data/exceptions/sending_queue_exceptions.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/repository/sending_queue_repository.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/state/update_multiple_sending_email_state.dart';

class UpdateMultipleSendingEmailInteractor {
  final SendingQueueRepository _sendingQueueRepository;

  UpdateMultipleSendingEmailInteractor(this._sendingQueueRepository);

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    UserName userName,
    List<SendingEmail> newSendingEmails
  ) async* {
    try {
      yield Right<Failure, Success>(UpdateMultipleSendingEmailLoading());
      final storedSendingEmails = await _sendingQueueRepository.updateMultipleSendingEmail(
        accountId,
        userName,
        newSendingEmails);
      if (storedSendingEmails.length == newSendingEmails.length) {
        yield Right<Failure, Success>(UpdateMultipleSendingEmailAllSuccess(storedSendingEmails));
      } else if (storedSendingEmails.isEmpty) {
        yield Left<Failure, Success>(UpdateMultipleSendingEmailAllFailure(NotFoundSendingEmailHiveObject()));
      } else {
        yield Right<Failure, Success>(UpdateMultipleSendingEmailHasSomeSuccess(storedSendingEmails));
      }
    } catch (e) {
      yield Left<Failure, Success>(UpdateMultipleSendingEmailFailure(e));
    }
  }
}