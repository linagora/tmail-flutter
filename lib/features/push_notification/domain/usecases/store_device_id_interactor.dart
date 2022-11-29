import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/store_device_id_state.dart';

class StoreDeviceIdInteractor {
  final FCMRepository _fcmRepository;

  StoreDeviceIdInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute(String deviceId) async* {
    try {
      yield Right<Failure, Success>(StoreDeviceIdLoading());
      await _fcmRepository.storeDeviceId(deviceId);
      yield Right<Failure, Success>(StoreDeviceIdSuccess());
    } catch (e) {
      yield Left<Failure, Success>(StoreDeviceIdFailure(e));
    }
  }
}