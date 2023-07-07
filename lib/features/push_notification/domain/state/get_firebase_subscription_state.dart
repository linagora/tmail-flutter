
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:fcm/model/firebase_subscription.dart';

class GetFirebaseSubscriptionLoading extends UIState {}

class GetFirebaseSubscriptionSuccess extends UIState {

  final FirebaseSubscription firebaseSubscription;

  GetFirebaseSubscriptionSuccess(this.firebaseSubscription);

  @override
  List<Object> get props => [firebaseSubscription];
}

class GetFirebaseSubscriptionFailure extends FeatureFailure {

  GetFirebaseSubscriptionFailure(dynamic exception) : super(exception: exception);
}