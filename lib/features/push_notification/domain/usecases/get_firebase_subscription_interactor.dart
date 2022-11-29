
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_firebase_subscription_state.dart';

class GetFirebaseSubscriptionInteractor {

  final FCMRepository _fcmRepository;

  GetFirebaseSubscriptionInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute(String deviceId) async* {
    try {
      yield Right<Failure, Success>(GetFirebaseSubscriptionLoading());
      final firebaseSubscription = await _fcmRepository.getFirebaseSubscriptionByDeviceId(deviceId);
      yield Right<Failure, Success>(GetFirebaseSubscriptionSuccess(firebaseSubscription));
    } catch (e) {
      yield Left<Failure, Success>(GetFirebaseSubscriptionFailure(e));
    }
  }
}