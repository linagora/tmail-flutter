import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/delete_fcm_token_state.dart';

class DeleteFCMTokenCacheInteractor {
  final FCMRepository _fcmRepository;

  DeleteFCMTokenCacheInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute(String accountId) async* {
    try {
      await _fcmRepository.deleteFCMToken(accountId);
      yield Right<Failure, Success>(DeleteFCMTokenSuccess());
    } catch (e) {
      logError('DeleteFirebaseCacheInteractor::execute(): $e');
      yield Left<Failure, Success>(DeleteFCMTokenFailure(e));
    }
  }
}
