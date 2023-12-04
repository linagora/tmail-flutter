
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class UpdateFirebaseRegistrationTokenLoading extends LoadingState {}

class UpdateFirebaseRegistrationTokenSuccess extends UIState {}

class UpdateFirebaseRegistrationTokenFailure extends FeatureFailure {

  UpdateFirebaseRegistrationTokenFailure(dynamic exception) : super(exception: exception);
}