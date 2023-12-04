
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/device_client_id.dart';
import 'package:fcm/model/fcm_token.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_firebase_registration_by_device_id_state.dart';

class GetFirebaseRegistrationByDeviceIdInteractor {

  final FCMRepository _fcmRepository;

  GetFirebaseRegistrationByDeviceIdInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute({required DeviceClientId deviceClientId, FcmToken? newFcmToken}) async* {
    try {
      yield Right<Failure, Success>(GetFirebaseRegistrationByDeviceIdLoading());
      final firebaseRegistration = await _fcmRepository.getFirebaseRegistrationByDeviceId(deviceClientId);
      yield Right<Failure, Success>(GetFirebaseRegistrationByDeviceIdSuccess(firebaseRegistration, newFcmToken));
    } catch (e) {
      yield Left<Failure, Success>(GetFirebaseRegistrationByDeviceIdFailure(e, newFcmToken));
    }
  }
}