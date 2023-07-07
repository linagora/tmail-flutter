import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class UpdateAuthenticationAccountLoading extends LoadingState {}

class UpdateAuthenticationAccountSuccess extends UIState {}

class UpdateAuthenticationAccountFailure extends FeatureFailure {

  UpdateAuthenticationAccountFailure(dynamic exception) : super(exception: exception);
}