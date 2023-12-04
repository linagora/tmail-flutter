import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class DestroyFirebaseRegistrationLoading extends LoadingState {}

class DestroyFirebaseRegistrationSuccess extends UIState {}

class DestroyFirebaseRegistrationFailure extends FeatureFailure {

  DestroyFirebaseRegistrationFailure(dynamic exception) : super(exception: exception);
}