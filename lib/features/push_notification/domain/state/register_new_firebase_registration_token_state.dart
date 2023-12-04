
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:fcm/model/firebase_registration.dart';

class RegisterNewFirebaseRegistrationTokenLoading extends LoadingState {}

class RegisterNewFirebaseRegistrationTokenSuccess extends UIState {

  final FirebaseRegistration firebaseRegistration;

  RegisterNewFirebaseRegistrationTokenSuccess(this.firebaseRegistration);

  @override
  List<Object> get props => [firebaseRegistration];
}

class RegisterNewFirebaseRegistrationTokenFailure extends FeatureFailure {

  RegisterNewFirebaseRegistrationTokenFailure(dynamic exception) : super(exception: exception);
}