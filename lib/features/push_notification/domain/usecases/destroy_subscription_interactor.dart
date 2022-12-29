import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/destroy_subscription_state.dart';

class DestroySubscriptionInteractor {

  final FCMRepository _fcmRepository;

  DestroySubscriptionInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute(String subscriptionId) async* {
    try {
      yield Right<Failure, Success>(DestroySubscriptionLoading());
      final destroyedSubscription = await _fcmRepository.destroySubscription(subscriptionId);
      yield Right<Failure, Success>(DestroySubscriptionSuccess(destroyedSubscription));
    } catch (e) {
      yield Left<Failure, Success>(DestroySubscriptionFailure(e));
    }
  }
}