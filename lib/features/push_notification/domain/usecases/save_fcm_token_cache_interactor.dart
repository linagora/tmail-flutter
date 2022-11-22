import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:model/fcm/fcm_token_dto.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/save_fcm_token_state.dart';

class SaveFCMTokenCacheInteractor {
  final FCMRepository _fcmRepository;

  SaveFCMTokenCacheInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute(FCMTokenDto fcmTokenDto) async* {
    try {
      await _fcmRepository.setFCMToken(fcmTokenDto);
      yield Right<Failure, Success>(SaveFCMTokenSuccess());
    } catch (e) {
      logError('SaveFirebaseCacheInteractor::execute(): $e');
      yield Left<Failure, Success>(SaveFCMTokenFailure(e));
    }
  }
}
