import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/repository/sending_queue_repository.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/state/delete_multiple_sending_email_state.dart';

class DeleteMultipleSendingEmailInteractor {
  final SendingQueueRepository _sendingQueueRepository;

  DeleteMultipleSendingEmailInteractor(this._sendingQueueRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, UserName userName, List<String> sendingIds) async* {
    try {
      yield Right<Failure, Success>(DeleteMultipleSendingEmailLoading());
      await _sendingQueueRepository.deleteMultipleSendingEmail(accountId, userName, sendingIds);
      yield Right<Failure, Success>(DeleteMultipleSendingEmailSuccess(sendingIds));
    } catch (e) {
      yield Left<Failure, Success>(DeleteMultipleSendingEmailFailure(e));
    }
  }
}