
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/fcm_subscription.dart';

class GetFCMSubscriptionLocalLoading extends UIState {}

class GetFCMSubscriptionLocalSuccess extends UIState {

  final FCMSubscription fcmSubscription;

  GetFCMSubscriptionLocalSuccess(this.fcmSubscription);

  @override
  List<Object> get props => [fcmSubscription];
}

class GetFCMSubscriptionLocalFailure extends FeatureFailure {
  final dynamic exception;

  GetFCMSubscriptionLocalFailure(this.exception);

  @override
  List<Object> get props => [exception];
}