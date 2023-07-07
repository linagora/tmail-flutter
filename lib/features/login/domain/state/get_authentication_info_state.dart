import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class GetAuthenticationInfoLoading extends LoadingState {}

class GetAuthenticationInfoSuccess extends UIState {}

class GetAuthenticationInfoFailure extends FeatureFailure {

  GetAuthenticationInfoFailure(dynamic exception) : super(exception: exception);
}