import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_fcm_subscription_local.dart';

class GetFCMSubscriptionLocalInteractor {
  final FCMRepository _fcmRepository;

  GetFCMSubscriptionLocalInteractor(this._fcmRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(GetFCMSubscriptionLocalLoading());
      final _subscription = await _fcmRepository.getSubscription();
      yield Right<Failure, Success>(GetFCMSubscriptionLocalSuccess(_subscription));
    } catch (e) {
      yield Left<Failure, Success>(GetFCMSubscriptionLocalFailure(e));
    }
  }
}