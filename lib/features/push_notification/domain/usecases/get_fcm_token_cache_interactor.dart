
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_fcm_token_state.dart';

class GetFCMTokenCacheInteractor {

  final FCMRepository _fcmRepository;

  GetFCMTokenCacheInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute(
      String accountId) async* {
    try {
      final fcmToken = await _fcmRepository.getFCMToken(accountId);
      yield Right<Failure, Success>(GetFCMTokenSuccess(fcmToken));
    } catch (e) {
      logError('GetFirebaseCacheInteractor::execute(): $e');
      yield Left<Failure, Success>(GetFCMTokenFailure(e));
    }
  }
}