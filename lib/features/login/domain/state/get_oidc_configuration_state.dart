import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class GetOIDCConfigurationLoading extends LoadingState {}

class GetOIDCConfigurationFailure extends FeatureFailure {

  GetOIDCConfigurationFailure(dynamic exception) : super(exception: exception);
}