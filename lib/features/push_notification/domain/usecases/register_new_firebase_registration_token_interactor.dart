
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/register_new_token_request.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/register_new_firebase_registration_token_state.dart';

class RegisterNewFirebaseRegistrationTokenInteractor {

  final FCMRepository _fcmRepository;

  RegisterNewFirebaseRegistrationTokenInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute(RegisterNewTokenRequest newTokenRequest) async* {
    try {
      yield Right<Failure, Success>(RegisterNewFirebaseRegistrationTokenLoading());
      final firebaseRegistration = await _fcmRepository.registerNewFirebaseRegistrationToken(newTokenRequest);
      yield Right<Failure, Success>(RegisterNewFirebaseRegistrationTokenSuccess(firebaseRegistration));
    } catch (e, st) {
      logError(
        'Register new firebase registration token failed',
        exception: e,
        stackTrace: st,
      );
      yield Left<Failure, Success>(RegisterNewFirebaseRegistrationTokenFailure(e));
    }
  }
}