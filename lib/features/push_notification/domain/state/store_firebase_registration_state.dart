
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StoreFirebaseRegistrationLoading extends LoadingState {}

class StoreFirebaseRegistrationSuccess extends UIState {}

class StoreFirebaseRegistrationFailure extends FeatureFailure {

  StoreFirebaseRegistrationFailure(dynamic exception) : super(exception: exception);
}