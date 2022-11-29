import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_device_id_state.dart';

class GetDeviceIdInteractor {
  final FCMRepository _fcmRepository;

  GetDeviceIdInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(GetDeviceIdLoading());
      final deviceId = await _fcmRepository.getDeviceId();
      yield Right<Failure, Success>(GetDeviceIdSuccess(deviceId));
    } catch (e) {
      yield Left<Failure, Success>(GetDeviceIdFailure(e));
    }
  }
}