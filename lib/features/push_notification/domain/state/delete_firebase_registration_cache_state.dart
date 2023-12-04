
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class DeleteFirebaseRegistrationCacheLoading extends LoadingState {}

class DeleteFirebaseRegistrationCacheSuccess extends UIState {}

class DeleteFirebaseRegistrationCacheFailure extends FeatureFailure {

  DeleteFirebaseRegistrationCacheFailure(dynamic exception) : super(exception: exception);
}