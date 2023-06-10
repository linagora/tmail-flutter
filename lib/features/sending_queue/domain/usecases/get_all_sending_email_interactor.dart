import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/repository/sending_queue_repository.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/state/get_all_sending_email_state.dart';

class GetAllSendingEmailInteractor {
  final SendingQueueRepository _sendingQueueRepository;

  GetAllSendingEmailInteractor(this._sendingQueueRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, UserName userName) async* {
    try {
      yield Right<Failure, Success>(GetAllSendingEmailLoading());
      final sendingEmails = await _sendingQueueRepository.getAllSendingEmails(accountId, userName);
      yield Right<Failure, Success>(GetAllSendingEmailSuccess(sendingEmails));
    } catch (e) {
      yield Left<Failure, Success>(GetAllSendingEmailFailure(e));
    }
  }
}