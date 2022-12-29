import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/fcm_subscription.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/store_subscription_state.dart';

class StoreSubscriptionInteractor {
  final FCMRepository _fcmRepository;

  StoreSubscriptionInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute(FCMSubscription fcmSubscription) async* {
    try {
      yield Right<Failure, Success>(StoreSubscriptionLoading());
      await _fcmRepository.storeSubscription(fcmSubscription);
      yield Right<Failure, Success>(StoreSubscriptionSuccess());
    } catch (e) {
      yield Left<Failure, Success>(StoreSubscriptionFailure(e));
    }
  }
}