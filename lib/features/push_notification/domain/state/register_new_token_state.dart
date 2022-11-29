
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:fcm/model/firebase_subscription.dart';

class RegisterNewTokenLoading extends UIState {}

class RegisterNewTokenSuccess extends UIState {

  final FirebaseSubscription firebaseSubscription;

  RegisterNewTokenSuccess(this.firebaseSubscription);

  @override
  List<Object> get props => [firebaseSubscription];
}

class RegisterNewTokenFailure extends FeatureFailure {
  final dynamic exception;

  RegisterNewTokenFailure(this.exception);

  @override
  List<Object> get props => [exception];
}