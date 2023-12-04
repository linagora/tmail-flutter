
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/update_token_expired_time_request.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/update_firebase_registration_token_state.dart';

class UpdateFirebaseRegistrationTokenInteractor {

  final FCMRepository _fcmRepository;

  UpdateFirebaseRegistrationTokenInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute(UpdateTokenExpiredTimeRequest updateTokenExpiredTimeRequest) async* {
    try {
      yield Right<Failure, Success>(UpdateFirebaseRegistrationTokenLoading());
      await _fcmRepository.updateFirebaseRegistrationToken(updateTokenExpiredTimeRequest);
      yield Right<Failure, Success>(UpdateFirebaseRegistrationTokenSuccess());
    } catch (e) {
      yield Left<Failure, Success>(UpdateFirebaseRegistrationTokenFailure(e));
    }
  }
}